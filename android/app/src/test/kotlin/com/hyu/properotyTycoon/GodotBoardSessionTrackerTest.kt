package com.hyu.properotyTycoon

import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class GodotBoardSessionTrackerTest {
    @Test
    fun staleDisposeCannotDetachNewSession() {
        val tracker = GodotBoardSessionTracker()
        val first = tracker.attach()
        val second = tracker.attach()

        assertFalse(tracker.detach(first.id))
        assertTrue(tracker.isActive(second.id))
    }

    @Test
    fun activeSessionCanDetach() {
        val tracker = GodotBoardSessionTracker()
        val session = tracker.attach()

        assertTrue(tracker.detach(session.id))
        assertNull(tracker.activeSession)
    }
}
