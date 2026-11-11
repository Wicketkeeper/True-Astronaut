#!/system/bin/sh
# Focused, read-only follow-up for True Astronaut X6831 porting.
# Run:
#   adb push tools/collect-x6831-capabilities.sh /sdcard/Download/ta-capabilities.sh
#   adb shell su -c "sh /sdcard/Download/ta-capabilities.sh" > x6831-capabilities.txt
# This script does not write sysfs nodes, settings, properties, or permissions.

section() { echo; echo "===== $1 ====="; }
read_file() {
  [ -r "$1" ] && { echo "-- $1"; cat "$1" 2>/dev/null; }
}
list_meta() {
  [ -e "$1" ] && { echo "-- $1"; ls -ldZ "$1" 2>/dev/null || ls -ld "$1"; }
}

section "IDENTITY / SECURITY"
getprop ro.product.model
getprop ro.product.device
getprop ro.build.version.release
getprop ro.build.version.sdk
getprop ro.board.platform
getprop ro.lunaris.display.version
getenforce 2>/dev/null
id

section "BACKLIGHT READ-ONLY CAPABILITY"
for f in /sys/class/leds/lcd-backlight /sys/class/leds/lcd-backlight/brightness \
  /sys/class/leds/lcd-backlight/max_brightness /sys/class/leds/lcd-backlight/actual_brightness \
  /sys/class/leds/lcd-backlight/type /sys/class/leds/lcd-backlight/trigger \
  /sys/class/leds/lcd-backlight/uevent; do
  list_meta "$f"
  [ -f "$f" ] && read_file "$f"
done

section "SENSOR INVENTORY"
echo "-- dumpsys sensorservice"
dumpsys sensorservice 2>&1 | head -n 260
echo "-- service list"
service list 2>/dev/null | grep -i sensor || true
echo "-- vendor sensor HAL init"
ls -lZ /vendor/etc/init/android.hardware.sensors* 2>/dev/null || true

section "FINGERPRINT CAPABILITY (NO BIOMETRIC DATA)"
service list 2>/dev/null | grep -iE 'fingerprint|biometric' || true
dumpsys fingerprint 2>&1 | head -n 160
dumpsys biometric 2>&1 | head -n 160
ls -lZ /vendor/bin/hw/*fingerprint* /vendor/lib64/hw/*fingerprint* 2>/dev/null || true
getprop | grep -iE 'udfps|fingerprint.*(type|position|location)|biometric' | head -n 100

section "PHYSICAL INPUT / KEYLAYOUT"
cat /proc/bus/input/devices 2>/dev/null
for d in /vendor/usr/keylayout /odm/usr/keylayout /system/usr/keylayout; do
  [ -d "$d" ] || continue
  echo "-- keylayout directory: $d"
  ls -l "$d" 2>/dev/null
  grep -HnE '^(key|axis) ' "$d"/*.kl 2>/dev/null | head -n 240
done

section "AUDIO READ-ONLY INVENTORY"
command -v tinymix >/dev/null 2>&1 && { echo "-- tinymix controls (read-only)"; tinymix 2>&1 | head -n 260; } || echo "tinymix not found"
command -v amixer >/dev/null 2>&1 && { echo "-- amixer controls (read-only)"; amixer controls 2>&1 | head -n 160; } || echo "amixer not found"
echo "-- audio policy dump"
dumpsys media.audio_policy 2>&1 | head -n 240
echo "-- audio config files"
for f in /vendor/etc/audio_policy_configuration.xml /vendor/etc/audio_effects.xml \
  /vendor/etc/audio_policy.conf /vendor/etc/mixer_paths.xml /vendor/etc/mixer_paths_mt6768.xml; do
  [ -f "$f" ] && { ls -l "$f"; grep -nE 'mixPort|devicePort|path name=|ctl name=|<effect|<library' "$f" | head -n 160; }
done

section "END: READ-ONLY FOLLOW-UP"
