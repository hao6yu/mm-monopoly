package com.hyu.properotyTycoon

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class GodotCommandSessionRegistryTest {
    @Test
    fun retainsOnlyTheLast64Commands() {
        var now = 10_000_000L
        val registry = GodotCommandSessionRegistry(nowMicros = { now })

        repeat(65) { index ->
            assertTrue(registry.register("${now}_player-$index", sessionId = 7L))
            now += 1
        }

        assertEquals(64, registry.size())
        assertFalse(registry.contains("10000000_player-0"))
        assertTrue(registry.contains("10000064_player-64"))
    }

    @Test
    fun rejectsExpiredAndImplausiblyFutureTimestampPrefixes() {
        val registry = GodotCommandSessionRegistry(nowMicros = { 70_000_000L })

        assertFalse(registry.register("60499999_player", sessionId = 1L))
        assertFalse(registry.register("130000001_player", sessionId = 1L))
        assertEquals(0, registry.size())
    }

    @Test
    fun prunesCancelledCommandsByAgeAndReturnsLiveSession() {
        var now = 20_000_000L
        val registry = GodotCommandSessionRegistry(nowMicros = { now })
        assertTrue(registry.register("20000000_player", sessionId = 42L))
        assertEquals(42L, registry.remove("20000000_player"))

        assertTrue(registry.register("20000001_cancelled", sessionId = 42L))
        now += GodotCommandSessionRegistry.DEFAULT_RETENTION_AGE_MICROS + 2

        assertNull(registry.remove("20000001_cancelled"))
        assertEquals(0, registry.size())
    }

    @Test
    fun legacyCommandWithoutTimestampIsStillBoundedFromReceipt() {
        var now = 1_000L
        val registry =
            GodotCommandSessionRegistry(
                commandFreshnessMicros = 100L,
                retentionAgeMicros = 100L,
                nowMicros = { now },
            )
        assertTrue(registry.register("bridge-smoke", sessionId = 3L))

        now = 1_101L

        assertFalse(registry.contains("bridge-smoke"))
    }
}
