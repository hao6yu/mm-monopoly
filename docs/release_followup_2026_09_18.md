# Store-readiness follow-up — September 18, 2026

Branch: `release-prep/store-readiness`. This is a follow-up to the September 17
review, not a claim that all release gates have passed. No store upload or
submission has been performed. The connected iPad and its saves were not
modified during this pass.

**Decision: HOLD public release.** Three Android defects were fixed, but
subsequent native testing found another engineering blocker: returning to the
menu and reopening a game in the same process destroys/reuses the Godot engine
incorrectly. iOS App Store export also remains blocked on distribution signing.

## Completed

### Existing Android key recovered and wired up

The key was never missing. The checkout lacked `android/key.properties`.
The owner's existing `/Users/haoyu/android-keys/my-universal-release-key.jks`
has a `release` private-key entry. The owner confirmed this game's first Play
upload is still pending, so there is no existing upload certificate to match.

The ignored `android/key.properties` is now a local symlink to the already
configured credentials at
`/Users/haoyu/development/mm-learning-lab/android/key.properties`.
No passwords or private keys were printed, copied into tracked files, or
committed. This local link depends on that existing configuration remaining
available; another machine must configure its own ignored signing properties.

Public release certificate SHA-256:
`22:67:D0:88:FB:43:EA:2E:85:7B:02:FF:2D:DD:F0:10:2D:29:FD:DF:EA:BE:85:28:5E:F9:C1:D4:E3:CA:9D:F8`.

### Hosted privacy policy

Published at https://hao6yu.github.io/mm-monopoly/privacy_policy_page.html.
HTTP 200 verified; hosted bytes match `docs/privacy_policy_page.html`:
`d695a34b46f7d6e336b9d0342d00bea94ed754be0f6e2c4ef307ad656095d874`.
GitHub Pages serves an isolated `gh-pages` branch containing only `index.html`
and `privacy_policy_page.html`, commit
`71d72ad0d8328e3ae4bdb19b7edb3b1c8353fd08`. The app release branch was not pushed.
The existing in-app policy remains available offline in all five languages.
Store-console declaration answers and the URL are recorded in
`store_privacy_declarations.md`; console entry is still pending access.

### Three real Android release defects reproduced and fixed

1. **Native crash on Start Game.** R8 renamed/removed Godot JNI classes and
   methods. The release crashed with `NoSuchMethodError` for
   `GodotNativeBridge.getRenderView()` / `GodotIO.openURI()`. Added scoped
   engine/plugin keep rules and wired them into the release build. The rest
   of the app is still optimized. Evidence: `android_pre_fix_crash.log`.
2. **3D initialization failed after the crash fix.** `replace(container.id, …)`
   ran before Flutter attached the platform view to the activity hierarchy.
   FragmentManager threw `No view found for id …`, leaving the preparation
   screen to time out. Passing the actual container to `add(container, …)`
   avoids that premature activity-ID lookup. Evidence:
   `android_pre_container_fix.log`; subsequent native board screenshots.
3. **Notifications never initialized in release.** The plugin could not resolve
   `@mipmap/ic_launcher` after resource shrinking. Added a dedicated monochrome
   `ic_notification` drawable with a resource keep rule. Release now shows
   the actual Android permission prompt; denial safely skips scheduling and
   does not block gameplay. Added an automated denial/initialization test.

These defects were not detected by the earlier successful compilation,
headless Godot smoke, or mocked Flutter bridge tests. A release-device boot
must remain an independent gate.

### Stronger release checks

`tool/verify_release.sh` now fails for an unsigned AAB, cryptographically
verifies its JAR signature, pins the public certificate, compares the Android
embedded PCK against the source pack, inspects all packaged Flutter AOT ABIs,
checks Godot JNI/bridge symbol canaries, rejects unreviewed permissions, checks
both iOS version fields, and verifies the iOS code signature. Absolute iOS
app paths now work. Presence of a provisioning profile is no longer described
as proof of App Store eligibility.

Negative controls: the pre-fix signed bundle failed the JNI symbol canaries;
a temporary unsigned copy failed; a deliberately incorrect expected
certificate failed. The original signed bundle was preserved. Symbol canaries
are regression checks, not proof of complete JNI compatibility.

### Android functional QA on a fresh emulator

Created `property_tycoon_release_qa` (Pixel 6 profile, Android 15 / API 35,
ARM64, host GPU). Existing SDK image folders contained incomplete old images;
installed a complete API 35 image. This is emulator functional evidence, not
physical Android thermal/GPU/performance acceptance.

Exercised the **normal minified signed release entrypoint**, not the QA harness:

- Menu → four-player setup (two humans, two AI) → immediate Preparing Game
  indicator → native Godot 4.7.1 board ready.
- Human roll, animated pawn movement, Reading Railroad purchase ($200),
  second human roll, actual Chance deck tap → card flip → Continue.
- AI thinking/rolling progression with disabled human roll surface; tapped
  during AI thinking, then backgrounded/resumed; game continued through both
  AI players to round 2. This is a short functional check, not a soak run.
