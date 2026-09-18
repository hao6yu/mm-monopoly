package com.hyu.properotyTycoon

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Pins the native ready-time dispatch contract that makes warm re-entry
 * observable: a fresh engine must announce readiness exactly once and deliver
 * the current session's cached generation (when Flutter already sent one)
 * before notifying Flutter — never the previous session's state.
 */
class GodotBoardReadyDispatchTest {
    @Test
    fun freshEngineWithoutCachedStateNotifiesWithoutSyncing() {
        // Cold path: the scene is ready before Flutter sent any state. The
        // engine must only announce readiness; the state arrives afterwards
        // and is acknowledged with its own exact stateApplied.
        assertEquals(
            listOf(
                GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
                GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
            ),
            godotBoardReadyDispatchActions(hasCachedState = false),
        )
    }

    @Test
    fun freshEngineWithCachedStateSyncsBeforeNotifying() {
        // Warm path: Flutter sent the new session's state while the engine was
        // still booting. The state must be applied (and acknowledged through
        // stateApplied) before the readiness notification unlocks gameplay.
        assertEquals(
            listOf(
                GodotBoardReadyDispatchAction.SYNC_CACHED_STATE,
                GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
                GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
            ),
            godotBoardReadyDispatchActions(hasCachedState = true),
        )
    }
}
