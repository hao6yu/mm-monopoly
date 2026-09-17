package com.hyu.properotyTycoon

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class GodotRuntimeValidatorTest {
    @Test
    fun acceptsGodotProjectPackMagic() {
        val header = ByteArray(64)
        header[0] = 0x47
        header[1] = 0x44
        header[2] = 0x50
        header[3] = 0x43
        assertTrue(
            GodotRuntimeValidator.hasValidProjectPackHeader(header),
        )
    }

    @Test
    fun rejectsMissingOrInvalidProjectPackMagic() {
        assertFalse(GodotRuntimeValidator.hasValidProjectPackHeader(byteArrayOf()))
        assertFalse(
            GodotRuntimeValidator.hasValidProjectPackHeader(
                byteArrayOf(0x47, 0x44, 0x50, 0x43),
            ),
        )
        assertFalse(
            GodotRuntimeValidator.hasValidProjectPackHeader(
                byteArrayOf(0x50, 0x4B, 0x03, 0x04),
            ),
        )
    }
}
