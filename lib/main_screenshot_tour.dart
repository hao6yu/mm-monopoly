// Dedicated entrypoint for the temporary screenshot-tour QA harness. Launch it
// explicitly with `flutter run -t lib/main_screenshot_tour.dart` (or a build
// targeting it) during device screenshot passes.
//
// Store builds compile from lib/main.dart, which never references this file or
// lib/qa_screenshot_tour.dart, so the harness cannot ship in release artifacts.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'qa_screenshot_tour.dart';
import 'services/audio_service.dart';
import 'services/graphics_quality_service.dart';
import 'services/locale_service.dart';
import 'services/save_service.dart';
import 'services/unlock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Match the store entrypoint's window setup so captured frames reflect the
  // real presentation.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await AudioService.instance.init();
  await UnlockService().init();
  await SaveService.instance.init();
  await LocaleService.instance.init();
  await GraphicsQualityService.instance.init();

  // Skip notification init so no system permission dialog covers the screens
  // being captured.
  runApp(const QaScreenshotTourApp());
}
