import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Render-quality tier for the 3D board (3D-21).
///
/// The tier is persisted and re-sent to the native scene every time a board
/// becomes ready. "high" matches the shipped renderer baseline; the device
/// profiling gate may promote "auto" later once Instruments thresholds exist.
enum GraphicsQuality { high, medium, low }

GraphicsQuality graphicsQualityFromString(String value) {
  for (final quality in GraphicsQuality.values) {
    if (quality.name == value) return quality;
  }
  return GraphicsQuality.high;
}

class GraphicsQualityService {
  GraphicsQualityService();

  static final GraphicsQualityService instance = GraphicsQualityService();

  static const _prefsKey = 'graphics_quality';

  GraphicsQuality _quality = GraphicsQuality.high;
  bool _initialized = false;

  GraphicsQuality get quality => _quality;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _quality = graphicsQualityFromString(
        prefs.getString(_prefsKey) ?? GraphicsQuality.high.name,
      );
      _initialized = true;
    } on Exception {
      // Default tier remains; the setter can still persist later.
      if (!kReleaseMode) {
        debugPrint('GraphicsQualityService init fell back to defaults.');
      }
    }
  }

  Future<void> setQuality(GraphicsQuality quality) async {
    _quality = quality;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, quality.name);
    } on Exception {
      // In-memory tier still applies for this session.
    }
  }
}
