# Singularity Port Matrix

Target: Infinix X6831 (MT6768), Android 16 / API 36, arm64.
Upstream: `Lunaris-AOSP/packages_apps_Singularity`, branch `16.2`.
Scope: **Singularity only**. No additional Lunaris Settings features are in scope.

This is an implementation inventory, not a claim that the features are already ported. The upstream tree is an AOSP Settings source package: its preference screens depend on framework/SystemUI services, privileged permissions, resource overlays, and in some cases ROM-specific providers. A Magisk ZIP alone cannot recreate missing framework or SystemUI hooks.

## Source feature inventory

| Area | Upstream source files / feature groups | Likely implementation layer | Initial assessment |
|---|---|---|---|
| Buttons | `ButtonBacklightBrightness`, `Buttons`, `PowerMenuActions`, `PowerOffVerify` | Settings provider, input/keylayout, SystemUI/global actions, device kernel | Mixed. X6831 has an LCD backlight node; write access and key mappings are unverified. Power-menu actions need SystemUI support. |
| Lockscreen | Clock styles/picker, widgets, media art, Now Playing/Pulse, UDFPS animation/icon, wallpaper depth | SystemUI/Keyguard, framework overlays, Settings, fingerprint HAL | Mostly ROM/framework-dependent. No UDFPS evidence in the audit; do not assume under-display fingerprint hardware. |
| Miscellaneous | Sensor Block, Shake Gestures, Idle Manager, QuickSwitch, Pixel Props, app spoofing, Play Integrity/TrickyStore/Duck RKP/Tensor targets | Privileged services, Zygisk/root integrations, device properties, kernel sensors | Mixed and high-risk. Sensor service exists but sensor inventory was empty; hardware/module-specific checks required. |
| Notifications | Essential Notifications, notification light | SystemUI notification pipeline, notification manager, device LED hardware | ROM-dependent; audit listed backlight, flashlight and vibrator LED classes but no separate notification LED. |
| Quick Settings | QS layout, header image | SystemUI resources/plugins/overlays | Requires compatible SystemUI hooks or resource overlays; a settings toggle alone cannot add the behavior. |
| Sound | Sound customization | Audio framework, vendor audio HAL, mixer paths, audio effects | Audio HAL/policy services are present; exact mixer controls remain unknown. Never write guessed mixer paths. |
| Status Bar | Battery bar, clock, cutout progress, lyrics, Dynamic Bar/Dynamic Island, Lunaris Bar cards/editor | SystemUI status bar/notification shade/keyguard | Primarily SystemUI integration; standalone Magisk can only support compatible overlays/configuration. |
| Themes | Charging animation, forced fullscreen cutout, Doze, Edge Light, Gradient, lockscreen glimpse, Smart Pixels, video wallpaper, fonts | SystemUI, framework overlays, WallpaperManager/service, display panel/kernel | Mixed. Smart Pixels needs panel support; video wallpaper can be a companion service; Doze/edge light require SystemUI hooks. |


## Preference XML map (upstream branch 16.2)

The following XML files anchor the settings UI and help trace each preference to its backend. They are not standalone implementations.

- **Buttons:** `power_menu.xml`, `power_menu_actions.xml`, `power_off_verify.xml`
- **Lockscreen:** `clock_styles.xml`, `lockscreen_clock_preview_settings.xml`, `media_art_settings.xml`, `nowplaying_settings.xml`, `pulse_settings.xml`, `rising_settings_lockscreen_widgets.xml`, `wallpaper_depth.xml`, `lunaris_settings_udfps_custom.xml`
- **Miscellaneous:** `sensor_block_settings.xml`, `shake_settings_gestures.xml`, `quick_switch.xml`, `spoofing.xml`, `play_integrity_fix.xml`, `tricky_store.xml`, `hide_applist_prefs.xml`
- **Notifications:** `notification_light_settings.xml`, `battery_light_settings.xml`
- **Quick Settings:** `qs_layout_settings.xml`, `qs_header_image_settings.xml`
- **Status Bar:** `battery_bar.xml`, `status_bar_clock.xml`, `status_bar_lyric_settings.xml`, `cutout_progress_settings.xml`, `dynamic_bar.xml`, `dynamic_island_settings.xml`, `lunaris_bar_appearance.xml`, `lunaris_bar_card.xml`, `lunaris_bar_cards.xml`, `lunaris_bar_colors.xml`, `lunaris_bar_feature_style.xml`, `lunaris_bar_features.xml`, `lunaris_bar_gestures.xml`, `lunaris_bar_media.xml`, `lunaris_bar_motion.xml`, `lunaris_bar_preference_templates.xml`
- **Themes:** `charging_animation_settings.xml`, `doze_settings.xml`, `edge_light_settings.xml`, `gradient_settings.xml`, `lock_glymps_settings.xml`, `smart_pixels.xml`, `video_wallpaper_settings.xml`, `wallpaper_settings.xml`
- **Common:** `lunaris_settings.xml`, `lunaris_settings_button.xml`, `lunaris_settings_lock_screen.xml`, `lunaris_settings_miscellaneous.xml`, `lunaris_settings_notifications.xml`, `lunaris_settings_quick_settings.xml`, `lunaris_settings_sound.xml`, `lunaris_settings_status_bar.xml`, `lunaris_settings_themes.xml`

