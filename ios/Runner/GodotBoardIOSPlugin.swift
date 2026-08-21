import Flutter
import SwiftGodot
import SwiftGodotKit
import UIKit

/// Hosts the single LibGodot runtime used by the embedded Manhattan board and
/// adapts the existing Flutter JSON method-channel protocol to SwiftGodotKit.
final class GodotBoardIOSPlugin: NSObject, FlutterPlugin {
  static let viewType = "property_tycoon/godot_board"
  static let channelName = "property_tycoon/godot_board_bridge"
  static let godotRenderScaleRatio: CGFloat = 0.75
  static let godotMaximumContentScale: CGFloat = 2.0
  static let godotMaximumFramesPerSecond = 60

  enum SceneReadyDispatchAction: Equatable {
    case notifyFlutter
    case sendCachedState
  }

  /// Ready-time state delivery belongs to the native cache. Flutter records
  /// boardReady but does not echo the same generation back into Godot.
  static func sceneReadyDispatchActions(
    hasCachedState: Bool
  ) -> [SceneReadyDispatchAction] {
    hasCachedState
      ? [.sendCachedState, .notifyFlutter]
      : [.notifyFlutter]
  }

  /// A readiness callback is replayable only when it carries a token created
  /// by the running Godot scene. Engine startup alone does not prove that the
  /// current scene exists or has connected its host bridge.
  static func observedSceneReadyToken(from arguments: Any?) -> String? {
    guard
      let values = arguments as? [String: Any],
      let token = values["sceneReadyToken"] as? String
    else {
      return nil
    }
    let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }

  /// Keeps Flutter and UIKit at native Retina resolution while reducing only
  /// the embedded 3D drawable. A 2x iPad therefore renders Godot at 1.5x; a
  /// 3x iPhone is bounded at 2x to avoid an unnecessarily large Metal surface.
  static func godotContentScale(for nativeScale: CGFloat) -> CGFloat {
    let safeNativeScale =
      nativeScale.isFinite && nativeScale > 0 ? nativeScale : 1.0
    let scaled = safeNativeScale * godotRenderScaleRatio
    return min(
      safeNativeScale,
      max(1.0, min(godotMaximumContentScale, scaled))
    )
  }

  private let channel: FlutterMethodChannel
  private let godotApp = GodotApp(
    packFile: "property_tycoon.pck",
    renderingDriver: "metal",
    renderingMethod: "mobile",
    displayDriver: "embedded"
  )

  private var viewHandle: GodotAppViewHandle?
  // LibGodot supports one engine instance and one active native surface per
  // process. Reuse the same Metal-backed view when Flutter recreates the
  // platform view so the engine never retains a layer from a retired view.
  private var hostedGodotView: UIGodotAppView?
  private var latestStateJSON: String?
  private var sceneReadyToken: String?

  private init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    super.init()
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = GodotBoardIOSPlugin(messenger: registrar.messenger())
    registrar.addMethodCallDelegate(plugin, channel: plugin.channel)
    registrar.register(
      GodotBoardViewFactory(plugin: plugin),
      withId: Self.viewType
    )
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      #if targetEnvironment(simulator)
      result(false)
      return
      #else
      let available =
        Bundle.main.path(forResource: "property_tycoon", ofType: "pck") != nil
      result(available)
      if available, let sceneReadyToken {
        DispatchQueue.main.async { [weak self] in
          self?.replayBoardReady(token: sceneReadyToken)
        }
      }
      #endif

    case "syncState":
      guard let json = call.arguments as? String else {
        result(
          FlutterError(
            code: "invalid_state",
            message: "The Godot board state must be a JSON string.",
            details: nil
          )
        )
        return
      }
      latestStateJSON = json
      if sceneReadyToken != nil, viewHandle != nil {
        sendToGodot(action: "sync_state", json: json)
      }
      result(true)

    case "retryScene":
      guard let sceneReadyToken else {
        result(false)
        return
      }
      dispatchSceneReady(token: sceneReadyToken, includeCachedState: true)
      result(true)

    case "animateRoll":
      guard let json = call.arguments as? String else {
        result(
          FlutterError(
            code: "invalid_roll",
            message: "The Godot roll command must be a JSON string.",
            details: nil
          )
        )
        return
      }
      guard sceneReadyToken != nil, viewHandle != nil else {
        result(false)
        return
      }
      sendToGodot(action: "animate_roll", json: json)
      result(true)

