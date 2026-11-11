#!/system/bin/sh

ui_print " "
ui_print "****************************************"
ui_print "        TRUE ASTRONAUT"
ui_print "****************************************"
ui_print " "

DEVICE="$(getprop ro.product.device)"
PRODUCT="$(getprop ro.product.name)"
API="$(getprop ro.build.version.sdk)"
RELEASE="$(getprop ro.build.version.release)"

ui_print "- Device: ${DEVICE:-unknown}"
ui_print "- Product: ${PRODUCT:-unknown}"
ui_print "- Android release: ${RELEASE:-unknown}"
ui_print "- API level: ${API:-unknown}"

case "$DEVICE" in
  Infinix-X6831|X6831) ;;
  *)
    ui_print "! Warning: this build targets Infinix Hot 30 (X6831)."
    ui_print "! Installation will continue in diagnostics-only mode."
    ;;
esac

if [ -z "$API" ] || [ "$API" -lt 31 ]; then
  ui_print "! Android API could not be verified or is below 31."
  ui_print "! No platform modifications will be applied."
fi

ui_print "- Installing development scaffold only."
ui_print "- No undocumented kernel nodes or SELinux grants are applied."
ui_print " "
