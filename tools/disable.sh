#!/bin/bash
# Apply a debloat list to an Android device over ADB, one pm command per call.
# entries may be bare <package> (tested as: disable if third-party possible, else user-0 removal)
# usage: DEVICE=<serial-or-ip:port> tools/disable.sh path/to/list.txt
set -euo pipefail
LIST="$(dirname "$0")/../$(basename "$1" 2>/dev/null)"; [ -f "$LIST" ] || LIST="$1"
[ -f "$LIST" ] || { echo "usage: DEVICE=<serial> tools/disable.sh path/to/list.txt" >&2; exit 1; }
DEV="${DEVICE:?set DEVICE=<serial> or <ip:port>}"
ADB="${ADB:-adb}"
tr -d '\r' < "$LIST" | grep -vE '^\s*(#|$)' | while read -r raw; do
  pkg=$(echo "$raw" | awk '{print $1}')
  [ -z "$pkg" ] && continue
  # try the softest reversible path first: disable-user
  out=$($ADB -s "$DEV" shell "pm disable-user --user 0 $pkg" 2>&1 | tr -d '\r')
  case "$out" in
    *disabled-user*) echo "✓ disabled: $pkg";;
    *)
      # HyperOS/Android 15 route: remove for user 0 only (fully restorable)
      out2=$($ADB -s "$DEV" shell "pm uninstall -k --user 0 $pkg" 2>&1 | tr -d '\r')
      case "$out2" in
        *Success*) echo "✓ user-0 removed: $pkg";;
        *) echo "✗ $pkg -> $out2";;
      esac
      ;;
  esac
done
