package com.hyu.properotyTycoon

import android.content.Context
import java.io.IOException

internal data class GodotRuntimeAvailability(
    val available: Boolean,
    val reason: String? = null,
)

/**
 * Checks the two artifacts the embedded board needs before Flutter chooses 3D:
 * a readable Godot project pack and a native runtime compatible with this ABI.
 */
internal object GodotRuntimeValidator {
    internal const val PROJECT_PACK_ASSET = "godot/property_tycoon.pck"
    private const val MINIMUM_PROJECT_PACK_HEADER_SIZE = 64
    private val projectPackMagic = byteArrayOf(0x47, 0x44, 0x50, 0x43) // GDPC

    fun check(context: Context): GodotRuntimeAvailability {
        val packResult = checkProjectPack(context)
        if (!packResult.available) return packResult

        return try {
            // Initializing GodotLib loads libgodot_android.so. This is idempotent
            // and proves the installed APK contains a runtime for the device ABI.
            Class.forName(
                "org.godotengine.godot.GodotLib",
                true,
                context.classLoader,
            )
            GodotRuntimeAvailability(available = true)
        } catch (error: ClassNotFoundException) {
            GodotRuntimeAvailability(
                available = false,
                reason = "Godot Android runtime classes are missing.",
            )
        } catch (error: LinkageError) {
            GodotRuntimeAvailability(
                available = false,
                reason = "Godot native runtime could not load: ${error.message}",
            )
        } catch (error: SecurityException) {
            GodotRuntimeAvailability(
                available = false,
                reason = "Godot native runtime is blocked: ${error.message}",
            )
        }
    }

    private fun checkProjectPack(context: Context): GodotRuntimeAvailability =
        try {
            val header = ByteArray(MINIMUM_PROJECT_PACK_HEADER_SIZE)
            val bytesRead =
                context.assets.open(PROJECT_PACK_ASSET).use { input ->
                    var offset = 0
                    while (offset < header.size) {
                        val read = input.read(header, offset, header.size - offset)
                        if (read < 0) break
                        offset += read
                    }
                    offset
                }
            if (bytesRead != header.size || !hasValidProjectPackHeader(header)) {
                GodotRuntimeAvailability(
                    available = false,
                    reason = "Godot project pack is empty or invalid.",
                )
            } else {
                GodotRuntimeAvailability(available = true)
            }
        } catch (error: IOException) {
            GodotRuntimeAvailability(
                available = false,
                reason = "Godot project pack is missing: ${error.message}",
            )
        }

    internal fun hasValidProjectPackHeader(header: ByteArray): Boolean =
        header.size >= MINIMUM_PROJECT_PACK_HEADER_SIZE &&
            projectPackMagic.indices.all { index ->
                header[index] == projectPackMagic[index]
            }
}
