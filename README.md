# Xiaomi 14T (HyperOS 3) debloat

A fully reversible ADB debloat list, tested on a real device, with
double-click runners for Windows and Linux/macOS.

Nothing here is truly uninstalled. Every entry is undone by
[restore](#running) with one command per package.

## Running

You need `adb` once:

| OS | Install adb |
|---|---|
| Windows | [platform-tools](https://developer.android.com/tools/releases/platform-tools) from Google, unzip, put `adb.exe` in PATH (or the folder you keep the files in) |
| Linux | `sudo apt install android-tools-adb` (Debian/Ubuntu), `sudo dnf install android-tools` (Fedora), `brew install android-platform-tools` (macOS via brew tap homebrew/cask if needed) |

Then:

| OS | Debloat (apply) | Restore (undo everything) |
|---|---|---|
| Windows | double-click `debloat.bat` | double-click `restore.bat` |
| Linux/macOS | `./debloat.sh` | `./restore.sh` |

Both ask for the target once (network `IP:PORT` or a USB serial), print
one line per package, and never loop retries.

## the HyperOS disable-user lock

On HyperOS (Android 15 line) the shell user cannot flip system packages any more:

```text
SecurityException: Cannot disable system packages.
```

The reversible route that still works is a user-0-only removal:

```text
pm uninstall -k --user 0 <package>    # remove for user 0, APK and data stay
pm install-existing <package>         # one-command restore
```

`debloat.bat`/`debloat.sh` try `pm disable-user` first (so third-party entries
still get the soft route) and fall back to the user-0 removal how every list
stays reversible through `pm enable --user 0` / `pm install-existing` on
`restore.bat`/`restore.sh`.

## Safety notes

- disable and reversible user-0 removal only; snapshot nothing is un-installed for real
- lists are per-device: using another device's list can break parts you need
- read the list first; every line says what the package does
- test one entry (e.g. `com.miui.cleaner`) and use the phone a minute before the whole list
- if an entry refuses with a security exception, that device's firmware blocks
  the route — don't loop, read the section above

> tested on `degas_global`, HyperOS 3.

> See also: [debloat-mibox-s-2gen](https://github.com/DarkHoffman-stack/debloat-mibox-s-2gen) — same method for an Android TV box.
