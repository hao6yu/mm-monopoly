import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:property_tycoon/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android notification denial skips scheduling without blocking startup',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      SharedPreferences.setMockInitialValues({});
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'initialize') return true;
            if (call.method == 'requestNotificationsPermission') return false;
            throw StateError('Unexpected call after denial: ${call.method}');
          });
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      await NotificationService.instance.init();
      expect(calls.map((call) => call.method), [
        'initialize',
        'requestNotificationsPermission',
      ]);
      expect((calls.first.arguments as Map)['defaultIcon'], 'ic_notification');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('notifications_last_scheduled'), isNull);
    },
  );
}
