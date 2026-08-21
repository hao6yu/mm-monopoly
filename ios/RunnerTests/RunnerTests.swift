import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

  func testGodotContentScaleReducesOnlyTheEmbeddedDrawable() {
    XCTAssertEqual(
      GodotBoardIOSPlugin.godotContentScale(for: 1.0),
      1.0,
      accuracy: 0.001
    )
    XCTAssertEqual(
      GodotBoardIOSPlugin.godotContentScale(for: 2.0),
      1.5,
      accuracy: 0.001
    )
    XCTAssertEqual(
      GodotBoardIOSPlugin.godotContentScale(for: 3.0),
      2.0,
      accuracy: 0.001
    )
  }

  func testGodotFrameRateIsCappedForProMotionDevices() {
    XCTAssertEqual(GodotBoardIOSPlugin.godotMaximumFramesPerSecond, 60)
  }

  func testSceneReadinessRequiresAnObservedGodotToken() {
    XCTAssertNil(GodotBoardIOSPlugin.observedSceneReadyToken(from: nil))
    XCTAssertNil(
      GodotBoardIOSPlugin.observedSceneReadyToken(
        from: ["sceneReadyToken": "   "]
      )
    )
    XCTAssertEqual(
      GodotBoardIOSPlugin.observedSceneReadyToken(
        from: ["sceneReadyToken": " scene-42 "]
      ),
      "scene-42"
    )
  }

  func testSceneReadyDispatchSendsOneCachedStateBeforeNotification() {
    XCTAssertEqual(
      GodotBoardIOSPlugin.sceneReadyDispatchActions(hasCachedState: true),
      [.sendCachedState, .notifyFlutter]
    )
    XCTAssertEqual(
      GodotBoardIOSPlugin.sceneReadyDispatchActions(hasCachedState: false),
      [.notifyFlutter]
    )
  }

}
