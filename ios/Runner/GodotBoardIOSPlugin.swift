import Flutter
import SwiftGodot
import SwiftGodotKit
import UIKit

/// Hosts the single LibGodot runtime used by the embedded Manhattan board and
/// adapts the existing Flutter JSON method-channel protocol to SwiftGodotKit.
final class GodotBoardIOSPlugin: NSObject, FlutterPlugin {
  static let viewType = "property_tycoon/godot_board"
  static let channelName = "property_tycoon/godot_board_bridge"

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
  private var boardReady = false

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
      if available && boardReady {
        DispatchQueue.main.async { [weak self] in
          self?.channel.invokeMethod("boardReady", arguments: nil)
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
      if boardReady {
        sendToGodot(action: "sync_state", json: json)
      }
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
      guard boardReady, viewHandle != nil else {
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
      guard boardReady, viewHandle != nil else {
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
      guard boardReady, viewHandle != nil else {
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
      scheduleBoardReadyAnnouncements(for: hostedGodotView)
      return hostedGodotView
    }

    let godotView = UIGodotAppView(frame: frame)
    godotView.backgroundColor = UIColor(red: 0.027, green: 0.067, blue: 0.15, alpha: 1)
    godotView.contentScaleFactor = UIScreen.main.scale
    godotView.isMultipleTouchEnabled = true
    godotView.app = godotApp
    godotView.onReady = { [weak self] handle in
      guard let self else { return }
      self.viewHandle = handle
      // SwiftGodot can unregister and re-register the view callbacks while
      // Flutter reparents a platform view. Treat its ready handle as the
      // authoritative readiness signal so Flutter cannot miss boardReady and
      // remain behind its loading overlay even though Godot is rendering.
      self.announceBoardReady()
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
    scheduleBoardReadyAnnouncements(for: godotView)
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

    if method == "boardReady" {
      announceBoardReady()
      return
    }

    let arguments: Any?
    if let data = argumentsJSON.data(using: .utf8) {
      arguments = try? JSONSerialization.jsonObject(with: data)
    } else {
      arguments = nil
    }
    channel.invokeMethod(method, arguments: arguments)
  }

  private func announceBoardReady() {
    boardReady = true
    channel.invokeMethod("boardReady", arguments: nil)
    if let json = latestStateJSON {
      sendToGodot(action: "sync_state", json: json)
    }
  }

  private func scheduleBoardReadyAnnouncements(for godotView: UIGodotAppView) {
    for delay in [0.25, 1.0, 2.5] {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak godotView] in
        guard
          let self,
          let godotView,
          self.hostedGodotView === godotView,
          self.godotApp.instance?.isStarted() == true
        else {
          return
        }
        // Re-announcing is intentional: it retries the cached state after the
        // Godot current scene becomes available and is harmless once synced.
        self.announceBoardReady()
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
