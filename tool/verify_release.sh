#!/usr/bin/env bash
#
# Repeatable release-artifact verification for store submission.
#
# Usage:
#   tool/verify_release.sh                      # verify default artifacts
#   APP_BUNDLE=path tool/verify_release.sh      # verify a specific AAB
#   IOS_APP=path tool/verify_release.sh         # verify a specific Runner.app
# These are local artifact checks, not App Store validation or Play approval.
#
# Distinguishes successful compilation from a distributable signed artifact,
# verifies version/build numbers, the declared Android permissions against
# the privacy declarations (docs/store_privacy_declarations.md), the embedded
# Godot PCK hashes, and QA-autoplay exclusion in the actual Flutter AOT
# snapshots (libapp.so / App.framework) — not just DEX strings.
set -uo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

APP_BUNDLE="${APP_BUNDLE:-build/app/outputs/bundle/release/app-release.aab}"
IOS_APP="${IOS_APP:-build/ios/iphoneos/Runner.app}"
IOS_PCK="ios/Runner/Godot/property_tycoon.pck"
ANDROID_PCK="android/app/src/main/assets/godot/property_tycoon.pck"
BUNDLETOOL="${BUNDLETOOL:-$project_dir/.tools/bundletool.jar}"
# Public certificate fingerprint of the owner's existing release key. This
# game's first Play upload will establish its upload identity (not yet uploaded).
EXPECTED_ANDROID_CERT_SHA256="${EXPECTED_ANDROID_CERT_SHA256:-22:67:D0:88:FB:43:EA:2E:85:7B:02:FF:2D:DD:F0:10:2D:29:FD:DF:EA:BE:85:28:5E:F9:C1:D4:E3:CA:9D:F8}"
verify_tmp="$(mktemp -d)" || exit 1
trap 'rm -f "$verify_tmp/libapp.so" "$verify_tmp/jarsigner.txt" "$verify_tmp/dex-symbols.txt"; rmdir "$verify_tmp"' EXIT

pass=0
fail=0

ok()   { printf '  \033[32mPASS\033[0m %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=$((fail+1)); }
info() { printf '  ---- %s\n' "$1"; }

sha256_of() { shasum -a 256 "$1" | awk '{print $1}'; }

flutter_binary() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
  elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
    printf '%s' "$HOME/flutter/bin/flutter"
  fi
}

# QA autoplay markers from lib/qa_autoplay.dart / lib/main_qa.dart. Any hit
# inside an AOT snapshot means the QA harness leaked into the artifact.
QA_MARKERS=(
  'qaAutoplay'
  'QA setup failed'
  'QA: waiting'
  'PT_QA_AUTOPLAY'
  'QaAutoplayApp'
  'M&M Property Tycoon QA'
  'QaScreenshotTourApp'
  'TOUR '
)
# A Dart string literal that must exist in the store entrypoint's snapshot
# (the Godot bridge channel name), proving the strings search is live.
CANARY_STRING='property_tycoon/godot_board_bridge'

FORBIDDEN_PERMISSIONS=(
  DUMP
  READ_MEDIA_IMAGES
  READ_EXTERNAL_STORAGE
  SCHEDULE_EXACT_ALARM
  USE_EXACT_ALARM
  READ_MEDIA_VISUAL_USER_SELECTED
  ACCESS_FINE_LOCATION
  RECORD_AUDIO
  READ_CONTACTS
)
EXPECTED_PERMISSIONS=(
  CAMERA
  POST_NOTIFICATIONS
  RECEIVE_BOOT_COMPLETED
  VIBRATE
)

flutter_bin="$(flutter_binary)"
printf '\n=== Toolchain ===\n'
if [[ -n "$flutter_bin" ]]; then
  info "$("$flutter_bin" --version 2>/dev/null | head -1)"
else
  bad 'flutter not found on PATH or ~/flutter/bin/flutter'
fi
info "iOS PCK: $(sha256_of "$IOS_PCK")  ($IOS_PCK)"
info "Android PCK: $(sha256_of "$ANDROID_PCK")  ($ANDROID_PCK)"

version_from_pubspec() {
  awk '/^version:/ {print $2}' pubspec.yaml
}
expected_version="$(version_from_pubspec)"
info "pubspec version: $expected_version"
expected_version_name="${expected_version%%+*}"
expected_version_code="${expected_version##*+}"

