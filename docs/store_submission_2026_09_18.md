# Store testing submission — September 18, 2026

## Status

**September 20 follow-up:** build 14 review, fixes, verification and internal-test
delivery are recorded in [the new review](internal_test_review_2026_09_20.md).
The build-13 evidence below is retained as historical submission evidence.

**Internal testing is available on both platforms. Production has not been submitted or released. Store-listing preparation is incomplete.**

Latest screenshot status: **App Store Connect draft 2.0.1 has five iPhone screenshots and seven iPad screenshots. Google Play's saved draft has five phone screenshots and four screenshots in each tablet category.** Genuine 3D gameplay leads every set. The seven obsolete Apple iPad 2D images were removed with explicit owner confirmation. Google assets reuse the iOS captures at the owner's request; they are not evidence of Android device testing. Outstanding store forms remain separate work.

Application source: `release-prep/store-readiness`, starting at `729dd56`. Version changed from `2.0.1+12` to `2.0.1+13` because Apple already had a different build 12. No gameplay source changes were made for this submission.

## Build and verification evidence

- Signed Android AAB: `build/app/outputs/bundle/release/app-release.aab`, 162.6 MB. SHA-256 `2327db8dca953b8c9216eea4bcb3b0031d23fa9bb0c45e4c5cb27366ed84c2b6`.
- Android signing certificate SHA-256: `22:67:D0:88:FB:43:EA:2E:85:7B:02:FF:2D:DD:F0:10:2D:29:FD:DF:EA:BE:85:28:5E:F9:C1:D4:E3:CA:9D:F8`. Existing release key reused; credentials remain outside version control.
- iOS archive: `build/ios/archive/Runner.xcarchive`; App Store IPA: `build/ios/ipa/Property Tycoon.ipa` (85.7 MB). Built/exported with stable Xcode 27.0, ISW team `F9XW9FCX92`.
- Archive `UIDeviceFamily = [1, 2]`: **iPhone and iPad supported**. Bundle identifier `com.hyu.ProperotyTycoon`, minimum iOS 17.
- Release artifact verification: **33/33 pass**.
- Flutter tests rerun after the version change: **178/178 pass**.
- Logs in `qa_evidence/2026-09-19-submission/` (folder date is UTC): `android_build.log`, `ios_build.log`, `artifact_verification.log`, `ios_upload.log`, `flutter_tests.log`.
- iOS upload completed successfully at approximately 8:17 PM CDT; App Store Connect processed build 13 successfully.

## Google Play

- Created **MM Property Tycoon**, free game, English (United States), under ISW Technologies.
- App ID `4972598226696007836`; package `com.hyu.properotyTycoon`.
- Internal track `4701563366318002135` is **Active**. Release **2.0.1 (13) — 3D board internal test** is **Available to internal testers**, not reviewed.
- The owner's user-approved Gmail account is the sole member of the enabled existing **Hao Yu** email list.
- Test opt-in: https://play.google.com/apps/internaltest/4701563366318002135
- Developer Program Policies and U.S. export declarations accepted with explicit user confirmation.
- Saved English listing draft with accurate 18-city/3D/offline/local-AI description, app icon and feature graphic. The screenshot follow-up below records five phone and four screenshots in each tablet category, reused from iOS with owner approval; listing is not final.
- Category **Game → Board** saved. Public support email `hyu@isw.dev` published; support website set to the new HTTPS support page.
- Saved declarations: privacy-policy URL; no ads; unrestricted app access; no Advertising ID; non-government app; no financial features; no health features.
- Data Safety drafted: **no data collection, no sharing**. Final save blocked until target audience is complete.
- Content rating: category Game and contact email entered. **IARC Terms of Use approval requested; not accepted or submitted yet.**
- Target audience: user intends **children 5+ and adults/families**. No age selections saved. Play currently disables under-13 selections before rating completion; do not work around this by falsely choosing adults only.
- Listing/declaration changes have not been sent for production review.

