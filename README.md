# Xiaomi 14T (HyperOS 3)

Device under test: `degas_global`, HyperOS 3. USB debugging enabled through
Settings → About → tap "OS version" seven times → Additional settings →
Developer options → USB debugging.

## The HyperOS lock on disable-user

From HyperOS (Android 15 line) the shell user may no longer flip system packages:

```
SecurityException: Cannot disable system packages.
```

Two third-party installs still accepted `pm disable-user --user 0`
(`com.amazon.appmanager`, `cn.wps.xiaomi.abroad.lite`); every Xiaomi system entry refused it.

The reversible route that still works for system packages is
[position 0 data-only removal](https://github.com/Gathin23/cleanyourtv/issues):

```bash
adb shell "pm uninstall -k --user 0 <package>"   # remove for user 0, keep data/APK
adb shell "pm install-existing <package>"        # single-command restore
```

This is not a real uninstall: the APK stays on the device, per-user data is kept,
and `pm install-existing` brings the package back for any user. Round-trip tested.

## debloat.txt

17 packages: the ones in the file, `pm uninstall -k --user 0` for the system
entries plus `pm disable-user --user 0` for the two third-party ones
(both work for those). One per shell call.

Kept by owner's choice: Facebook/Messenger/Instagram, Mi Cloud (`micloudsync`,
`cloudservice`), `com.xiaomi.finddevice`, `com.xiaomi.payment` (NFC),
`com.xiaomi.mirror`/`mishare`/`mi_connect_service` (HyperConnect),
camera tools, gallery, `com.xiaomi.xmsf` (Xiaomi push).

## Undo

```bash
DEVICE=<serial> tools/restore.sh debloat.txt
```

## Notes

- `com.xiaomi.discover` is the GetApps feed pusher; owners who rely on
  GetApps-driven notifications may keep it.
- The in-source AI image stack (`aiasst.vision`, `aicr`, `aiservice`) is only
  verified to boot fine without them on `degas_global` HyperOS 3; other models
  may wire gallery features differently, so test before keeping them disabled.
