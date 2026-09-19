# Store testing submission — September 18, 2026

## Status

**Internal testing is available on both platforms. Production has not been submitted or released. Store-listing preparation is incomplete.**

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
- Saved English listing draft with accurate 18-city/3D/offline/local-AI description, app icon and feature graphic. **No Android screenshots yet**; listing is not final.
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
- Uploaded one real current menu screenshot for iPhone 6.5-inch (1284×2778) and one for iPad 13-inch (2064×2752).
- **Seven inherited iPad screenshots remain and show the older 2D design. They must be replaced, not treated as current screenshots.** Current iPad count is 8 including the newly added menu; iPhone count is 1.

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

Native desktop control of Device Hub repeatedly timed out even after the owner opened it. Dedicated `simctl` full-resolution screenshot capture works. The owner was asked to start a game on each simulator so real 3D screenshots can be captured. Do not use generated images as gameplay screenshots or label Android captures as iOS captures.

Assets so far live under `store_assets/2.0.1/`; `tool/create_store_graphics.swift` regenerates the Google icon/feature graphic using the existing app artwork.

### Next actions

1. Obtain IARC terms approval; accurately complete rating questionnaire, including the actual free bonus wheel and virtual-currency mechanics. Then complete the child/family audience declaration and Data Safety.
2. Capture varied actual 3D gameplay/setup screens on both iOS simulators and Android; upload, reorder gameplay first, and replace the seven obsolete iPad images. Preserve or explicitly confirm removal of old assets before destructive deletion.
3. Recheck child-audience requirements against the direct external support/donation links and optional photo-avatar behavior before claiming release compliance. Do not change the intended audience merely to avoid Families requirements.
4. Complete remaining dashboard/forms and validate listing content. Internal availability is not production approval.
5. Perform final human/device acceptance testing before separately authorizing production submission.
