#!/system/bin/sh
MODDIR=${0%/*}
LOGDIR=/data/adb
LOG="$LOGDIR/true_astronaut.log"

# Late-start service: collect diagnostics only; do not block boot or alter tuning.
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 2
done

{
  echo "===== True Astronaut diagnostics ====="
  date
  for prop in \
    ro.product.device \
    ro.product.model \
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
  echo "======================================"
} >> "$LOG" 2>&1

chmod 0600 "$LOG" 2>/dev/null
