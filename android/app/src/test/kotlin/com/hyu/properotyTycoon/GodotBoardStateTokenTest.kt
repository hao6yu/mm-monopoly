package com.hyu.properotyTycoon

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class GodotBoardStateTokenTest {
    @Test
    fun acceptsCompleteSceneApplicationToken() {
        assertEquals(
            GodotBoardStateToken("game-7", 12L, "usa"),
            GodotBoardStateToken.fromValues(
                sessionId = "game-7",
                stateGeneration = 12L,
                boardId = "usa",
            ),
        )
    }

    @Test
    fun rejectsUnversionedOrIncompleteState() {
        assertNull(
            GodotBoardStateToken.fromValues(
                sessionId = "game-7",
                stateGeneration = null,
                boardId = "usa",
            ),
        )
        assertNull(
            GodotBoardStateToken.fromValues(
                sessionId = null,
                stateGeneration = 12L,
                boardId = "usa",
            ),
        )
    }

    @Test
    fun readyDispatchSendsOneCachedStateBeforeBoardReady() {
        assertEquals(
            listOf(
                GodotBoardReadyDispatchAction.SYNC_CACHED_STATE,
                GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
                GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
            ),
            godotBoardReadyDispatchActions(hasCachedState = true),
        )
        assertEquals(
            listOf(
                GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
                GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
            ),
            godotBoardReadyDispatchActions(hasCachedState = false),
        )
    }
}
