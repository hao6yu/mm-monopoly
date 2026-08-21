package com.hyu.properotyTycoon

/**
 * Correlates Godot movement completions with the Flutter view session that sent
 * them. Godot remembers its last 64 completed/cancelled commands and considers
 * timestamp-prefixed commands stale after 9.5 seconds. Entries live through
 * Flutter's 10-second response window, but never accumulate beyond those limits.
 */
internal class GodotCommandSessionRegistry(
    private val maxEntries: Int = DEFAULT_MAX_ENTRIES,
    private val commandFreshnessMicros: Long = DEFAULT_COMMAND_FRESHNESS_MICROS,
    private val retentionAgeMicros: Long = DEFAULT_RETENTION_AGE_MICROS,
    private val maxFutureSkewMicros: Long = DEFAULT_MAX_FUTURE_SKEW_MICROS,
    private val nowMicros: () -> Long = { System.currentTimeMillis() * 1_000L },
) {
    companion object {
        internal const val DEFAULT_MAX_ENTRIES = 64
        internal const val DEFAULT_COMMAND_FRESHNESS_MICROS = 9_500_000L
        internal const val DEFAULT_RETENTION_AGE_MICROS = 10_000_000L
        internal const val DEFAULT_MAX_FUTURE_SKEW_MICROS = 60_000_000L
    }

    private data class Entry(
        val sessionId: Long,
        val registeredAtMicros: Long,
    )

    private val entries = linkedMapOf<String, Entry>()

    init {
        require(maxEntries > 0)
        require(commandFreshnessMicros > 0)
        require(retentionAgeMicros >= commandFreshnessMicros)
        require(maxFutureSkewMicros >= 0)
    }

    @Synchronized
    fun register(commandId: String, sessionId: Long): Boolean {
        if (commandId.isBlank()) return false

        val now = nowMicros()
        prune(now)
        val commandTimestamp = timestampPrefix(commandId)
        if (commandTimestamp != null) {
            val age = now - commandTimestamp
            if (age > commandFreshnessMicros || age < -maxFutureSkewMicros) return false
        }

        // Re-registration refreshes insertion order without growing the map.
        entries.remove(commandId)
        entries[commandId] = Entry(sessionId, now)
        while (entries.size > maxEntries) {
            val oldest = entries.entries.iterator()
            if (!oldest.hasNext()) break
            oldest.next()
            oldest.remove()
        }
        return true
    }

    @Synchronized
    fun remove(commandId: String): Long? {
        prune(nowMicros())
        return entries.remove(commandId)?.sessionId
    }

    @Synchronized
    fun clear() {
        entries.clear()
    }

    @Synchronized
    internal fun contains(commandId: String): Boolean {
        prune(nowMicros())
        return entries.containsKey(commandId)
    }

    @Synchronized
    internal fun size(): Int {
        prune(nowMicros())
        return entries.size
    }

    private fun prune(now: Long) {
        val iterator = entries.entries.iterator()
        while (iterator.hasNext()) {
            val entry = iterator.next().value
            if (now - entry.registeredAtMicros > retentionAgeMicros) iterator.remove()
        }
    }

    private fun timestampPrefix(commandId: String): Long? {
        val separator = commandId.indexOf('_')
        if (separator <= 0) return null
        return commandId.substring(0, separator).toLongOrNull()
    }
}
