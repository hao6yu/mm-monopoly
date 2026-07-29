import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/audio_service.dart';
import 'services/unlock_service.dart';
import 'services/save_service.dart';
import 'services/notification_service.dart';
import 'services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow all orientations - layout adapts responsively
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize services
  await AudioService.instance.init();
  await UnlockService().init();
  await SaveService.instance.init();
  await LocaleService.instance.init();

  runApp(const MonopolyApp());

  // Notifications are optional and must not delay or prevent the game UI from
  // opening when permission is denied or a simulator service is unavailable.
  unawaited(NotificationService.instance.init());
}
