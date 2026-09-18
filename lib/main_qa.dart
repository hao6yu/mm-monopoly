// Dedicated entrypoint for the temporary QA autoplay harness. Launch it
// explicitly with `flutter run -t lib/main_qa.dart` (or the matching build
// target) during physical-device automation passes.
//
// Store builds compile from lib/main.dart, which never references this file
// or lib/qa_autoplay.dart, so the harness cannot be selected by a build-time
// define and cannot ship in a release artifact.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'qa_autoplay.dart';
import 'services/audio_service.dart';
import 'services/unlock_service.dart';
import 'services/save_service.dart';
import 'services/graphics_quality_service.dart';
import 'services/locale_service.dart';

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

  // The QA harness intentionally skips notification init so no system
  // permission dialog covers the board during automated capture.
  runApp(const QaAutoplayApp());
}
