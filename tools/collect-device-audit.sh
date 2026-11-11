#!/system/bin/sh
# Read-only hardware / framework inventory for True Astronaut.
# Run: adb push collect-device-audit.sh /data/local/tmp/
#      adb shell su -c sh /data/local/tmp/collect-device-audit.sh
# This script does not change settings, permissions, properties, or files on /system.

section() { echo; echo "===== $1 ====="; }

section "BUILD"
for p in ro.build.version.release ro.build.version.sdk ro.build.version.security_patch \
  ro.product.model ro.product.device ro.product.vendor.device ro.board.platform \
  ro.hardware ro.boot.hardware ro.boot.product.hardware.sku ro.bootmode \
  ro.system.build.fingerprint ro.vendor.build.fingerprint ro.bootimage.build.fingerprint; do
  printf '%s=' "$p"
  getprop "$p"
done
uname -a
id

section "ROOT / MAGISK"
command -v magisk >/dev/null 2>&1 && magisk -v || echo "magisk binary not in PATH"
command -v su >/dev/null 2>&1 && su -v 2>&1 | head -n 2

section "RELEVANT SERVICES"
service list 2>/dev/null | grep -iE 'fingerprint|biometric|sensor|light|display|power|audio|wallpaper|statusbar|notification' || true

section "SENSORS"
dumpsys sensorservice 2>/dev/null | head -n 180

section "FINGERPRINT / BIOMETRIC"
dumpsys biometric 2>/dev/null | head -n 120
dumpsys fingerprint 2>/dev/null | head -n 120
getprop | grep -iE 'fingerprint|udfps|biometric' | head -n 100

section "DISPLAY / PANEL / BACKLIGHT"
getprop | grep -iE 'display|panel|brightness|refresh|resolution|density' | head -n 140
for d in /sys/class/backlight /sys/class/leds /sys/class/graphics /sys/class/drm; do
  if [ -d "$d" ]; then
    echo "-- $d"
    ls -la "$d" 2>/dev/null
  fi
done
for f in /sys/class/backlight/*/max_brightness /sys/class/backlight/*/type \
  /sys/class/leds/*/max_brightness /sys/class/leds/*/trigger; do
  [ -f "$f" ] && { echo "-- $f"; cat "$f" 2>/dev/null; }
done

section "INPUT DEVICES"
for f in /proc/bus/input/devices /vendor/usr/keylayout/* /system/usr/keylayout/*; do
  [ -f "$f" ] && { echo "-- $f"; if [ "$f" = /proc/bus/input/devices ]; then cat "$f"; else ls -l "$f"; fi; }
done

section "AUDIO"
getprop | grep -iE 'audio|mixer|sound|codec' | head -n 160
dumpsys media.audio_policy 2>/dev/null | head -n 180
for d in /vendor/etc /odm/etc; do
  [ -d "$d" ] && find "$d" -maxdepth 3 -type f 2>/dev/null | grep -iE 'audio.*(policy|mixer)|mixer.*paths|audio_effects' | head -n 100
done

section "SYSTEMUI / WALLPAPER / NOTIFICATION CONFIG"
pm list packages -s 2>/dev/null | grep -iE 'systemui|wallpaper|settings|lineage|lunaris' || true
getprop | grep -iE 'doze|aod|ambient|notification.*light|light.*notification' | head -n 120

section "DEVICE TREE / VENDOR MODULE HINTS"
for d in /sys/firmware/devicetree/base /vendor/etc/init /odm/etc/init; do
  [ -d "$d" ] && { echo "-- $d"; ls -la "$d" 2>/dev/null | head -n 100; }
done

echo
echo "===== END: READ-ONLY AUDIT ====="
