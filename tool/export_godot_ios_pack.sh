#!/usr/bin/env bash
set -euo pipefail

flutter_project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace_dir="$(cd "$flutter_project_dir/.." && pwd)"
godot_project_dir="$flutter_project_dir/godot_3d"
godot_binary="${GODOT_IOS_BINARY:-$workspace_dir/.tools/Godot-4.6.3.app/Contents/MacOS/Godot}"
pack_output="$flutter_project_dir/ios/Runner/Godot/property_tycoon.pck"

if [[ ! -x "$godot_binary" ]]; then
  echo "Godot executable not found: $godot_binary" >&2
  echo "Set GODOT_IOS_BINARY to a Godot 4.6.x executable." >&2
  exit 1
fi

mkdir -p "$(dirname "$pack_output")"
"$godot_binary" \
  --headless \
  --path "$godot_project_dir" \
  --export-pack "Android Embedded Pack" \
  "$pack_output"

echo "Updated $pack_output"