Additional implementation-heavy source groups:
- Doze implementation: `themes/doze/AODSchedule`, `DozeReceiver`, `DozeService`, `PickupSensor`, `ProximitySensor`, `TiltSensor`.
- Notification light UI/backend controllers: `notifications/notificationlight/*`.
- Font picker/manager: `themes/fonts/*`.
- Video wallpaper: `VideoWallpaperFragment`, `VideoWallpaperService`, `VideoWallpaperViewModel`.

## Porting rules

1. Preserve upstream feature names and behavior; do not add unrelated Settings features.
2. For each feature, identify its controller, preference XML/resource keys, Settings provider keys, framework/SystemUI receiver, service, permission, overlay, and any device node/property it uses.
3. Classify every item as:
   - **Magisk**: safe systemless configuration or boot-time operation.
   - **Companion**: requires an installed app/service with user-granted permissions.
   - **ROM/framework**: requires Settings/SystemUI/framework source integration or an overlay that the target ROM actually supports.
   - **Unsupported on device**: hardware/API absent.
4. Do not guess sysfs paths, mixer controls, property names, SELinux allow rules, or vendor interfaces. Discover and validate them on the target first.
5. Do not claim a feature works until its backend is implemented and tested on X6831.
6. Keep changes reversible and avoid replacing core SystemUI/framework APKs as a first approach.

## Device facts confirmed from user ADB output

- `ro.build.version.release=16`
- `ro.build.version.sdk=36`
- `ro.product.model=Infinix X6831`
- `ro.board.platform=mt6768`
- Kernel: `4.19.191-g5048da07dcbc-dirty`
- Reported system/vendor fingerprint still contains an Android 12 build string. Treat it as inherited vendor/system identity, not as the running Android release.
- Magisk Kitsune v30.71 is installed; the audit ran as root.
- `/sys/class/leds/lcd-backlight` exists and reports `max_brightness=3750`; the latest report shows mode `-rw-rw-rw-` and SELinux type `sysfs_backlight_file`, but no write was attempted and SELinux authorization was not established (`sesearch` unavailable). Latest brightness snapshot is `64`; an earlier snapshot was `0`.
- The LED classes listed are LCD backlight, flashlight and vibrator; no separate notification LED was listed.
- Sensor and fingerprint services exist, but standard and extended sensor dumps were empty despite a running MTK Sensors 2.0 multihal service and `ro.vendor.mtk.sensor.support=yes`; fingerprint binaries for generic 2.1, FocalTech and Silead are present, but active HAL and placement/UDFPS capability were not established.
- Vendor audio HAL and policy services run, but `audio_effects.xml` declares equalizer, bassboost, virtualizer and DTS effects, but `tinymix`/`amixer` are absent and mixer control names or safe tuning values remain unknown.
- MTK key input devices exist; input modaliases were captured, but no matching device-specific keylayout mapping was established.

## Read-only target audit

The diagnostic collector at `tools/collect-device-audit.sh` has been run on the X6831. It only reads properties, service lists, sensor information, and selected sysfs/vendor configuration metadata; it does not write settings or alter the device.

Three read-only audit reports have been collected, including a follow-up with extended sensorservice commands, SELinux process context, input modaliases and audio effect declarations. Sensor inventory remains empty; the latest backlight value is a snapshot only. Use targeted read-only checks to close open evidence gaps before implementing backlight, sensor, UDFPS, Doze, Smart Pixels, key or audio features.

## Next audit / implementation sequence

- [ ] Read every feature controller and its referenced preference XML/string/resource keys.
- [ ] Trace settings keys and calls into SystemUI/framework/vendor services.
- [ ] Targeted read-only check: backlight node permissions, current brightness, SELinux context and safe supported write interface (do not change brightness during audit).
- [ ] Targeted read-only check: obtain a real sensor inventory from HAL/service diagnostics and establish active fingerprint HAL and sensor placement/type.
- [ ] Read actual keylayout mappings for detected physical key devices.
- [ ] Inspect vendor audio policy/effects and available mixer controls without writing values.
- [ ] Build a feature-by-feature compatibility report with exact upstream source references.
- [ ] Implement safe Magisk-backed items first, then companion-service items.
- [ ] Keep ROM/framework-only items documented as requiring a matching ProjectInfinity-X source patch; do not simulate them with inert toggles.

## Build boundary

The current repository is an early Magisk scaffold. It is not yet a complete Singularity port and should not be presented as a release-ready feature pack. Magisk's supported module model provides systemless files, boot scripts, properties, and narrowly scoped SELinux rules; it does not automatically provide the privileged Settings/SystemUI APIs used by upstream Singularity.
