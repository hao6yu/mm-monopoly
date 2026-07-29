package com.hyu.properotyTycoon

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.Fragment
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import org.godotengine.godot.Godot
import org.godotengine.godot.GodotFragment
import org.godotengine.godot.GodotHost
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

/**
 * Flutter remains the gameplay host while Godot renders the Manhattan board in
 * an Android platform view. Only one GodotFragment is kept for the activity,
 * matching Godot's single-engine-instance-per-process requirement.
 */
class MainActivity : FlutterFragmentActivity(), GodotHost {
    companion object {
        const val GODOT_VIEW_TYPE = "property_tycoon/godot_board"
        const val GODOT_CHANNEL = "property_tycoon/godot_board_bridge"
        private const val GODOT_FRAGMENT_TAG = "property_tycoon_godot_fragment"
    }

    private var godotFragment: GodotFragment? = null
    private var bridgePlugin: PropertyTycoonGodotBridge? = null
    private var channel: MethodChannel? = null
    private var pendingState: String? = null
    private val pendingRolls = ArrayDeque<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GODOT_CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(true)
                "syncState" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error("invalid_state", "Expected a JSON string.", null)
                    } else {
                        pendingState = json
                        bridgePlugin?.syncState(json)
                        result.success(true)
                    }
                }
                "animateRoll" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error("invalid_roll", "Expected a JSON string.", null)
                    } else {
                        if (bridgePlugin == null) {
                            pendingRolls.addLast(json)
                        } else {
                            bridgePlugin?.animateRoll(json)
                        }
                        result.success(true)
                    }
                }
                "cameraGesture" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error(
                            "invalid_camera_gesture",
                            "Expected a JSON string.",
                            null,
                        )
                    } else {
                        bridgePlugin?.cameraGesture(json)
                        result.success(bridgePlugin != null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(GODOT_VIEW_TYPE, GodotBoardViewFactory(this))
    }

    internal fun attachGodotView(container: FrameLayout) {
        val existing =
            supportFragmentManager.findFragmentByTag(GODOT_FRAGMENT_TAG) as? GodotFragment
        if (existing != null) {
            godotFragment = existing
            moveFragmentView(existing, container)
            return
        }

        val fragment = GodotFragment()
        godotFragment = fragment
        supportFragmentManager
            .beginTransaction()
            .replace(container.id, fragment, GODOT_FRAGMENT_TAG)
            .commitNowAllowingStateLoss()
    }

    private fun moveFragmentView(fragment: Fragment, container: FrameLayout) {
        val view = fragment.view ?: return
        (view.parent as? ViewGroup)?.removeView(view)
        container.addView(
            view,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
    }

    internal fun notifyFlutter(method: String, arguments: Map<String, Any?> = emptyMap()) {
        runOnUiThread {
            channel?.invokeMethod(method, arguments)
        }
    }

    override fun getActivity() = this

    override fun getGodot() = godotFragment?.godot

    override fun getCommandLine(): List<String> =
        listOf("--main-pack", "res://godot/property_tycoon.pck")

    override fun getHostPlugins(godot: Godot): Set<GodotPlugin> {
        if (bridgePlugin == null) {
            bridgePlugin = PropertyTycoonGodotBridge(godot, this).also { plugin ->
                pendingState?.let(plugin::syncState)
                while (pendingRolls.isNotEmpty()) {
                    plugin.animateRoll(pendingRolls.removeFirst())
                }
            }
        }
        return setOf(bridgePlugin!!)
    }
}

private class GodotBoardViewFactory(
    private val activity: MainActivity,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        GodotBoardPlatformView(context, activity)
}

private class GodotBoardPlatformView(
    context: Context,
    activity: MainActivity,
) : PlatformView {
    private val container =
        FrameLayout(context).apply {
            id = View.generateViewId()
            isFocusable = true
            isFocusableInTouchMode = true
        }

    init {
        activity.attachGodotView(container)
    }

    override fun getView(): View = container

    override fun dispose() {
        // The fragment and engine intentionally survive navigation. Its render
        // view is moved into the next platform-view container when reopened.
        container.visibility = View.GONE
    }
}

/**
 * Runtime Godot plugin. Host-to-Godot messages are signals; Godot-to-Flutter
 * messages are annotated calls routed through the activity's MethodChannel.
 */
private class PropertyTycoonGodotBridge(
    godot: Godot,
    private val activity: MainActivity,
) : GodotPlugin(godot) {
    companion object {
        private val SYNC_STATE_SIGNAL = SignalInfo("sync_state", String::class.java)
        private val ANIMATE_ROLL_SIGNAL = SignalInfo("animate_roll", String::class.java)
        private val CAMERA_GESTURE_SIGNAL = SignalInfo("camera_gesture", String::class.java)
    }

    private var scriptReady = false
    private var latestState: String? = null
    private val queuedRolls = ArrayDeque<String>()

    override fun getPluginName() = "PropertyTycoonBridge"

    override fun getPluginSignals() =
        setOf(SYNC_STATE_SIGNAL, ANIMATE_ROLL_SIGNAL, CAMERA_GESTURE_SIGNAL)

    @Synchronized
    fun syncState(json: String) {
        latestState = json
        if (scriptReady) {
            emitSignal(SYNC_STATE_SIGNAL.name, json)
        }
    }

    @Synchronized
    fun animateRoll(json: String) {
        if (scriptReady) {
            emitSignal(ANIMATE_ROLL_SIGNAL.name, json)
        } else {
            queuedRolls.addLast(json)
        }
    }

    @Synchronized
    fun cameraGesture(json: String) {
        if (scriptReady) {
            emitSignal(CAMERA_GESTURE_SIGNAL.name, json)
        }
    }

    @UsedByGodot
    @Synchronized
    fun ready() {
        scriptReady = true
        latestState?.let { emitSignal(SYNC_STATE_SIGNAL.name, it) }
        while (queuedRolls.isNotEmpty()) {
            emitSignal(ANIMATE_ROLL_SIGNAL.name, queuedRolls.removeFirst())
        }
        activity.notifyFlutter("boardReady")
    }

    @UsedByGodot
    fun movementComplete(
        commandId: String,
        playerId: String,
        logicalPosition: Long,
        visualPosition: Long,
    ) {
        activity.notifyFlutter(
            "movementComplete",
            mapOf(
                "commandId" to commandId,
                "playerId" to playerId,
                "logicalPosition" to logicalPosition,
                "visualPosition" to visualPosition,
            ),
        )
    }
}