if [[ -f "$APP_BUNDLE" ]]; then
  printf '\n=== Android release AAB: %s ===\n' "$APP_BUNDLE"
  info "size: $(du -h "$APP_BUNDLE" | awk '{print $1}')"
  info "sha256: $(sha256_of "$APP_BUNDLE")"

  if [[ -f "$BUNDLETOOL" ]]; then
    manifest="$(java -jar "$BUNDLETOOL" dump manifest --bundle="$APP_BUNDLE" 2>/dev/null)"
    aab_version="$(printf '%s' "$manifest" | sed -n 's/.*android:versionName="\([^"]*\)".*/\1/p' | head -1)"
    aab_build="$(printf '%s' "$manifest" | sed -n 's/.*android:versionCode="\([^"]*\)".*/\1/p' | head -1)"
    if [[ "$aab_version" == "$expected_version_name" ]]; then
      ok "versionName $aab_version matches pubspec (versionCode $aab_build)"
    else
      bad "versionName '$aab_version' does not match pubspec '$expected_version_name'"
    fi
    if [[ "$aab_build" == "$expected_version_code" ]]; then
      ok "versionCode $aab_build matches pubspec build number"
    else
      bad "versionCode '$aab_build' does not match pubspec build '$expected_version_code'"
    fi

    permissions="$(printf '%s' "$manifest" | grep '<uses-permission' | grep -o 'android:name="[^"]*"' | sed 's/android:name="//;s/"$//' | sort -u)"
    info "merged-manifest permissions:"
    printf '%s\n' "$permissions" | sed 's/^/       /'
    for expected in "${EXPECTED_PERMISSIONS[@]}"; do
      if printf '%s\n' "$permissions" | grep -qx "android.permission.$expected"; then
        ok "expected permission present: android.permission.$expected"
      else
        info "expected permission absent: android.permission.$expected (check if intentional)"
      fi
    done
    for forbidden in "${FORBIDDEN_PERMISSIONS[@]}"; do
      if printf '%s\n' "$permissions" | grep -q "android.permission.$forbidden"; then
        bad "forbidden permission declared: android.permission.$forbidden"
      else
        ok "no forbidden permission: android.permission.$forbidden"
      fi
    done
    while IFS= read -r permission; do
      allowed=0
      # AndroidX's app-scoped signature permission protects dynamic receivers;
      # it is not a user-data permission. Do not allow arbitrary custom names.
      [[ "$permission" == 'com.hyu.properotyTycoon.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION' ]] && allowed=1
      for expected in "${EXPECTED_PERMISSIONS[@]}"; do
        [[ "$permission" == "android.permission.$expected" ]] && allowed=1
      done
      [[ "$allowed" -eq 1 ]] || bad "unreviewed permission: $permission"
    done <<< "$permissions"
  else
    bad "bundletool jar not found at $BUNDLETOOL; cannot inspect the merged manifest"
  fi

  # AABs use JAR signing, not APK v2/v3 signing. A signature block alone
  # does not prove integrity; verify the contents and pin the public identity.
  # Consume the complete listing: grep -q may SIGPIPE unzip under pipefail.
  if unzip -l "$APP_BUNDLE" 'META-INF/*' 2>/dev/null | grep -E 'META-INF/.*\.(RSA|DSA|EC)' >/dev/null; then
    if jarsigner -J-Duser.language=en -verify "$APP_BUNDLE" > "$verify_tmp/jarsigner.txt" 2>&1 \
      && grep -q 'jar verified\.' "$verify_tmp/jarsigner.txt" \
      && ! grep -qi 'unsigned entries' "$verify_tmp/jarsigner.txt"; then
      ok 'AAB JAR signature verifies, with no unsigned entries'
    else
      bad 'AAB signature verification failed or contains unsigned entries'
    fi
    actual_certificate="$(keytool -J-Duser.language=en -printcert -jarfile "$APP_BUNDLE" 2>/dev/null | sed -n 's/.*SHA256: //p' | sort -u)"
    if [[ "$actual_certificate" == "$EXPECTED_ANDROID_CERT_SHA256" ]]; then
      ok "AAB certificate matches expected release identity: $actual_certificate"
    else
      bad "AAB certificate does not match expected release identity: $actual_certificate"
    fi
  else
    bad 'AAB is UNSIGNED: compilation artifact only, not distributable'
  fi

  embedded_android_pck="$(unzip -p "$APP_BUNDLE" base/assets/godot/property_tycoon.pck 2>/dev/null | shasum -a 256 | awk '{print $1}')"
  if [[ "$embedded_android_pck" == "$(sha256_of "$ANDROID_PCK")" ]]; then
    ok 'Android embedded PCK matches source pack'
  else
    bad 'Android embedded PCK missing or differs from source pack'
  fi

  # Release-only R8 regression canaries. Native Godot uses these exact Java
  # descriptors/names. This caught the missing GodotRenderView return type;
  # symbol presence is not a substitute for booting a minified release build.
  unzip -p "$APP_BUNDLE" 'base/dex/classes*.dex' 2>/dev/null | strings > "$verify_tmp/dex-symbols.txt"
  jni_missing=0
  for symbol in 'Lorg/godotengine/godot/GodotRenderView;' \
    'Lorg/godotengine/godot/GodotIO;' \
    'Lorg/godotengine/godot/nativeapi/GodotNativeBridge;' \
    getRenderView openURI stateApplied movementComplete boardObjectTapped; do
    # DEX strings can have a printable length prefix; do not require an exact
    # line match from the generic strings utility.
    if ! grep -Fq "$symbol" "$verify_tmp/dex-symbols.txt"; then
      bad "Godot JNI/bridge symbol missing from release DEX: $symbol"
      jni_missing=1
    fi
  done
  [[ "$jni_missing" -ne 0 ]] || ok 'Godot JNI/bridge symbol canaries survive release shrinking'

  # QA exclusion in the actual Flutter AOT snapshot.
  aot_paths="$(unzip -Z1 "$APP_BUNDLE" 2>/dev/null | grep -E '^base/lib/[^/]+/libapp[.]so$')"
  if [[ -n "$aot_paths" ]]; then
    while IFS= read -r aot_path; do
      info "checking $aot_path"
      libapp="$verify_tmp/libapp.so"
      unzip -p "$APP_BUNDLE" "$aot_path" > "$libapp" 2>/dev/null
      if [[ "$(strings "$libapp" | grep -cF "$CANARY_STRING")" -gt 0 ]]; then
        ok "AOT snapshot readable (canary string present in libapp.so)"
      else
        bad 'AOT snapshot canary string missing; strings check is not trustworthy'
      fi
      qa_hit=0
      for marker in "${QA_MARKERS[@]}"; do
        if [[ "$(strings "$libapp" | grep -cF "$marker")" -gt 0 ]]; then
          bad "QA marker '$marker' found in libapp.so"
          qa_hit=1
        fi
      done
      if [[ "$qa_hit" -eq 0 ]]; then
        ok 'no QA-autoplay markers in the AOT snapshot (store entrypoint)'
      fi
    done <<< "$aot_paths"
  else
    bad 'no libapp.so AOT snapshots found in the AAB'
  fi
else
  printf '\n=== Android release AAB ===\n'
  bad "AAB not found at $APP_BUNDLE (run: flutter build appbundle --release --no-pub)"
fi

if [[ -d "$IOS_APP" ]]; then
  printf '\n=== iOS release .app: %s ===\n' "$IOS_APP"
  info "size: $(du -sh "$IOS_APP" | awk '{print $1}')"

  embedded_pck="$IOS_APP/property_tycoon.pck"
  [[ -f "$embedded_pck" ]] || embedded_pck="$IOS_APP/Godot/property_tycoon.pck"
  if [[ -f "$embedded_pck" ]]; then
    if [[ "$(sha256_of "$embedded_pck")" == "$(sha256_of "$IOS_PCK")" ]]; then
      ok "embedded PCK matches source pack ($(sha256_of "$embedded_pck"))"
    else
      bad 'embedded PCK hash differs from ios/Runner/Godot/property_tycoon.pck'
    fi
  else
    bad "embedded PCK missing at $embedded_pck"
  fi

  ios_plist="$IOS_APP/Info.plist"
  if [[ -f "$ios_plist" ]]; then
    ios_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ios_plist" 2>/dev/null)"
    ios_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ios_plist" 2>/dev/null)"
    if [[ "$ios_version" == "$expected_version_name" ]]; then
      ok "CFBundleShortVersionString $ios_version matches pubspec (build $ios_build)"
    else
      bad "CFBundleShortVersionString '$ios_version' does not match pubspec '$expected_version'"
    fi
    if [[ "$ios_build" == "$expected_version_code" ]]; then
      ok "CFBundleVersion $ios_build matches pubspec build number"
    else
      bad "CFBundleVersion '$ios_build' does not match pubspec '$expected_version_code'"
    fi
    if /usr/libexec/PlistBuddy -c 'Print :UIBackgroundModes' "$ios_plist" >/dev/null 2>&1; then
      bad 'UIBackgroundModes present in Info.plist (should be absent for a local-notification app)'
    else
      ok 'no UIBackgroundModes in Info.plist'
    fi
  else
    bad "Info.plist missing at $ios_plist"
  fi

  app_framework="$IOS_APP/Frameworks/App.framework/App"
  if [[ -f "$app_framework" ]]; then
    if [[ "$(strings "$app_framework" | grep -cF "$CANARY_STRING")" -gt 0 ]]; then
      ok 'AOT snapshot readable (canary string present in App.framework)'
    else
      bad 'AOT snapshot canary string missing; strings check is not trustworthy'
    fi
    qa_hit=0
    for marker in "${QA_MARKERS[@]}"; do
      if [[ "$(strings "$app_framework" | grep -cF "$marker")" -gt 0 ]]; then
        bad "QA marker '$marker' found in App.framework"
        qa_hit=1
      fi
    done
    if [[ "$qa_hit" -eq 0 ]]; then
      ok 'no QA-autoplay markers in the AOT snapshot (store entrypoint)'
    fi
  else
    bad "App.framework missing at $app_framework"
  fi

  if codesign --verify --deep --strict "$IOS_APP" >/dev/null 2>&1; then
    ok 'iOS .app code signature verifies (not App Store distribution validation)'
    info "$(codesign -dv "$IOS_APP" 2>&1 | grep -E 'TeamIdentifier|Authority' | head -2 | tr '\n' '; ')"
  else
    bad 'iOS .app code signature is missing or fails verification'
  fi
  [[ -f "$IOS_APP/embedded.mobileprovision" ]] \
    && ok 'embedded provisioning profile present (distribution eligibility not asserted)' \
    || info 'no embedded provisioning profile'
else
  printf '\n=== iOS release .app ===\n'
  bad "iOS .app not found at $IOS_APP (run: flutter build ios --release --no-pub)"
fi

printf '\n=== Result: %d passed, %d failed ===\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
