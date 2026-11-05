#!/bin/bash
# Restore every entry in a debloat list (enable-user, else install-existing).
# usage: DEVICE=<serial-or-ip:port> tools/restore.sh path/to/list.txt
set -euo pipefail
LIST="$(dirname "$0")/../$(basename "$1" 2>/dev/null)"; [ -f "$LIST" ] || LIST="$1"
[ -f "$LIST" ] || { echo "usage: DEVICE=<serial> tools/restore.sh path/to/list.txt" >&2; exit 1; }
DEV="${DEVICE:?set DEVICE=<serial> or <ip:port>}"
ADB="${ADB:-adb}"
tr -d '\r' < "$LIST" | grep -vE '^\s*(#|$)' | while read -r raw; do
  pkg=$(echo "$raw" | awk '{print $1}')
  [ -z "$pkg" ] && continue
  out=$($ADB -s "$DEV" shell "pm enable --user 0 $pkg" 2>&1 | tr -d '\r')
  case "$out" in
    *enabled-user*) echo "✓ enabled: $pkg";;
    *)
      out2=$($ADB -s "$DEV" shell "pm install-existing $pkg" 2>&1 | tr -d '\r')
      case "$out2" in
        *installed*|*Success*) echo "✓ restored: $pkg";;
        *) echo "✗ $pkg -> $out2";;
      esac
      ;;
  esac
done