## App Store Connect / TestFlight

- Existing app **MM Property Tycoon**, Apple ID `6758560433`.
- Export-compliance answer saved: none of the listed non-OS/proprietary algorithms. Source audit found no app crypto/network operations; Godot PCK encryption is disabled.
- Build **2.0.1 (13)** appears as **Testing** in the existing **Internal** group (automatic distribution). Group contains the owner's two existing Apple accounts; no external testers were added.
- Build 13 attached to draft store version **2.0.1**.
- Updated English description, promotional text, What's New, and reviewer notes to describe the 3D app accurately.
- Review contact email `hyu@isw.dev` verified visually; owner-provided review phone is present in Apple only, not copied into this public repository.
- **Manually release this version** is selected. No Add for Review / production submission action was taken.
- App Privacy: existing **Data Not Collected** retained; hosted privacy URL updated.
- Support URL replaced with https://hao6yu.github.io/mm-monopoly/support.html; broken marketing URL replaced with company homepage https://isw.technology/.
- Initially uploaded one current menu screenshot per device category. The screenshot follow-up below records replacement of the inherited 2D images and the complete current sets.

## Support page

User explicitly authorized publishing a support page with `hyu@isw.dev`.

- Source: `docs/support.html`.
- Published on existing GitHub Pages `gh-pages` branch, commit `e5a1232`, preserving privacy pages and the application branch.
- Live URL returned HTTP 200 and was visually checked: https://hao6yu.github.io/mm-monopoly/support.html
- Only `gh-pages` was pushed. Application/release branch was not pushed by this submission work.

## Screenshot tooling and remaining work

New, isolated simulators were created so the owner's device data is untouched:

- Store Screenshots iPhone — iPhone 14 Plus, iOS 26.5, `4185C578-6BFA-42EF-9DAD-1C3B54D809AC`.
- Store Screenshots iPad — iPad Pro 13-inch M4, iOS 26.5, `097D7705-CA9E-400C-83B9-664FF6B464A7`.

Both have the normal app entrypoint installed and running. Flutter's simulator build tried x86_64 against an arm64-only cached engine; direct Xcode build with `ARCHS=arm64 ONLY_ACTIVE_ARCH=YES` succeeded. See `ios_simulator_arm64.log`. This is a local build-tool issue, not a store binary failure.

Native desktop control of Device Hub repeatedly timed out even after the owner opened it. With explicit owner approval, a temporary standalone XCTest runner successfully navigated the installed normal app on both simulators. Full-resolution city-selection and player-setup screenshots were captured and visually checked, in addition to the existing menu images:

- `store_assets/2.0.1/ios-iphone/02-city-selection.png` and `04-player-setup.png` — 1284×2778, two-player setup.
- `store_assets/2.0.1/ios-ipad/02-city-selection.png` and `04-player-setup.png` — 2064×2752, four-player setup; player screen shows two humans and two AI players.
- These four new images were initially saved locally; subsequent uploads are recorded in the follow-ups below.
- Temporary runner and successful result bundles: `/tmp/tycoon-screenshot-runner.gXuAtT/`, `players-iphone.xcresult`, `setup-ipad-final.xcresult`. No runner code was added to the game or uploaded builds.

**Simulator 3D limitation confirmed:** `ios/Runner/GodotBoardIOSPlugin.swift` explicitly returns `false` for `isAvailable` under `targetEnvironment(simulator)`. Starting a game through XCTest confirmed the simulator renders the old 2D fallback. That board capture was excluded from store assets; it is not evidence of current hardware 3D gameplay. Genuine 3D captures require physical iOS hardware with this build configuration. The paired iPad could not be reached because it was locked/disconnected; the owner was asked to unlock and connect it. No app was installed or save data changed on the physical device during this capture attempt.

Do not use generated images as gameplay screenshots, represent 2D fallback captures as 3D, or label Android/iPad captures as iPhone captures.

