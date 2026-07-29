#!/usr/bin/env bash
set -euo pipefail

flutter_project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace_dir="$(cd "$flutter_project_dir/.." && pwd)"
godot_project_dir="$flutter_project_dir/godot_3d"
godot_binary="${GODOT_BINARY:-$workspace_dir/.tools/Godot.app/Contents/MacOS/Godot}"
pack_output="$flutter_project_dir/android/app/src/main/assets/godot/property_tycoon.pck"

if [[ ! -x "$godot_binary" ]]; then
  echo "Godot executable not found: $godot_binary" >&2
  echo "Set GODOT_BINARY to a Godot 4.7.1 executable." >&2
  exit 1
fi

mkdir -p "$(dirname "$pack_output")"
"$godot_binary" \
  --headless \
  --path "$godot_project_dir" \
  --export-pack "Android Embedded Pack" \
  "$pack_output"

echo "Updated $pack_output"
