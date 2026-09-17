package com.hyu.properotyTycoon

/**
 * Gives each Flutter platform view exclusive ownership of the retained Godot
 * engine. A late dispose from an older view cannot pause or detach its successor.
 */
internal class GodotBoardSessionTracker {
    internal data class Session(val id: Long)

    private var nextSessionId = 0L

    var activeSession: Session? = null
        private set

    @Synchronized
    fun attach(): Session {
        val session = Session(++nextSessionId)
        activeSession = session
        return session
    }

    @Synchronized
    fun detach(sessionId: Long): Boolean {
        if (activeSession?.id != sessionId) return false
        activeSession = null
        return true
    }

    @Synchronized
    fun isActive(sessionId: Long): Boolean = activeSession?.id == sessionId
}
