# Internal-test update review — September 20, 2026

## Scope and recommendation

Review of the local, uncommitted changes on `release-prep/store-readiness`
since build 13 (`3b50d59`): top-bar camera-follow relocation, automatic card
chooser, setup layout/dice icons, D12 rolls/save/bridge/rendering support,
and camera-relative dice docking. Existing local work was preserved.

Suitable for a new **internal beta**; signed-artifact verification passed.
This is not approval for production release. Existing
camera framing/landmark label polish and full device acceptance remain open.
The supplied phone captures were inspected; their TOUR banner identifies a
QA entrypoint, so they were not substituted into public store screenshots.

## Review findings fixed before building

1. **Duplicate card dialog race:** tapping the deck before the 1.1-second
   auto-open timer opened a chooser manually, then the timer opened another.
   A regression test failed on the original implementation with two dialogs.
   Manual opening now cancels the timer and a dialog-open guard prevents
   re-entry. Callback application is tied to the original turn/session and
   pending pick. Scheduled-action cancellation also cancels auto-opening.
2. **Fresh D12 orientation:** `_die_face_rotation` returns radians, but the
   new dice initialization assigned it to `rotation_degrees`. Use `rotation`
   for D12, retaining the existing D6 orientation. Added numerical checks for
   fresh orientation, all 12 face rotations/pentagons and 24 orbit angles.
3. **Analysis housekeeping:** removed six unused imports/local-variable
   warnings. The supplied zero-warning claim did not match the initial local
   analysis; the final analysis has zero errors/warnings and 241 info items.
4. Extended release-artifact checks to reject screenshot-tour markers in
   addition to the existing autoplay markers. Store builds explicitly target
   `lib/main.dart`.

## Verification

- Original Flutter suite: **183/183** passed.
- Expanded suite: **188/188** passed, including automatic Chance/Chest opening,
  the manual/automatic race, invalidated-turn suppression and disposal.
- Godot bridge smoke passed on **4.7.2** (Android exporter) and **4.6.3**
  (iOS exporter); iOS headless shutdown reports ObjectDB instances leaked.
  This is not evidence of a measured device-memory leak; no new sustained
  hardware-memory run was performed in this review.
- New D12 numerical regression passed on both versions.
- Android `:app:testReleaseUnitTest` passed (14 native tests). The initial
  all-module test invocation also ran the third-party notification plugin's
  tests under the shell's Java 19, which its Robolectric ASM cannot parse
  (`Unsupported class file major version 63`). Those two tests passed when
  rerun under the installed JDK 17; no dependency source was modified.
- Both platform PCKs regenerated from the reviewed source before building.
- iOS exporter/runtime pairing remains the previously documented official
  4.6.3 exporter / vendored 4.6.4 runtime pairing.
- Evidence logs: `qa_evidence/2026-09-20-submission/`.

## Build and delivery

Version advanced to **2.0.1+14** after both consoles confirmed build 13 as
the latest existing build. Only Google Play internal testing and the
existing TestFlight Internal group are in scope; no production or external
testing rollout is authorized by this task.

- Google Play: signed 162.6 MB AAB uploaded and release **2.0.1 (14) - 3D UI
  and D12 improvements** published to the existing internal track. The console
  confirms **Available to internal testers**, released September 20 at
  2:32 AM CDT. No supported-device loss versus build 13 was reported.
- AAB SHA-256: `8719d8d2717b3d73a2e5f9b8fe9b80e409695848c3f68d5143baf4838c8b4af8`.
- Android source PCK SHA-256: `67c585920648e60bf04e390eb57066dfe3c8d14fea1e056882a7419b93951a73`.
- iOS source PCK SHA-256: `61754c512046eca2320771be3ecdb1d99cb579ff2d809282487bae14022718f3`.
- Signed iOS archive and App Store IPA built successfully (85.8 MB IPA).
  Both archive and exported IPA report `UIDeviceFamily = [1, 2]` and build 14.
  Exported app code signature verifies, Team `F9XW9FCX92`, and its profile has
  `get-task-allow = false`. Embedded iOS PCK matches the source hash above.
- IPA SHA-256: `4e91b6d6aeca680ae79c1edab08f6c68423c498452433a5e747be0afb9cbc59c`.
- Release-artifact checks: **33/33 passed**, including signature/identity,
  manifest permissions, version/build, PCK hashes, native JNI canaries and
  both autoplay/screenshot-tour exclusions in all Flutter AOT snapshots.
- TestFlight upload succeeded through Xcode's existing authenticated account
  at **2:34 AM CDT**. Apple processing completed, the unchanged encryption
  declaration was saved, and build **2.0.1 (14)** was automatically assigned
  to the existing **Internal** group (2 testers). Detailed What to Test notes
  were saved. The group's Builds table confirms **Testing — Expires in
  90 days** for build 14. No external testing or production submission was
  performed.
- The exported IPA independently passed the same **33/33** artifact checks,
  not only the archive. No physical-device app installation or saved-game
  modification was performed during this review/upload session.

## Beta acceptance priorities

- D6 and D12 with one/two dice; verify visual faces match the roll and moves.
- Chance/Chest auto-opening, quick manual tapping, one card effect per draw.
- Camera follow in More, orbit/zoom and dice docking at different angles.
- Save/Continue, legacy D6 saves, restart and repeated Quit/Continue.
- Phone/tablet, portrait/landscape, all five languages and large text.
- Fresh hardware runtime/performance testing remains separate from automated
  checks and the supplied earlier device captures.
