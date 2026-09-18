# Android release QA evidence

See `docs/release_followup_2026_09_18.md` for findings, artifact hashes,
scope, and remaining blockers. These are Android 15 ARM64 emulator captures,
not physical-device performance evidence.

Filenames record the point in the investigation, not a passing assertion:
`android_board_after_fix.png`, `android_board_working.png`, and
`android_second_session_low.png` include intermediate loading/error states.
`android_board_ready.png` shows the first working native board;
`android_aab_continue.png` shows the successful cold Continue from actual
AAB-derived APKs. That cold result does **not** cover warm re-entry.

The removed deferred-attachment experiment ended in a native crash;
`android_reattach_experiment_crash_home.png` shows the launcher afterward,
not a game timeout. Its crash log and warm lifecycle log are included.
The final source does not contain that experiment, and the original signed
AAB-derived APK set was reinstalled afterward. No emulator save was erased.

Automated evidence: 175 Flutter tests, analyzer 239 existing informational
diagnostics (no errors/warnings), 12 Android release JVM tests, and 33 artifact
checks. Negative controls confirm unsigned, wrong-certificate, and pre-JNI-fix
artifacts are rejected. None of these closes the warm native lifecycle blocker
or establishes iOS App Store export eligibility.
