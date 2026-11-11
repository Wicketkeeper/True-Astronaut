#!/system/bin/sh
# Read-only inventory of installed ROM components for True Astronaut.
# Run from Windows:
#   adb push collect-rom-components.sh /data/local/tmp/ta-rom-components.sh
#   adb shell su -c "sh /data/local/tmp/ta-rom-components.sh" > ta-rom-components.txt
# This script does not install, remove, or modify packages, settings, properties, or files.

section() { echo; echo "===== $1 ====="; }

section "BUILD IDENTITY"
for p in ro.build.version.release ro.build.version.sdk ro.build.fingerprint \
  ro.build.display.id ro.build.version.incremental ro.build.date.utc \
  ro.product.device ro.product.model ro.product.vendor.device ro.board.platform; do
  printf '%s=' "$p"
  getprop "$p"
done

section "CORE ROM PACKAGE INVENTORY"
pm list packages -s -f 2>/dev/null | grep -iE 'systemui|settings|lineage|infinity|lunaris|wallpaper|biometric|fingerprint|overlay' || true

section "KNOWN CORE PACKAGE PATHS"
for p in com.android.systemui com.android.settings com.android.wallpaper \
  com.android.wallpaperbackup com.android.providers.settings \
  org.lineageos.settings org.lineageos.lineagesettings \
  org.lunaris.settings; do
  echo "-- package: $p"
  pm path "$p" 2>&1
done

section "SYSTEMUI PACKAGE METADATA"
dumpsys package com.android.systemui 2>/dev/null | grep -iE \
  'Package \[|versionCode=|versionName=|codePath=|resourcePath=|primaryCpuAbi=|sharedUser=|pkgFlags=|userId=' | head -n 100

section "SETTINGS PACKAGE METADATA"
dumpsys package com.android.settings 2>/dev/null | grep -iE \
  'Package \[|versionCode=|versionName=|codePath=|resourcePath=|primaryCpuAbi=|sharedUser=|pkgFlags=|userId=' | head -n 100

section "ROM SERVICES"
service list 2>/dev/null | grep -iE 'statusbar|window|sensor|biometric|fingerprint|wallpaper|overlay|package' || true

section "OVERLAY INVENTORY"
cmd overlay list 2>/dev/null | head -n 240

section "FRAMEWORK FILE METADATA"
for f in /system/framework/framework.jar /system/framework/services.jar \
  /system/framework/framework-res.apk /system/framework/ext.jar \
  /system_ext/framework/framework.jar /system_ext/framework/services.jar \
  /system_ext/priv-app/SystemUI/SystemUI.apk \
  /system/priv-app/SystemUI/SystemUI.apk \
  /system_ext/priv-app/Settings/Settings.apk \
  /system/priv-app/Settings/Settings.apk; do
  if [ -e "$f" ]; then
    ls -lZ "$f" 2>/dev/null || ls -l "$f"
    command -v sha256sum >/dev/null 2>&1 && sha256sum "$f" 2>/dev/null
  fi
done

section "END: READ-ONLY ROM COMPONENT INVENTORY"
