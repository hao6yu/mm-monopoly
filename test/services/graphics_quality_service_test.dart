import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/services/graphics_quality_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GraphicsQualityService (3D-21)', () {
    test('defaults to the shipped high baseline', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GraphicsQualityService();
      await service.init();

      expect(service.quality, GraphicsQuality.high);
    });

    test('persists the chosen tier across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final service = GraphicsQualityService();
      await service.init();
      await service.setQuality(GraphicsQuality.low);
      expect(service.quality, GraphicsQuality.low);

      final reloaded = GraphicsQualityService();
      await reloaded.init();
      expect(reloaded.quality, GraphicsQuality.low);
    });

    test('unknown persisted values fall back to high', () async {
      SharedPreferences.setMockInitialValues({'graphics_quality': 'ultra'});
      final service = GraphicsQualityService();
      await service.init();

      expect(service.quality, GraphicsQuality.high);
    });
  });
}
