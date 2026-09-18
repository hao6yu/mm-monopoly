package com.hyu.properotyTycoon

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
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
import org.json.JSONObject

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
        private const val TAG = "PropertyTycoonGodot"
    }

    private var godotFragment: GodotFragment? = null
    private var bridgePlugin: PropertyTycoonGodotBridge? = null
    private var channel: MethodChannel? = null
    private var pendingState: String? = null
    private val boardSessions = GodotBoardSessionTracker()
    private val runtimeAvailability by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
        GodotRuntimeValidator.check(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GODOT_CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    if (!runtimeAvailability.available) {
                        Log.e(TAG, "3D board unavailable: ${runtimeAvailability.reason}")
                    }
                    result.success(runtimeAvailability.available)
                }
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
                "retryScene" -> {
                    val sessionId = boardSessions.activeSession?.id
                    result.success(
                        sessionId != null &&
                            bridgePlugin?.retryScene(sessionId) == true,
                    )
                }
                "animateRoll" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error("invalid_roll", "Expected a JSON string.", null)
                    } else {
                        val session = boardSessions.activeSession
                        val accepted =
                            if (session == null) {
                                false
                            } else {
                                bridgePlugin?.animateRoll(session.id, json) == true
                            }
                        if (accepted) {
                            result.success(true)
                        } else {
                            result.error(
                                "board_not_ready",
                                "The active 3D board is not ready for movement.",
                                null,
                            )
                        }
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
                        val sessionId = boardSessions.activeSession?.id
                        result.success(
                            sessionId != null &&
                                bridgePlugin?.cameraGesture(sessionId, json) == true,
                        )
                    }
                }
                "setCameraFollow" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error(
                            "invalid_camera_follow",
                            "Expected a JSON string.",
                            null,
                        )
                    } else {
                        val sessionId = boardSessions.activeSession?.id
                        result.success(
                            sessionId != null &&
                                bridgePlugin?.setCameraFollow(sessionId, json) == true,
                        )
                    }
                }
                "setGraphicsQuality" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error(
                            "invalid_graphics_quality",
                            "Expected a JSON string.",
                            null,
                        )
                    } else {
                        val sessionId = boardSessions.activeSession?.id
                        result.success(
                            sessionId != null &&
                                bridgePlugin?.setGraphicsQuality(sessionId, json) == true,
                        )
                    }
                }
                "setBoardVisible" -> {
                    val json = call.arguments as? String
                    val visible = runCatching {
                        json?.let { JSONObject(it).optBoolean("visible", true) }
                    }.getOrNull()
                    if (visible == null) {
                        result.error(
                            "invalid_board_visibility",
                            "Expected a JSON string with a visible flag.",
                            null,
                        )
                    } else {
                        setBoardVisible(visible)
                        result.success(true)
                    }
                }
                "pickBoardObject" -> {
                    val json = call.arguments as? String
                    if (json == null) {
                        result.error(
                            "invalid_board_pick",
                            "Expected a JSON string.",
                            null,
                        )
                    } else {
                        val sessionId = boardSessions.activeSession?.id
                        result.success(
                            sessionId != null &&
                                bridgePlugin?.pickBoardObject(sessionId, json) == true,
                        )
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

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    internal fun attachGodotView(container: FrameLayout): Long {
        val session = boardSessions.attach()
        container.visibility = View.VISIBLE

        val existing =
            supportFragmentManager.findFragmentByTag(GODOT_FRAGMENT_TAG) as? GodotFragment
        if (existing != null) {
            godotFragment = existing
            moveFragmentView(existing, container)
            supportFragmentManager
                .beginTransaction()
                .setMaxLifecycle(existing, Lifecycle.State.RESUMED)
                .commitNowAllowingStateLoss()
            bridgePlugin?.attachSession(session.id, pendingState)
            return session.id
        }

        val fragment = GodotFragment()
        godotFragment = fragment
        supportFragmentManager
            .beginTransaction()
            // Flutter creates the platform view before attaching it to the
            // activity hierarchy. Resolve the actual container, not its ID:
            // FragmentManager's activity lookup cannot find that ID yet.
            .add(container, fragment, GODOT_FRAGMENT_TAG)
            .commitNowAllowingStateLoss()
        return session.id
    }

    internal fun detachGodotView(sessionId: Long) {
        if (!boardSessions.detach(sessionId)) return

        bridgePlugin?.detachSession(sessionId)
        val fragment = godotFragment ?: return
        if (fragment.isAdded) {
            supportFragmentManager
                .beginTransaction()
                .setMaxLifecycle(fragment, Lifecycle.State.STARTED)
                .commitNowAllowingStateLoss()
        }
    }

    /**
     * Pauses or resumes the retained engine while its platform view stays
     * attached. The app presents ONE board for the whole process: the bundled
     * runtime destroys the engine when the render view leaves the window and
     * cannot re-initialize in place, so hidden boards are paused — no
     * rendering, no gameplay, no input — instead of torn down.
     */
    internal fun setBoardVisible(visible: Boolean) {
        val fragment = godotFragment ?: return
        if (!fragment.isAdded) return
        val targetState = if (visible) {
            Lifecycle.State.RESUMED
        } else {
            Lifecycle.State.STARTED
        }
        supportFragmentManager
            .beginTransaction()
            .setMaxLifecycle(fragment, targetState)
            .commitNowAllowingStateLoss()
        Log.i(TAG, "Board layer ${if (visible) "resumed" else "paused"}")
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

    internal fun notifyFlutterForSession(
        sessionId: Long,
        method: String,
        arguments: Map<String, Any?> = emptyMap(),
    ) {
        runOnUiThread {
            if (boardSessions.isActive(sessionId)) {
                channel?.invokeMethod(method, arguments)
            }
        }
    }

    override fun getActivity() = this

    override fun getGodot() = godotFragment?.godot

    override fun getCommandLine(): List<String> =
        listOf("--main-pack", "res://godot/property_tycoon.pck")

    override fun getHostPlugins(godot: Godot): Set<GodotPlugin> {
        if (bridgePlugin == null) {
            bridgePlugin = PropertyTycoonGodotBridge(godot, this).also { plugin ->
                val session = boardSessions.activeSession
                if (session != null) {
                    plugin.attachSession(session.id, pendingState)
                } else {
                    pendingState?.let(plugin::syncState)
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
    private val activity: MainActivity,
) : PlatformView {
    private val container =
        FrameLayout(context).apply {
            id = View.generateViewId()
            isFocusable = true
            isFocusableInTouchMode = true
        }

    private val sessionId = activity.attachGodotView(container)

    override fun getView(): View = container

    override fun dispose() {
        // Keep the single engine instance, but pause it while Flutter no longer
        // presents a board. The session id prevents a late dispose callback from
        // pausing a newer platform view that has already taken ownership.
        container.visibility = View.GONE
        activity.detachGodotView(sessionId)
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
        private val CAMERA_FOLLOW_SIGNAL = SignalInfo("camera_follow", String::class.java)
        private val GRAPHICS_QUALITY_SIGNAL = SignalInfo("graphics_quality", String::class.java)
        private val BOARD_TAP_SIGNAL = SignalInfo("board_tap", String::class.java)
    }

    private var scriptReady = false
    private var sceneReadyToken: String? = null
    private var latestState: String? = null
    private var latestStateToken: GodotBoardStateToken? = null
    private var attachedSessionId: Long? = null
    private val queuedRolls = ArrayDeque<QueuedRoll>()
    private val commandSessions = GodotCommandSessionRegistry()

    private data class QueuedRoll(
        val sessionId: Long,
        val commandId: String,
        val json: String,
    )

    override fun getPluginName() = "PropertyTycoonBridge"

    override fun getPluginSignals() =
        setOf(
            SYNC_STATE_SIGNAL,
            ANIMATE_ROLL_SIGNAL,
            CAMERA_GESTURE_SIGNAL,
            CAMERA_FOLLOW_SIGNAL,
            GRAPHICS_QUALITY_SIGNAL,
            BOARD_TAP_SIGNAL,
        )

    @Synchronized
    fun syncState(json: String) {
        // Godot treats an authoritative state sync as cancellation of any
        // hosted roll, and cancelled rolls intentionally emit no completion.
        queuedRolls.clear()
        commandSessions.clear()
        latestState = json
        latestStateToken = GodotBoardStateToken.fromJson(json)
        if (scriptReady && attachedSessionId != null) {
            emitSignal(SYNC_STATE_SIGNAL.name, json)
        }
    }

    @Synchronized
    fun attachSession(sessionId: Long, cachedState: String?) {
        attachedSessionId = sessionId
        queuedRolls.clear()
        commandSessions.clear()
        if (cachedState != null) {
            latestState = cachedState
            latestStateToken = GodotBoardStateToken.fromJson(cachedState)
        }
        if (scriptReady) announceReady(sessionId)
    }

    @Synchronized
    fun detachSession(sessionId: Long) {
        if (attachedSessionId != sessionId) return
        attachedSessionId = null
        queuedRolls.clear()
        commandSessions.clear()
    }

    @Synchronized
    fun animateRoll(sessionId: Long, json: String): Boolean {
        if (attachedSessionId != sessionId) return false
        val commandId = runCatching { JSONObject(json).optString("commandId") }.getOrNull()
        if (commandId.isNullOrBlank()) return false

        if (!commandSessions.register(commandId, sessionId)) return false
        if (scriptReady) {
            emitSignal(ANIMATE_ROLL_SIGNAL.name, json)
        } else {
            queuedRolls.addLast(QueuedRoll(sessionId, commandId, json))
        }
        return true
    }

    @Synchronized
    fun cameraGesture(sessionId: Long, json: String): Boolean {
        if (scriptReady && attachedSessionId == sessionId) {
            emitSignal(CAMERA_GESTURE_SIGNAL.name, json)
            return true
        }
        return false
    }

    @Synchronized
    fun setCameraFollow(sessionId: Long, json: String): Boolean {
        if (scriptReady && attachedSessionId == sessionId) {
            emitSignal(CAMERA_FOLLOW_SIGNAL.name, json)
            return true
        }
        return false
    }

    @Synchronized
    fun setGraphicsQuality(sessionId: Long, json: String): Boolean {
        if (scriptReady && attachedSessionId == sessionId) {
            emitSignal(GRAPHICS_QUALITY_SIGNAL.name, json)
            return true
        }
        return false
    }

    @Synchronized
    fun pickBoardObject(sessionId: Long, json: String): Boolean {
        if (scriptReady && attachedSessionId == sessionId) {
            emitSignal(BOARD_TAP_SIGNAL.name, json)
            return true
        }
        return false
    }

    @UsedByGodot
    @Synchronized
    fun ready(token: String) {
        if (token.isBlank()) return
        scriptReady = true
        sceneReadyToken = token
        val sessionId = attachedSessionId ?: return
        announceReady(sessionId)
    }

    @Synchronized
    fun retryScene(sessionId: Long): Boolean {
        if (!scriptReady ||
            sceneReadyToken.isNullOrBlank() ||
            attachedSessionId != sessionId
        ) {
            return false
        }
        announceReady(sessionId)
        return true
    }

    @Synchronized
    private fun announceReady(sessionId: Long) {
        val readyToken = sceneReadyToken
        if (!scriptReady || readyToken.isNullOrBlank() || attachedSessionId != sessionId) return
        for (action in godotBoardReadyDispatchActions(latestState != null)) {
            when (action) {
                GodotBoardReadyDispatchAction.SYNC_CACHED_STATE ->
                    latestState?.let { emitSignal(SYNC_STATE_SIGNAL.name, it) }
                GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS -> {
                    while (queuedRolls.isNotEmpty()) {
                        val roll = queuedRolls.removeFirst()
                        if (roll.sessionId == sessionId) {
                            emitSignal(ANIMATE_ROLL_SIGNAL.name, roll.json)
                        } else {
                            commandSessions.remove(roll.commandId)
                        }
                    }
                }
                GodotBoardReadyDispatchAction.NOTIFY_FLUTTER ->
                    activity.notifyFlutterForSession(
                        sessionId,
                        "boardReady",
                        mapOf("sceneReadyToken" to readyToken),
                    )
            }
        }
    }

    @UsedByGodot
    fun stateApplied(
        gameSessionId: String,
        stateGeneration: Long,
        boardId: String,
    ) {
        val nativeSessionId =
            synchronized(this) {
                val applied = GodotBoardStateToken(
                    sessionId = gameSessionId,
                    stateGeneration = stateGeneration,
                    boardId = boardId,
                )
                if (applied != latestStateToken) return
                attachedSessionId
            } ?: return
        activity.notifyFlutterForSession(
            nativeSessionId,
            "stateApplied",
            mapOf(
                "sessionId" to gameSessionId,
                "stateGeneration" to stateGeneration,
                "boardId" to boardId,
            ),
        )
    }

    @UsedByGodot
    fun movementComplete(
        commandId: String,
        playerId: String,
        logicalPosition: Long,
        visualPosition: Long,
    ) {
        val sessionId =
            synchronized(this) {
                val commandSession = commandSessions.remove(commandId)
                commandSession?.takeIf { it == attachedSessionId }
            } ?: return
        activity.notifyFlutterForSession(
            sessionId,
            "movementComplete",
            mapOf(
                "commandId" to commandId,
                "playerId" to playerId,
                "logicalPosition" to logicalPosition,
                "visualPosition" to visualPosition,
            ),
        )
    }

    @UsedByGodot
    fun movementStep(
        commandId: String,
        playerId: String,
        stepIndex: Long,
        totalSteps: Long,
    ) {
        // Progress events peek instead of consume: the command still owes its
        // movementComplete, and stale or retired sessions stay silent.
        val sessionId =
            synchronized(this) {
                val commandSession = commandSessions.peekSession(commandId)
                commandSession?.takeIf { it == attachedSessionId }
            } ?: return
        activity.notifyFlutterForSession(
            sessionId,
            "movementStep",
            mapOf(
                "commandId" to commandId,
                "playerId" to playerId,
                "stepIndex" to stepIndex,
                "totalSteps" to totalSteps,
            ),
        )
    }

    @UsedByGodot
    fun boardObjectTapped(
        kind: String,
        logicalIndex: Long,
        visualIndex: Long,
        playerIndex: Long,
        playerId: String,
        title: String,
    ) {
        val sessionId = synchronized(this) { attachedSessionId } ?: return
        activity.notifyFlutterForSession(
            sessionId,
            "boardObjectTapped",
            mapOf(
                "kind" to kind,
                "logicalIndex" to logicalIndex.takeIf { it >= 0 },
                "visualIndex" to visualIndex.takeIf { it >= 0 },
                "playerIndex" to playerIndex.takeIf { it >= 0 },
                "playerId" to playerId.ifEmpty { null },
                "title" to title.ifEmpty { null },
            ),
        )
    }
}

internal enum class GodotBoardReadyDispatchAction {
    SYNC_CACHED_STATE,
    FLUSH_QUEUED_ROLLS,
    NOTIFY_FLUTTER,
}

/**
 * Native owns delivery of the one cached scene generation at readiness.
 * Flutter treats boardReady as a readiness fact and must not echo the same
 * generation back through syncState.
 */
internal fun godotBoardReadyDispatchActions(
    hasCachedState: Boolean,
): List<GodotBoardReadyDispatchAction> =
    if (hasCachedState) {
        listOf(
            GodotBoardReadyDispatchAction.SYNC_CACHED_STATE,
            GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
            GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
        )
    } else {
        listOf(
            GodotBoardReadyDispatchAction.FLUSH_QUEUED_ROLLS,
            GodotBoardReadyDispatchAction.NOTIFY_FLUTTER,
        )
    }

internal data class GodotBoardStateToken(
    val sessionId: String,
    val stateGeneration: Long,
    val boardId: String,
) {
    companion object {
        fun fromJson(json: String): GodotBoardStateToken? =
            runCatching {
                val payload = JSONObject(json)
                fromValues(
                    sessionId = payload.optString("sessionId"),
                    stateGeneration = payload.optLong("stateGeneration", -1L),
                    boardId = payload.optString("boardId"),
                )
            }.getOrNull()

        fun fromValues(
            sessionId: String?,
            stateGeneration: Long?,
            boardId: String?,
        ): GodotBoardStateToken? {
            if (sessionId.isNullOrBlank() ||
                stateGeneration == null ||
                stateGeneration < 0L ||
                boardId.isNullOrBlank()
            ) {
                return null
            }
            return GodotBoardStateToken(sessionId, stateGeneration, boardId)
        }
    }
}