### Physical iPad capture follow-up

After the owner unlocked the iPad Air (5th generation), the device connected successfully. Its installed normal app was version 2.0.1 build 12. The build-13 submission commit changed the version number, store assets/documentation and tooling, not gameplay source. The installed game was not replaced for this capture session.

Using the explicitly authorized temporary XCTest runner, a new four-human-player Atlantic City session was started from the menu. The runner rolled Player 1's dice, completed the move to Vermont Avenue, bought the property using in-game cash, and opened the player's portfolio. This exercised real 3D rendering, turn handoff, pinch zoom and purchase/portfolio UI. It is a screenshot session, not a complete release-acceptance test. Existing saved games were not deleted or overwritten manually; this new game can create its own normal autosave.

Four visually checked, unedited hardware originals are saved in `store_assets/2.0.1/ios-ipad-air-originals/`:

- `01-3d-board-portrait.png`: initial four-player board, 1908×2746.
- `02-3d-board-landscape.png`: board after purchase and a normal pinch-to-zoom-out gesture, 2746×1908.
- `03-property-purchase.png`: Vermont Avenue purchase dialog, 2746×1908.
- `04-player-portfolio.png`: owned property and net worth, 2746×1908.

The portfolio was closed and the game was left on Player 2's turn. The temporary `dev.isw.screenshot.ScreenshotTests.xctrunner` app was uninstalled after capture; the game itself remains installed. Local runner source/results remain available for reproducibility.

XCTest's `app.screenshot()` produced clipped/black-area images after rotation on this iPadOS beta. Those landscape attachments were rejected. Direct `devicectl device capture screenshot` captures were correct and are the saved landscape originals. The portrait XCTest attachment was visually correct. Successful runner results are in the temporary directory above: `board-device.xcresult`, `action-device.xcresult`, `purchase-device.xcresult`, and `portfolio-device.xcresult`.

