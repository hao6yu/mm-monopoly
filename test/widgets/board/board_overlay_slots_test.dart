import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/widgets/board/board_overlay_slots.dart';

void main() {
  group('BoardOverlaySlots serialization', () {
    test('keeps every event inline when the stack is short', () {
      final slots = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 2,
        hasCardPrompt: false,
      );

      expect(slots.visibleEventCount, 2);
      expect(slots.hiddenEventCount, 0);
      expect(
        slots.serializeEvents(['a', 'b']),
        orderedEquals(['a', 'b']),
      );
    });

    test('caps inline events and counts the overflow', () {
      final slots = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 5,
        hasCardPrompt: false,
      );

      expect(slots.visibleEventCount, BoardOverlaySlots.maxInlineEventIndicators);
      expect(slots.hiddenEventCount, 3);
      expect(
        slots.serializeEvents(['oldest', 'old', 'mid', 'new', 'newest']),
        orderedEquals(['new', 'newest']),
        reason: 'the most recent events stay inline',
      );
    });
  });

  group('BoardOverlaySlots left-column serialization', () {
    test('event stack sits above the gesture hint in wide 3D', () {
      final slots = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 2,
        hasCardPrompt: false,
      );

      expect(
        slots.eventStackBottom,
        greaterThanOrEqualTo(
          slots.gestureHintBottom + slots.gestureHintHeight,
        ),
        reason: 'badges must never cover the gesture hint pill',
      );
    });

    test('event stack uses the plain edge when no hint is shown', () {
      final slots = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: false,
        visibleEventCount: 2,
        hasCardPrompt: false,
      );

      expect(slots.gestureHintHeight, 0);
      expect(slots.eventStackBottom, lessThan(20));
    });

    test('card prompt serializes above events and hint', () {
      final withEvents = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 2,
        hasCardPrompt: true,
      );
      final withoutEvents = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 0,
        hasCardPrompt: true,
      );

      expect(
        withEvents.cardPromptBottom,
        greaterThanOrEqualTo(
          withEvents.eventStackBottom +
              withEvents.eventStackHeight +
              withEvents.eventStackBottom * 0,
        ),
        reason: 'the action-critical prompt never hides behind event badges',
      );
      expect(
        withoutEvents.cardPromptBottom,
        lessThan(withEvents.cardPromptBottom),
        reason: 'a busy event stack pushes the prompt higher',
      );
    });

    test('compact landscape tightens margins but keeps serialization', () {
      final compact = BoardOverlaySlots.fromConstraints(
        size: const Size(700, 400),
        showsGestureHint: false,
        visibleEventCount: 2,
        hasCardPrompt: true,
      );
      final roomy = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: false,
        visibleEventCount: 2,
        hasCardPrompt: true,
      );

      expect(compact.isCompactLandscape, isTrue);
      expect(
        compact.actionBarTop,
        lessThan(roomy.actionBarTop),
        reason: 'compact layouts tighten edge margins instead of overflowing',
      );
      // The serialized prompt position is height-driven, so both modes place
      // it above the same event stack height.
      expect(compact.cardPromptBottom, roomy.cardPromptBottom);
    });

    test('left column serializes above its own base in every mode', () {
      for (final showsGestureHint in [true, false]) {
        final slots = BoardOverlaySlots.fromConstraints(
          size: const Size(1000, 800),
          showsGestureHint: showsGestureHint,
          visibleEventCount: 2,
          hasCardPrompt: false,
        );
        expect(
          slots.eventStackBottom,
          greaterThanOrEqualTo(
            slots.gestureHintBottom + slots.gestureHintHeight,
          ),
          reason: 'the left column never dips behind the gesture hint',
        );
        expect(
          slots.cardPromptBottom,
          greaterThanOrEqualTo(slots.eventStackBottom),
          reason: 'the card prompt never sinks behind event badges',
        );
      }
    });
  });

  group('BoardOverlaySlots widget rendering', () {
    testWidgets('overflow chip appears for serialized-out events', (
      tester,
    ) async {
      final slots = BoardOverlaySlots.fromConstraints(
        size: const Size(1000, 800),
        showsGestureHint: true,
        visibleEventCount: 4,
        hasCardPrompt: false,
      );
      final events = ['one', 'two', 'three', 'four'];
      final inline = slots.serializeEvents(events);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    bottom: slots.eventStackBottom,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (slots.hiddenEventCount > 0)
                          Text('+${slots.hiddenEventCount}'),
                        ...inline.map(Text.new),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('+2'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
      expect(find.text('four'), findsOneWidget);
      expect(find.text('one'), findsNothing);
      expect(find.text('two'), findsNothing);
    });
  });
}