    case "cameraGesture":
      guard let json = call.arguments as? String else {
        result(
          FlutterError(
            code: "invalid_camera_gesture",
            message: "The camera gesture must be a JSON string.",
            details: nil
          )
        )
        return
      }
      guard sceneReadyToken != nil, viewHandle != nil else {
        result(false)
        return
      }
      sendToGodot(action: "camera_gesture", json: json)
      result(true)

    case "pickBoardObject":
      guard let json = call.arguments as? String else {
        result(
          FlutterError(
            code: "invalid_board_pick",
            message: "The board pick must be a JSON string.",
            details: nil
          )
        )
        return
      }
      guard sceneReadyToken != nil, viewHandle != nil else {
        result(false)
        return
      }
      sendToGodot(action: "board_tap", json: json)
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func makeGodotView(frame: CGRect) -> UIView {
    if let hostedGodotView {
      hostedGodotView.removeFromSuperview()
      hostedGodotView.frame = frame
      return hostedGodotView
    }

    let godotView = UIGodotAppView(frame: frame)
    godotView.backgroundColor = UIColor(red: 0.027, green: 0.067, blue: 0.15, alpha: 1)
    godotView.contentScaleFactor = Self.godotContentScale(
      for: UIScreen.main.scale
    )
    godotView.maximumFramesPerSecond = Self.godotMaximumFramesPerSecond
    godotView.isMultipleTouchEnabled = true
    godotView.app = godotApp
    godotView.onReady = { [weak self] handle in
      guard let self else { return }
      self.viewHandle = handle
      // SwiftGodot's view handle proves only that the engine/window exists.
      // Reparenting may replay a readiness token, but only after GDScript has
      // emitted that token from its connected scene.
      if let token = self.sceneReadyToken {
        self.replayBoardReady(token: token)
      }
    }
    godotView.onMessage = { [weak self] message in
      self?.handleGodotMessage(message)
    }

    hostedGodotView = godotView
    // Keep a usable unrouted handle even if SwiftGodot's view callback is
    // briefly unregistered while Flutter reparents the UIKit platform view.
    // The registered onReady callback replaces this handle when available.
    viewHandle = GodotAppViewHandle(app: godotApp)
    _ = godotApp.start()
    return godotView
  }

  private func sendToGodot(action: String, json: String) {
    guard let viewHandle else { return }
    let message = VariantDictionary()
    message["action"] = Variant(action)
    message["json"] = Variant(json)
    viewHandle.emitMessage(message)
  }

  private func handleGodotMessage(_ message: VariantDictionary) {
    guard let method = String(message["method"]), !method.isEmpty else {
      return
    }
    let argumentsJSON = String(message["arguments"]) ?? "{}"
    let arguments: Any?
    if let data = argumentsJSON.data(using: .utf8) {
      arguments = try? JSONSerialization.jsonObject(with: data)
    } else {
      arguments = nil
    }

    if method == "boardReady" {
      guard let token = Self.observedSceneReadyToken(from: arguments) else {
        return
      }
      sceneReadyToken = token
      dispatchSceneReady(token: token, includeCachedState: true)
      return
    }

    channel.invokeMethod(method, arguments: arguments)
  }

  private func replayBoardReady(token: String) {
    channel.invokeMethod(
      "boardReady",
      arguments: ["sceneReadyToken": token]
    )
  }

  private func dispatchSceneReady(
    token: String,
    includeCachedState: Bool
  ) {
    let cachedState = includeCachedState ? latestStateJSON : nil
    for action in Self.sceneReadyDispatchActions(
      hasCachedState: cachedState != nil
    ) {
      switch action {
      case .notifyFlutter:
        replayBoardReady(token: token)
      case .sendCachedState:
        if let cachedState {
          sendToGodot(action: "sync_state", json: cachedState)
        }
      }
    }
  }
}

private final class GodotBoardViewFactory: NSObject, FlutterPlatformViewFactory {
  private let plugin: GodotBoardIOSPlugin

  init(plugin: GodotBoardIOSPlugin) {
    self.plugin = plugin
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    GodotBoardPlatformView(nativeView: plugin.makeGodotView(frame: frame))
  }
}

private final class GodotBoardPlatformView: NSObject, FlutterPlatformView {
  private let nativeView: UIView

  init(nativeView: UIView) {
    self.nativeView = nativeView
    super.init()
  }

  func view() -> UIView {
    nativeView
  }
}
