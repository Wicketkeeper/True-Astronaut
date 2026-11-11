#!/system/bin/sh
MODDIR=${0%/*}
OUT=/sdcard/Download/True-Astronaut-diagnostics.txt

{
  echo "True Astronaut diagnostics"
  date
  echo
  for prop in \
    ro.product.device \
    ro.product.model \
    ro.product.name \
    ro.build.version.release \
    ro.build.version.sdk \
    ro.build.fingerprint \
    ro.system.build.fingerprint \
    ro.vendor.build.fingerprint \
    ro.boot.hardware \
    ro.board.platform
  do
    echo "$prop=$(getprop "$prop")"
  done
  echo
  echo "Kernel:"
  uname -a
  echo
  echo "Root manager:"
  magisk -v 2>/dev/null || echo "Magisk CLI unavailable"
  echo
  echo "This is a diagnostics-only development build."
} > "$OUT" 2>&1

chmod 0644 "$OUT" 2>/dev/null
ui_print "Diagnostics saved to $OUT"
