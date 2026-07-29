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

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func makeGodotView(frame: CGRect) -> UIView {
    let godotView = UIGodotAppView(frame: frame)
    godotView.backgroundColor = UIColor(red: 0.027, green: 0.067, blue: 0.15, alpha: 1)
    godotView.contentScaleFactor = UIScreen.main.scale
    godotView.isMultipleTouchEnabled = true
    godotView.app = godotApp
    godotView.onReady = { [weak self] handle in
      guard let self else { return }
      self.viewHandle = handle
      if self.boardReady, let json = self.latestStateJSON {
        self.sendToGodot(action: "sync_state", json: json)
      }
    }
    godotView.onMessage = { [weak self] message in
      self?.handleGodotMessage(message)
    }

    _ = godotApp.start()
    godotView.startGodotInstance()
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
      boardReady = true
      channel.invokeMethod("boardReady", arguments: nil)
      if let json = latestStateJSON {
        sendToGodot(action: "sync_state", json: json)
      }
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
