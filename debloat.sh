#!/bin/bash
# debloat from this device's debloat list (one pm command per call).
# requires: adb in PATH (apt install android-tools-adb / brew install android-platform-tools)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
list="$HERE/debloat.txt"
if [ -n "${DEVICE:-}" ]; then DEV="$DEVICE"; else
  read -r -p "Device (IP:PORT for network adb, or USB serial): " DEV
fi
case "$DEV" in
  */*|\#*) echo "bad device given: $DEV" >&2; exit 1;;
  *.*|*:*) type=network ;;
  *) type=usb ;;
esac
if [ "$type" = network ]; then
  adb -s "$DEV" start-server >/dev/null 2>&1 || true
  connected=$(adb devices | grep -F "$DEV" || true)
  if [ -z "$connected" ]; then
    echo "connecting to $DEV ... (accept the prompt on the device screen!)"
    adb connect "$DEV"
  fi
fi
adb -s "$DEV" shell true 2>&1 | head -1 || true
echo "=== $kind on $DEV ==="
tr -d '\r' < "$list" | grep -vE '^\s*(#|$)' | while IFS= read -r raw; do
  pkg=$(echo "$raw" | awk '{print $1}')
  [ -z "$pkg" ] && continue
  echo "- $pkg"
  if [ "debloat" = "debloat" ]; then
    out=$(adb -s "$DEV" shell "pm disable-user --user 0 $pkg" 2>&1 | tr -d '\r')
    case "$out" in *disabled-user*) echo "  -> disabled" ;;
      *) out2=$(adb -s "$DEV" shell "pm uninstall -k --user 0 $pkg" 2>&1 | tr -d '\r')
         case "$out2" in *Success*) echo "  -> user-0 removed (restorable)" ;;
           *) echo "  FAILED: $out2" ;; esac ;; esac
  else
    out=$(adb -s "$DEV" shell "pm install-existing $pkg" 2>&1 | tr -d '\r') ; case "$out" in
      *installed*|*Success*) echo "  -> restored" ;;
      *) out2=$(adb -s "$DEV" shell "pm enable --user 0 $pkg" 2>&1 | tr -d '\r')
         case "$out2" in *enabled*) echo "  -> enabled" ;;
           *) echo "  FAILED: $out2" ;; esac ;; esac
  fi
done
echo "Done."
