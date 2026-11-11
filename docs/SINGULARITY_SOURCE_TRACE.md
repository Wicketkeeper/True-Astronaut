# Singularity Source Trace — X6831

Target: Infinix X6831 / MT6768 / Android 16 (API 36).
Upstream: [Lunaris-AOSP/packages_apps_Singularity, branch 16.2](https://github.com/Lunaris-AOSP/packages_apps_Singularity/tree/16.2).
This document records source-backed behavior and porting boundaries. It does not claim these features work on the target ROM.

## Findings from controller + preference source

| Feature | Upstream backend contract | Port classification | X6831 decision |
|---|---|---|---|
| Button backlight brightness | `ButtonBacklightBrightness` uses LineageOS platform resource flags `config_deviceSupportsButtonBrightnessControl` / `config_deviceSupportsKeyboardBrightnessControl`. Brightness is stored through `LineageSettings.Secure.BUTTON_BRIGHTNESS` / `KEYBOARD_BRIGHTNESS`; button-only-when-pressed uses `LineageSettings.System.BUTTON_BACKLIGHT_ONLY_WHEN_PRESSED`; timeout uses `LineageSettings.Secure.BUTTON_BACKLIGHT_TIMEOUT`. | ROM/framework + device resource + kernel driver | **Do not map this to the LCD backlight sysfs node.** The X6831 audit only established an LCD panel backlight node, not physical navigation-button or keyboard backlight hardware. No Magisk implementation is justified. |
| Sensor Block | UI stores app package names in `Settings.Global.SENSOR_BLOCKED_APP` (pipe-separated) and resets `Settings.Global.SENSOR_BLOCK`. | Framework SensorService integration + Settings UI | **ROM/framework-only.** The preference writes configuration; it does not itself filter sensor events. The X6831 sensor inventory is still unknown, so do not expose an inert toggle. |
| Shake Gestures | The fragment loads `shake_settings_gestures.xml`; this fragment itself does not implement gesture recognition. | Depends on the preference XML's backend and ROM gesture service | **Unclassified pending full XML/backend trace.** Do not create guessed properties or scripts. |
| QuickSwitch | Reads `persist.sys.default_launcher`; checks `persist.sys.quickswitch_pixel_shipped`; toggles overlay `com.android.system.qs.wallpaperoverlay` and prompts for SystemUI restart. | ROM property + prebuilt overlay + system restart path | **Not a generic Magisk feature.** Must confirm that the target ROM ships the overlay and its expected property contract before changing anything. |
| Battery Bar | Preference XML writes System settings: `statusbar_battery_bar`, `statusbar_battery_bar_thickness`, `statusbar_battery_bar_style`, color/blend/animation/charging keys. Controller is only a Settings preference fragment. | SystemUI consumer + Settings UI | **ROM/SystemUI-only unless ProjectInfinity-X already implements the consumer.** Writing these settings alone will not draw a bar. |
| Dynamic Bar | Uses Secure settings `ax_dynamic_bar_enabled`, `ax_dynamic_bar_keyguard_enabled`, `ax_dynamic_bar_events`, `ax_dynamic_bar_compact_notifications`, and `ax_dynamic_bar_keyguard_battery_chip_mode`. UI updates event JSON and observes settings changes. | SystemUI feature implementation + Settings UI | **ROM/SystemUI-only.** The settings keys are configuration, not the Dynamic Bar renderer. Do not write them as a substitute for the SystemUI code. |
| Doze gestures | `DozeService` checks tilt, pickup and proximity sensor availability via utility methods; creates sensor wrappers and registers screen on/off receiver; enables/disables listeners based on Secure-setting switches. | Companion/ROM service + working sensor HAL and sensor types | **Blocked on hardware evidence.** X6831 sensorservice dumps are empty; vendor multihal presence alone does not prove required sensors exist or are enumerable. |
| Video Wallpaper | `VideoWallpaperService` extends Android `WallpaperService`; it owns a wallpaper engine, media file lifecycle, playback speed and pause-on-lock behavior. | Companion app/service + wallpaper binding/manifest integration | **Not a shell-script feature.** Requires an installed APK with a declared wallpaper service and user selection through WallpaperManager. |
| Fonts | `FontManager` uses ThemeUtils / OverlayManager categories `android.theme.customization.font` and `android.theme.customization.lockscreen_clock_font`. | Runtime resource overlays + Theme/OverlayManager support | **Potentially companion/overlay-based**, but only if the target ROM supports the same overlay categories and has valid font overlay APKs. No evidence yet that X6831's current ROM exposes this integration. |
| Notification Light | XML uses LineageOS SystemSetting preferences and custom per-app notification-light preferences. | SystemUI/notification-light framework + compatible notification LED hardware | **Unsupported on currently observed hardware unless another notification-capable LED is found.** Audit listed LCD backlight, flashlight and vibrator classes, not a separate notification LED. Do not repurpose the LCD backlight. |

## Key source references

- [ButtonBacklightBrightness.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/buttons/ButtonBacklightBrightness.java)
- [SensorBlock.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/miscellaneous/SensorBlock.java)
- [ShakeGestures.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/miscellaneous/ShakeGestures.java)
- [QuickSwitch.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/miscellaneous/QuickSwitch.java)
- [BatteryBar.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/statusbar/BatteryBar.java)
- [DynamicBar.kt](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/statusbar/DynamicBar.kt)
- [DozeService.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/themes/doze/DozeService.java)
- [VideoWallpaperService.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/themes/VideoWallpaperService.java)
- [FontManager.java](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/src/org/lunaris/settings/fragments/themes/fonts/FontManager.java)
- [sensor_block_settings.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/sensor_block_settings.xml)
- [dynamic_bar.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/dynamic_bar.xml)
- [battery_bar.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/battery_bar.xml)
- [doze_settings.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/doze_settings.xml)
- [notification_light_settings.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/notification_light_settings.xml)
- [video_wallpaper_settings.xml](https://github.com/Lunaris-AOSP/packages_apps_Singularity/blob/16.2/res/xml/video_wallpaper_settings.xml)

## Implementation gate

Before adding a feature to the Magisk ZIP, require all of:
1. A concrete upstream backend contract (settings key, service, overlay, framework hook, or device interface).
2. Evidence that the X6831 ProjectInfinity-X build contains that backend or that a safe standalone companion implementation is possible.
3. A reversible implementation and validation plan.
4. No guessed sysfs nodes, mixer controls, system properties, SELinux rules, or privileged settings writes.

## Current outcome

No feature in this trace qualifies for a safe Magisk-only implementation yet. This is a useful negative result: it prevents packaging settings that merely change values without any ROM component consuming them. Next, inspect ProjectInfinity-X's actual Settings/SystemUI/framework source or installed package resources to identify already-present consumers. Keep the module diagnostics-only until that compatibility check is complete.
