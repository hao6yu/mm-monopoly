# Store privacy declarations — proposed answers

Prepared for the App Store privacy label and Google Play Data Safety form.
Everything below reflects the audited behavior of this checkout (branch
`release-prep/store-readiness`), verified against the source:

- **Storage:** game saves, settings, statistics, leaderboard entries
  (`SharedPreferences` via `StatsService`/`SaveService`/`LocaleService`/
  `GraphicsQualityService`/`UnlockService`), and custom avatar photos
  (`getApplicationDocumentsDirectory()/custom_avatars` via
  `CustomAvatarService`) all live in the app sandbox on device.
- **Network:** the app makes no network requests of its own. The only
  outbound touchpoint is the optional Settings support/donation link opened
  with `url_launcher` (`https://buymeacoffee.com/hao_yu`), which leaves the
  app. There are no analytics, ads, crash-reporting, or tracking packages in
  `pubspec.yaml`.
- **Notifications:** local reminders only
  (`flutter_local_notifications`, `AndroidScheduleMode.inexactAllowWhileIdle`).
  No push, no background modes (`UIBackgroundModes` removed from
  `ios/Runner/Info.plist`).
- **Photo/camera:** optional custom avatar only (`image_picker`). Gallery
  selection uses the system photo picker; the merged Android manifest carries
  no `READ_MEDIA_IMAGES`/`READ_EXTERNAL_STORAGE`. iOS keeps
  `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription`.

## Owner confirmation required before submission

| # | Item | Why it needs the owner |
|---|---|---|
| O1 | Hosted privacy-policy URL | The policy exists in-app and as `docs/privacy_policy_page.html`, but no authorized public URL exists yet. Options: GitHub Pages on `github.com/hao6yu/mm-monopoly` (e.g. `https://hao6yu.github.io/mm-monopoly/privacy_policy_page.html`) or any owner-controlled site. |
| O2 | Support/contact identity | The policy's contact section currently points at the in-app support link and the store listing. If a direct email/contact form exists, it should replace or supplement this. |
| O3 | Console account access | The App Store Connect privacy answer form and Play Console Data Safety form must be filled in by the account holder; the answers below are the proposed content. |

## App Store — App Privacy answers

**Do you or your third-party partners collect data from this app?**
→ **No.**

The app collects no data off the device: no identifiers, no usage data, no
location, no contacts, no user content transmitted anywhere. Optional local
notifications and on-device avatars are not "collected" under Apple's
definitions. The support link is an external website, not an SDK integration.

**Privacy policy URL (App Store Connect + in-app):** pending O1. The in-app
policy is reachable from Settings → Privacy Policy
(`settings-privacy-button`), which satisfies guideline 5.1.1(i) once the
store-listing URL (O1) is also live.

## Google Play — Data Safety answers

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No.** |
| Is all of the user data collected by your app encrypted in transit? | N/A — no data leaves the device (form auto-completes when "no data" is selected). |
| Do you provide a way for users to request that their data is deleted? | N/A — no data leaves the device; uninstalling removes all app data. |
| Data deletion URL (if requested) | Not required under "no data collected"; if the form demands one, link the O1 policy page. |

**Permissions declared to Play:** `CAMERA` (optional avatar photo, runtime
permission with in-app rationale), `POST_NOTIFICATIONS` (optional local
reminders), `RECEIVE_BOOT_COMPLETED` (reschedule reminders after reboot). No
storage/media, no exact-alarm, no location, no contacts, no microphone.
Verify the final merged manifest against this list before submission (the
release-verification check in `tool/verify_release.sh` prints the AAB's
declared permissions).

## Store listing policy link checklist

1. Publish `docs/privacy_policy_page.html` at the O1 destination unchanged.
2. App Store Connect: App Privacy section → policy URL + "Data Not
   Collected" answers; App Description does not need the URL but App Review
   notes should mention the in-app Settings entry.
3. Play Console: App content → Privacy Policy → the same URL; Data Safety →
   answers above.
4. Re-run `tool/verify_release.sh` after any dependency change so the
   declared permissions stay in sync with these declarations.
