import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/integration/godot_board_contract.dart';
import 'package:property_tycoon/integration/godot_board_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('property_tycoon/godot_board_bridge');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('rejected native movement falls back without waiting for timeout', () {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'animateRoll');
          return false;
        });
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    final movement = controller.animateRoll(
      const GodotRollCommand(
        sessionId: 'game_1',
        commandId: '1_player_0',
        playerId: 'player_0',
        playerIndex: 0,
        die1: 3,
        die2: 2,
        fromLogicalPosition: 0,
        toLogicalPosition: 5,
        logicalTileCount: 40,
        visualSpotCount: 52,
        visualPath: [1, 3, 4, 5, 7],
      ),
    );

    expect(
      movement,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('rejected'),
        ),
      ),
    );
  });
}
