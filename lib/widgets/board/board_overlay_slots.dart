import 'package:flutter/widgets.dart';

/// Named overlay slots for the board experience (UI-03).
///
/// One source of truth for where board chrome may sit in each responsive
/// mode, so independent overlays can never collide with each other or cover
/// the gameplay-critical bottom band (roll control, dice platform, active
/// pawn, and destination beacon). The left edge serializes one column:
/// gesture hint at the base, active-event indicators above it, and the
/// action-critical card-deck prompt above those. The right edge stays
/// reserved for the roll control at all times.
@immutable
class BoardOverlaySlots {
  const BoardOverlaySlots({
    required this.isCompactLandscape,
    required this.showsGestureHint,
    required this.hasVisibleEvents,
    required this.hasCardPrompt,
    required this.visibleEventCount,
    required this.hiddenEventCount,
  });

  /// Wide enough for the gesture hint and full roll control; below this the
  /// experience switches to its compact variants.
  static const double compact3DBreakpoint = 700;

  /// Height under which the board is treated as compact landscape and
  /// overlays tighten their spacing.
  static const double compactLandscapeHeight = 500;

  static const double _edgeMargin = 12;
  static const double _gestureHintHeight = 34;
  static const double _eventIndicatorHeight = 40;
  static const double _eventStackGap = 4;
  static const double _cardPromptHeight = 72;

  /// At most two event indicators render inline; older ones collapse into a
  /// summary chip so the column can never grow into the card-prompt slot.
  static const int maxInlineEventIndicators = 2;

  factory BoardOverlaySlots.fromConstraints({
    required Size size,
    required bool showsGestureHint,
    required int visibleEventCount,
    required bool hasCardPrompt,
  }) {
    final inlineEvents = visibleEventCount.clamp(
      0,
      maxInlineEventIndicators,
    );
    final hiddenEvents = visibleEventCount - inlineEvents;
    return BoardOverlaySlots(
      isCompactLandscape: size.height < compactLandscapeHeight,
      showsGestureHint: showsGestureHint,
      hasVisibleEvents: visibleEventCount > 0,
      hasCardPrompt: hasCardPrompt,
      visibleEventCount: inlineEvents,
      hiddenEventCount: hiddenEvents,
    );
  }

  final bool isCompactLandscape;
  final bool showsGestureHint;
  final bool hasVisibleEvents;
  final bool hasCardPrompt;

  /// Inline event indicators after serialization; the rest collapse into a
  /// summary chip counted by [hiddenEventCount].
  final int visibleEventCount;
  final int hiddenEventCount;

  double get _baseMargin => isCompactLandscape ? 8 : _edgeMargin;

  /// Gesture hint sits at the base of the left column when the viewport is
  /// wide enough to show it at all.
  double get gestureHintBottom => showsGestureHint ? _baseMargin : 0;

  double get gestureHintHeight => showsGestureHint ? _gestureHintHeight : 0;

  double get _leftColumnTop =>
      gestureHintBottom +
      gestureHintHeight +
      (gestureHintHeight > 0 ? _eventStackGap : 0);

  /// Bottom inset of the serialized event-indicator stack.
  double get eventStackBottom => _leftColumnTop;

  double get eventStackHeight =>
      visibleEventCount * (_eventIndicatorHeight + _eventStackGap) +
      (hiddenEventCount > 0 ? _eventIndicatorHeight * 0.6 : 0);

  /// Bottom inset of the action-critical card-deck prompt: always above the
  /// event stack and the gesture hint, never overlapping either.
  double get cardPromptBottom {
    var bottom = _leftColumnTop;
    if (hasVisibleEvents) {
      bottom += eventStackHeight + _eventStackGap;
    }
    if (hasCardPrompt && bottom < _cardPromptHeight + _baseMargin) {
      bottom = _cardPromptHeight + _baseMargin;
    }
    return bottom;
  }

  /// Bottom inset of the roll control; the reserved bottom band never hosts
  /// any other overlay.
  double get rollControlBottom => _baseMargin;

  double get actionBarTop => _baseMargin;

  double get statusRailTop => _baseMargin + 52;

  /// Splits an ordered event list into the inline tail (most recent first in
  /// render order) and the older overflow that collapses into the summary
  /// chip. Keeps the bottom-left column bounded in every responsive mode.
  List<T> serializeEvents<T>(List<T> events) {
    if (events.length <= maxInlineEventIndicators) return events;
    return events.sublist(events.length - maxInlineEventIndicators);
  }
}
