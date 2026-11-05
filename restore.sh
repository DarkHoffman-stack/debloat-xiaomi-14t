#!/bin/bash
# Restore the debloat applied on a Xiaomi 14T (HyperOS 3).
# usage: DEVICE=<serial> bash restore.sh
set -euo pipefail
LIST="$(dirname "$0")/debloat.txt"
DEV="${DEVICE:?set DEVICE=<serial>}"
ADB="${ADB:-adb}"
tr -d '\r' < "$LIST" | grep -vE '^\s*(#|$)' | while read -r raw; do
  pkg=$(echo "$raw" | awk '{print $1}' | sed 's/\s*#.*//')
  [ -z "$pkg" ] && continue
  from=$(tr -d '\r' < "$LIST" | grep -F "$pkg" | head -1)
  case "$from" in
    *com.amazon.appmanager*|*cn.wps.xiaomi.abroad.lite*)
      echo "$pkg -> $($ADB -s "$DEV" shell "pm enable --user 0 $pkg" 2>&1 | tr -d '\r')"
      ;;
    *)
      # user-0 removal, restore via install-existing
      echo "$pkg -> $($ADB -s "$DEV" shell "pm install-existing $pkg" 2>&1 | tr -d '\r')"
      ;;
  esac
done
