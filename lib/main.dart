import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'qa_autoplay.dart';
import 'services/audio_service.dart';
import 'services/unlock_service.dart';
import 'services/save_service.dart';
import 'services/notification_service.dart';
import 'services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEMPORARY QA HARNESS (uncommitted): an all-AI session driven by the
  // physical-device automation pass. Enabled only by an explicit build-time
  // define; never part of a release build.
  const qaAutoplay = bool.fromEnvironment('PT_QA_AUTOPLAY');

  // Allow all orientations - layout adapts responsively
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize services
  await AudioService.instance.init();
  await UnlockService().init();
  await SaveService.instance.init();
  await LocaleService.instance.init();

  runApp(qaAutoplay ? const QaAutoplayApp() : const MonopolyApp());

  // Notifications are optional and must not delay or prevent the game UI from
  // opening when permission is denied or a simulator service is unavailable.
  // The QA harness skips this so no system dialog covers the board.
  if (!qaAutoplay) {
    unawaited(NotificationService.instance.init());
  }
}
