# Store release review — September 17, 2026

Reviewed `main` at `1fd7371` (app `2.0.1+12`), including the local AI's September follow-up commits. **Decision: hold public store release.** The recent work improves the game, but the current Android release does not compile, card-movement integration bypasses the new animations, and store-submission requirements remain unresolved.

> **Remediation addendum:** the integration and submission blockers R1–R5 were fixed and re-verified after this review. See [Remediation status](#remediation-status--september-17-2026) at the end of this document. The original findings below are retained unchanged for the record; device-acceptance evidence remains outstanding.

This is a review, not a remediation pass. No application code was changed or installed on a device. Existing September iPad screenshots were inspected; they are historical QA evidence, not a fresh physical-device test of this checkout. Store-console configuration, distribution credentials, and submitted metadata were not inspected.

## Fresh verification

| Check | Result |
|---|---|
| `flutter test --reporter expanded` | **153/153 passed.** |
| `flutter analyze --no-pub --no-fatal-infos` | **Passed; 0 errors, 0 warnings, 239 informational diagnostics.** An initial concurrent dependency-generation attempt failed on an ephemeral iOS directory; the subsequent no-pub analysis completed. |
| Godot 4.6.3 headless `bridge_smoke.gd` | **Passed**, including special movement, camera, quality-tier, occupancy, dice, and 18-city checks; an ObjectDB leak warning appeared at process shutdown. |
| `flutter build appbundle --release --no-pub` | **Failed** in `:app:compileReleaseKotlin`, at `MainActivity.kt:123,138,142`. |
| `flutter build ios --release --no-codesign --no-pub` | **Passed** in approximately 191 seconds; `Runner.app` reported as 160.6 MB. This is an unsigned device build, not a validated distribution archive or a fresh device run. |
| Android release signing | No local `android/key.properties`; this checkout is configured to produce unsigned artifacts when it is absent. Signing could exist elsewhere, but was not demonstrated here. |
| Device/performance evidence | September iPad screenshots show all-AI play into rounds 23–24 and portrait/landscape captures. No new performance trace or complete cross-device acceptance record was found with them. |

The Android and iOS PCKs currently have the same SHA-256: `a1962b457d5c009b5e233fc4a4b91855bd71895861fd6eebcda0ce4672a72db7`. This is an artifact identity check, not proof of exporter/runtime compatibility or source freshness. The fresh smoke used the local 4.6.3 editor; it did not exercise the Android plugin or the vendor iOS engine.

## Confirmed release findings

### R1 — P0: Android store artifact cannot compile

`android/app/src/main/kotlin/com/hyu/properotyTycoon/MainActivity.kt:114–145` nests the `"setGraphicsQuality" ->` branch inside `"setCameraFollow"` and leaves its `else` at the wrong level. A real release App Bundle build reproduces the syntax errors and nullable-string mismatch. Flutter analysis and Dart tests cannot catch Kotlin errors.

Required before Android release: restore separate method-handler branches and successfully build the signed release AAB. Add a native compile check to the verification workflow.

### R2 — P1: Android graphics quality has no connected receiver

The Android plugin registers/emits `graphics_quality` (`MainActivity.kt:307,404–410`), but `godot_3d/scripts/main.gd:4386–4400` connects every neighboring bridge signal except that one. The iOS `host_receive_message` path does dispatch it, which explains why the direct/headless quality tests pass. Even after fixing R1, Android users selecting Low/Medium would not get the requested render budget.

Required: connect and verify the actual Android signal path, then measure the tier on hardware. A test that calls the GDScript handler directly does not cover this failure.

### R3 — P1: Card movement bypasses the new animation integration

`lib/screens/game_board_screen.dart:3484–3493` mutates the position and immediately starts `_sync3DBoard()` before returning the movement result. The controller synchronously creates a new state generation (`lib/integration/godot_board_controller.dart:269–286`), making `isBoardReady` false until acknowledgement. The following special-move call is then rejected by its readiness guard (`game_board_screen.dart:427`), and falls back to another sync. In the AI path this happens in the same synchronous call chain. In the human path the first sync has already sent the destination, so an acknowledgement arriving early still cannot preserve an untouched movement start.

Additionally, `_applyCardEffect` returns a destination only when `resolveLanding` is true. `advanceGo` and `goToJail` deliberately return a destination with `resolveLanding=false` (`lib/engine/card_effect_engine.dart:149–159`), so both skip special animation entirely. Movement and landing-resolution decisions need to remain separate.

Required: orchestrate mutation/presentation/state sync in the correct order and test real card selection through the board screen for forward/backward/nearest/GO/jail. The new movement contract and headless animations are useful, but their isolated tests do not establish that gameplay invokes them.

### R4 — P1: Missing accessible privacy policy; excessive Android permissions

No privacy-policy URL or in-app privacy entry was found in `lib` or the localized app content. Settings exposes a support/donation link, but no privacy policy. Apple requires an accessible policy link both in the app and in App Store Connect. Metadata outside the repository remains unverified. See [Apple guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#privacy).

The Android manifest still declares `USE_EXACT_ALARM` and `SCHEDULE_EXACT_ALARM` (`android/app/src/main/AndroidManifest.xml:14–15`), although notification scheduling uses `inexactAllowWhileIdle` (`lib/services/notification_service.dart:325`). Google's restricted exact-alarm permission is for qualifying core alarm/calendar functionality, not optional game reminders. See [Google Play exact-alarm policy](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en).

The manifest also declares `READ_MEDIA_IMAGES` for optional avatar selection (`AndroidManifest.xml:9`). Review this against the system-photo-picker alternative; infrequent avatar selection does not establish a need for broad library access. See [Google Play photo-permission guidance](https://support.google.com/googleplay/android-developer/answer/16935362?hl=en).

Required: publish/link the accurate policy, verify store privacy declarations, remove unnecessary permissions, and test denied-permission flows. Also justify/remove the existing iOS fetch/remote-notification background modes for this local-notification app.

### R5 — P2: QA autoplay is not excluded from release builds

`lib/main.dart:17–33` says the temporary harness is uncommitted and never part of release builds, but it is committed and selected solely by `bool.fromEnvironment('PT_QA_AUTOPLAY')`. There is no release-mode guard. A release built with that define launches four AI players, bypasses normal setup, displays a QA banner, and performs synthetic mute-button taps. The default build does not enable it; this is a release-process hazard, not a claim that every build launches QA mode.

Required: use a separate QA entrypoint or enforce its exclusion from store builds, and inspect the final archived artifact's launch behavior.

## Evidence still needed before approval

- **Sustained hardware performance.** Quality tiers are implemented, but High remains the default. The old M1 iPad measurements cannot establish performance of the latest framing/tier changes. Record 30–60 minutes of frame time, memory, thermals, and battery on the minimum supported iPhone/iPad and physical Android hardware.
- **Full user workflows.** All-AI screenshots are useful soak evidence, but do not cover human card selection, purchase/auction decisions, save/load, background/resume, second-session reattachment, bankruptcy, and victory/replay. The app lifecycle handler currently pauses audio only (`lib/app.dart:133–141`); turn/mini-game interruption needs explicit acceptance coverage.
- **Final store artifacts.** Build/sign/validate the Android AAB and iOS archive using an accepted release toolchain. The local Xcode is `27.0 / 27A5194q`; unsigned compilation alone is not App Store validation. Confirm upload build numbers and console metadata. No repository CI configuration was found.
- **Phone UI and accessibility.** The inspected September landscape capture crops part of the near route and places the top rail over far-side content; portrait still spends substantial area above the board. These captures may predate the final framing commit. Check the final build's overview/reset and active-pawn visibility on phones, safe areas, large text, and screen readers.
- **Localization and asset provenance.** Event and power-up surfaces still use English model strings, and event duration manually appends an English `s`. `assets/audio/MUSIC_LICENSES.md` records four tracks, while ten music files are bundled; establish the other six tracks' provenance before distribution. This is missing evidence, not a conclusion that those tracks are unlicensed.

## Recommended decision

Continue internal iOS testing, resolve R1–R4 before store submission, and close R5 while preparing reproducible release artifacts. Reassess after the real card workflows, final phone layouts, and sustained device measurements pass. The prior readiness document contains useful history but mixes August metadata with later follow-ups and should not be treated as a current release sign-off.

## Remediation status — September 17, 2026

All five blockers were fixed in this checkout and re-verified with automated checks. **This is still not a store sign-off:** sustained hardware runs, full human decision workflows, final signed artifacts, and phone-UI/accessibility acceptance (the evidence list above) remain outstanding.

### R1 — Android release compile: fixed

`MainActivity.kt` restored `"setCameraFollow"` and `"setGraphicsQuality"` as separate, parallel method branches (each with its own error/success path, matching the `cameraGesture`/`pickBoardObject` pattern).

Evidence: `flutter build appbundle --release --no-pub` now completes — `✓ Built build/app/outputs/bundle/release/app-release.aab (162.4MB)`. (Gradle 8.12/AGP 8.9.1/Kotlin 2.1 deprecation warnings are pre-existing.)

### R2 — Android graphics-quality receiver: fixed

`main.gd` now connects the `graphics_quality` signal, and the signal→handler mapping was extracted into `_flutter_bridge_signal_handlers()` so the wiring is a checkable contract instead of a hidden connect list. `bridge_smoke.gd` gained `_test_flutter_bridge_signal_contract`, which asserts every Android plugin signal (including `graphics_quality` → `_apply_graphics_quality_json`) is mapped to a valid scene method.

Evidence: headless smoke on the local editor (now 4.7.2 — the 4.6.3 editor used at review time is no longer installed) reports `FLUTTER_BRIDGE_SIGNAL_CONTRACT_OK` and full `BRIDGE_SMOKE_OK`. A real-hardware tier measurement is still pending.

### R3 — Card movement animation: fixed

`_applyCardEffect` no longer fires a state sync, which was bumping the board generation and failing the animation readiness guard before any presentation could start. It now returns a `_CardMoveOutcome` for every relocating card — including `advanceGo` and `goToJail`, whose engine results carry `resolveLanding=false` — and the awaiting turn flow presents the movement (teleport/jail/walk/reverse per `GodotMovementPresentation.forCardAction`) **before** the authoritative sync, resolving the destination only when `resolveLanding` is true. The jail-dice and teleport-prize callers own their fallback sync via the helper's new `Future<bool>` contract. A test seam (`drawCardForTesting` / `handlePickedCardForTesting` on the now-public `GameBoardScreenState`) drives the real flow.

New coverage (9 tests, suite now 162/162): board-screen card selection for amount, forward-across-GO, backward, nearest-railroad (owned), Advance to GO, and Go To Jail; card-pick dialog tap→flip→callback; and a controller-ordering test asserting `animateRoll` is accepted on a ready board and completes before the post-move `syncState`.

### R4 — Privacy and permissions: fixed in-repo (store console still pending)

- Android: removed `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` (scheduling uses `inexactAllowWhileIdle`), and removed `READ_MEDIA_IMAGES`/`READ_EXTERNAL_STORAGE` (avatar selection goes through the system photo picker / SAF gallery intent; `CAMERA` retained for optional avatar photos).
- iOS: removed the `UIBackgroundModes` (`fetch`, `remote-notification`) block — this is a local-notification app.
- New localized in-app privacy policy: `lib/screens/privacy_policy_screen.dart`, opened from a new Settings entry, with strings added to all five ARB catalogs (en/es/fr/ja/zh) and regenerated localizations.

Still required outside this repository: publish/host the policy at a URL for App Store Connect and Google Play, verify the store privacy declarations match this content, and exercise denied-permission flows on hardware. The policy's contact section deliberately points to the Settings support link and store listing; replace with a direct contact if one becomes available.

### R5 — QA autoplay exclusion: fixed

The QA harness moved behind a dedicated entrypoint (`lib/main_qa.dart`, run via `flutter run -t lib/main_qa.dart`). The store entrypoint (`lib/main.dart`) no longer references `qa_autoplay.dart` or reads any build define, so no define combination can launch QA mode in a store build. Final archived-artifact launch inspection remains a release-process step.

### Re-verification after remediation

| Check | Result |
|---|---|
| `flutter analyze --no-pub --no-fatal-infos` | **0 errors, 0 warnings**, 239 informational diagnostics (unchanged baseline). |
| `flutter test` | **162/162 passed** (153 prior + 9 new). |
| `flutter build appbundle --release --no-pub` | **Passed** — `app-release.aab (162.4MB)`, after re-exporting the Android PCK. |
| `flutter build ios --release --no-codesign --no-pub` | **Passed** — `Runner.app (160.6MB)`, after removing the iOS background modes. Unsigned build, not a distribution archive. |
| Godot headless `bridge_smoke.gd` | **Passed** on Godot 4.7.2, including the new signal-contract check. |
| Android PCK | Re-exported with the installed Godot 4.7.2 (`tool/export_godot_android_pack.sh`; script pins 4.7.1 — same 4.7 minor as the embedded `org.godotengine:godot:4.7.1.stable`). |
| iOS PCK | **Not regenerated** — the required pinned Godot 4.6.x binary (`GODOT_IOS_BINARY`) is not present in this environment, and the vendored iOS engine must match it. Run `tool/export_godot_ios_pack.sh` with that binary before building the final archive, or the iOS build keeps the pre-fix GDScript. |

### Still open (unchanged from the evidence list)

Sustained hardware performance, full human decision workflows (purchase/auction, save/load, background/resume, bankruptcy, victory), signed final artifacts and store-console validation, phone UI/accessibility acceptance, and localization/asset provenance. The store-console privacy work from R4 also remains.