The connected device reports native size 1640×2360 but current display bounds 1908×2746; both capture methods return the latter resolution. These originals are **not yet store-size-ready or uploaded**. Owner approval was requested for ordinary, non-AI aspect-preserving resize/padding to [Apple's accepted screenshot dimensions](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications). The required 13-inch iPad set accepts 2064×2752 or 2048×2732 portrait (or the corresponding landscape dimensions). No images are stretched or relabeled as iPhone captures.

Visual follow-up items: the default portrait camera cuts off part of the island edge; zooming out improves the overview. The Boardwalk and Absecon Light world labels can overlap at the captured camera angle. These should be reviewed as camera-framing/label-readability polish; the malformed XCTest landscape image alone is not evidence of an in-app rotation defect.

### Screenshot uploads and physical iPhone follow-up

The owner requested upload of the captures and explicitly approved replacing the seven inherited iPad screenshots. Only those seven obsolete draft assets were deleted; the current menu was retained. The published 1.3 listing was not edited.

`tool/pad_store_screenshots.swift` creates opaque, sRGB PNG copies with a plain navy border. It preserves the complete original image at its original pixel dimensions, with **padding only**: no cropping, stretching, rescaling or generated gameplay. Original captures remain separately available. iPad upload copies live in `ios-ipad-store/` beneath `store_assets/2.0.1/`.

The owner also connected and authorized capture on **Hyu17ProBlue (iPhone 17 Pro)**. It already had version 2.0.1 **build 13** installed, with a four-player Atlantic City game open. No game installation was necessary. The temporary XCTest runner used actual screen-coordinate taps because this TestFlight build did not expose the Flutter controls in the accessibility tree. It collapsed the player-status list, rolled Player 1's dice, and captured the resulting Connecticut Avenue purchase dialog. The game was left at that decision; no purchase was made on the owner's behalf. The temporary runner was uninstalled afterward.

Three unedited iPhone captures are retained in `store_assets/2.0.1/ios-iphone-originals/` (1206×2622): expanded status/board, collapsed status/board, and purchase dialog. The collapsed board and purchase dialog were selected for upload and padded to 1284×2778 in `ios-iphone-store/`. The expanded-status capture was retained locally but not uploaded. Main-screen XCTest attachments were visually correct in portrait; source result is `action-iphone-hardware.xcresult` in the temporary runner directory. Source image `iphone-current.png` is the expanded-status capture.

**Verified App Store Connect draft order (English U.S.):**

- iPhone 6.5-inch, **5 of 10**: 3D board → purchase dialog → city selection → player setup → menu.
- iPad 13-inch, **7 of 10**: landscape 3D board → portrait 3D board → purchase dialog → portfolio → city selection → player setup → menu.

Upload counts and ordered filenames were confirmed through the rendered listing UI; iPhone thumbnails were also visually checked. Save is disabled after the auto-saved asset updates. Build 13 remains attached, status remains Prepare for Submission, and Add for Review was not pressed. No production review/submission/release occurred. The later Google Play follow-up below records owner-approved reuse of these captures.

Additional UI issue observed on the physical iPhone: the city badge overlaps part of the rightmost top-row camera control at this portrait width. This is preserved in the authentic captures and should be fixed and re-captured with the next UI build, not concealed through image edits.

Assets so far live under `store_assets/2.0.1/`; `tool/create_store_graphics.swift` regenerates the Google icon/feature graphic using the existing app artwork.

### Google Play screenshot reuse follow-up

The owner explicitly approved using the existing iOS captures for Google Play. The shared Flutter board-screen UI and Godot rendering source were inspected; platform-specific native view hosting differs. This source inspection does **not** establish pixel parity or replace Android hardware testing. No Android captures were taken during this work.

Extended `tool/pad_store_screenshots.swift` with `play-phone` and `play-tablet` modes. All nine output files are opaque PNGs under 8 MB, with the complete original image retained at its original pixel dimensions and centered on a navy canvas. No cropping, stretching, rescaling or generated gameplay was used.

- `store_assets/2.0.1/google-play-phone/`: five 1620×2880 images. Board/purchase images originate from the physical iPhone 17 Pro running build 13; city/setup/menu originate from the normal-entrypoint iOS simulator.
- `store_assets/2.0.1/google-play-tablet/`: four images, 3392×1908 landscape or 1908×3392 portrait, originating from the physical iPad Air build-12 capture session documented above. These same four assets were attached to both tablet categories.

**Verified saved Google Play draft order (English U.S.):**

- Phone, **5 of 8**: 3D board → purchase dialog → city selection → player setup → menu.
- 7-inch tablet, **4 of 8**: landscape 3D board → portrait 3D board → purchase dialog → portfolio.
- 10-inch tablet, **4 of 8**: landscape 3D board → portrait 3D board → purchase dialog → portfolio.

The rendered editor confirmed these orders before saving, then displayed **Your changes have been saved**, with Save as draft disabled and all three counts retained. The short description now uses “2 to 4” instead of an en-dash range; the previously shown punctuation warning remained visible after saving, so its clearance is not claimed. PC, Chromebook and XR asset sections were left untouched. No production review/release action or additional legal declaration was submitted.

### Next actions

1. Obtain IARC terms approval; accurately complete rating questionnaire, including the actual free bonus wheel and virtual-currency mechanics. Then complete the child/family audience declaration and Data Safety.
2. Both store drafts now have screenshots as recorded above. Verify Android visual parity before production; replace the reused captures if Android layout or rendering differs. Re-capture after fixes to the documented camera/label/HUD issues.
3. Recheck child-audience requirements against the direct external support/donation links and optional photo-avatar behavior before claiming release compliance. Do not change the intended audience merely to avoid Families requirements.
4. Complete remaining dashboard/forms and validate listing content. Internal availability is not production approval.
5. Perform final human/device acceptance testing before separately authorizing production submission.