- Menu pause/resume; Save at a stable human turn.
- Force-stop; install signed split APKs generated from the final AAB using
  bundletool; launch → Continue. Restored round 2, player 1 active, and cash
  $1800 / $2000 / $1900 / $1900 with the 3D board ready.
- Notifications denied through the real system permission dialog; game
  remains playable. Version `2.0.1`, build `12`, minSdk `24`, targetSdk `36`.

Screenshots/logs: `qa_evidence/2026-09-18/`.

### New P1 blocker: warm game re-entry destroys the Android engine

Reproduction on the minified signed Android release: launch → Continue (works)
→ game menu → Quit to Menu → confirm → Continue without force-stopping.
The 3D preparation screen times out; Retry does not recover. Changing graphics
quality in Settings between sessions is not required to reproduce it.

`GLThread: Exiting render thread` and `GodotRenderer: Destroying Godot Engine`
occur as Flutter detaches the old platform view. `MainActivity` retains the
fragment and plugin, then reparents its view and reports the cached scene-ready
signal on the next session, even though the native engine was destroyed.
The bundled Godot 4.7.1 bytecode confirms `GLSurfaceView.onDetachedFromWindow`
exits the GL thread, whose renderer calls `GodotLib.ondestroy()`.

A local experiment deferring fragment resume/bridge attachment until the new
container attaches still failed (eventually SIGSEGV); it was removed, and the
previous signed AAB-derived install restored. Do not count cold-start
Save/Continue, mocked bridge/session tests, or a successful signed build as
coverage for this case. Logs are retained as
`android_warm_reentry_lifecycle.log`, `android_reattach_timeout.log`, and
`android_reattach_experiment_crash.log`.

Required fix: preserve a live, attached renderer across Flutter navigation, or
implement an engine lifecycle strategy supported by the bundled runtime. Then
test repeated Quit/Continue, New Game, Restart, victory Replay, 2D fallback and
return, and background/resume on the actual minified AAB-derived install.
Do not simply raise the timeout or report a cached boardReady as success.

### Automated coverage and artifact checks

- Flutter: **175 tests passed**, including progressed-state save/reload,
  corrupt/future-save handling, real Replay/Home button taps, and Android
  notification denial. Analyzer: 0 errors / 0 warnings, 239 existing infos.
- Android release JVM tests: **12 passed** in four suites. Artifact verifier:
  **33/33 passed**, including the archived iOS app path. These are artifact
  integrity checks, not App Store distribution validation or lifecycle QA.
- Android signed AAB:
  `build/app/outputs/bundle/release/app-release.aab`, SHA-256
  `4f229d543cdb711f43518ca5dfcdeb1154df84c610f097b6b804ca3ee66bbbd5`.
- AAB-derived device APK set:
  `build/app/outputs/bundle/release/release-device.apks`, SHA-256
  `69a36055e3550910ba68f01f01c850b6796bab532b2fcf4e6003e25a520568da`.
- `apksigner verify` succeeds with the expected certificate. APK ZIP alignment
  passes at 16 KB; AAB requests `PAGE_ALIGNMENT_16K`; all ten ARM64/x86_64
  native libraries have ELF LOAD alignment at least 16 KB. This does not
  replace an actual 16 KB-page runtime test.
- iOS archive rebuilt with **non-beta Xcode 27.0 (27A266a)** and local app
  settings validation passed. **App Store IPA export failed**: no account for
  `ISW TECHNOLOGIES LLC`, no applicable distribution certificate/profile.
  The project is configured for team `F9XW9FCX92`; do not silently switch teams.

## Still required before public release

0. Fix the warm Android game re-entry blocker above and repeat the native
   navigation/second-session acceptance matrix.
1. Confirm the intended Apple team and connect its authorized Xcode account /
   distribution signing credentials. Then export and validate the App Store
   artifact. Development signing and an archive are not sufficient.
2. Authenticated App Store Connect / Play Console entry: privacy URL and
   declarations, age/content ratings, listing/screenshots, account-specific
   testing requirements and final upload authorization. Agents can do this
   with appropriate access; it is not inherently human-only.
3. Real minimum-spec Android and older-iOS sustained gameplay, memory/thermal
   and graphics-tier profiling. Emulator results do not close these gates.
4. Complete the remaining acceptance matrix: auction/bankruptcy/end-game
   workflows on native builds, camera denial, multi-touch feel, screen-reader
   and largest-text usability. The new tests cover specific flows, not every
   combination or subjective experience. Asset/name provenance remains a
   separate owner review item from the original audit.

## UI polish still visible

- The phone landscape default camera/HUD can obscure pawns and crop board
  extremities. Review framing across narrow aspect ratios and collapsed HUD;
  do not treat a responsive layout test as proof of scene readability.
- Quit confirmation says all progress is lost even when a save exists; more
  precise wording would distinguish unsaved progress from the retained save.
- Consider requesting notification permission from an explicit opt-in flow
  instead of immediately on first launch.

## Correction to previous performance report

The September 17 hitch XML contains **six** hitch rows, not three: total
**166.653374 ms**, maximum **66.662041 ms**. Three rows reference an earlier
duration ID. Thermal remained Nominal for the 10.03-minute trace. Flutter
compositor timings do not establish native 3D FPS. The historical addendum
has been corrected accordingly.
