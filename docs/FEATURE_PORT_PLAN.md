# True Astronaut — Singularity Port Plan

Target: Infinix X6831 (MT6768), ProjectInfinity-X Android 16 / API 36.
Upstream reference: `Lunaris-AOSP/packages_apps_Singularity`, branch `16.2`.
Scope: Singularity features only.

## Release gates

A feature is not marked implemented merely because its preference exists. Each feature must have:
1. A traced upstream controller and exact setting/provider keys.
2. A supported backend on this ROM/device.
3. Capability detection and a safe unsupported state.
4. Reversible behavior and error handling.
5. A device test with a recorded result.

## Portability classes

- **Magisk** — systemless files or boot-time configuration that the target ROM already supports.
- **Companion** — a separately installed app/service with documented Android permissions.
- **ROM integration** — requires Settings, SystemUI, framework, privileged permission, overlay, or vendor source changes.
- **Device unsupported** — required hardware/API is absent.
- **Unverified** — source or device evidence is not yet sufficient.

## X6831 audit evidence (2026-11-11)

Collected from the running ProjectInfinity-X Android 16 / API 36 device with root. The collector is read-only.

| Area | Observed evidence | Porting consequence |
|---|---|---|
| Device / OS | Infinix X6831, MT6768, Android 16, SDK 36, arm64, Linux 4.19.191 | Target identity confirmed. The system/vendor fingerprints contain an Android 12 string; do not mistake that inherited fingerprint for the running OS version. |
| Root | Magisk Kitsune v30.71; audit ran as uid 0 in Magisk SELinux domain | Magisk module installation is viable; this does not grant missing framework/SystemUI APIs. |
| Backlight | `/sys/class/leds/lcd-backlight` exists; `max_brightness=3750`; `brightness` is `-rw-rw-rw-` with SELinux type `sysfs_backlight_file`; latest follow-up captured brightness was `64` (an earlier audit snapshot read `0`) | DAC mode bits permit writes, but no write was attempted and SELinux authorization from the Magisk service domain is not proven. The captured `0` is only a snapshot. Do not write until a controlled, reversible runtime test is designed. |
| LED devices | `lcd-backlight`, `led_flashlight`, and `vibrator` appear under `/sys/class/leds`; no separate notification LED node was listed | Notification-light feature remains unsupported/unverified on this evidence; flashlight/backlight are not notification LEDs. |
| Sensors | `sensorservice` and a vendor Sensors 2.0 multihal init service are present, but both standard and extended `dumpsys sensorservice` sections are empty; `cmd sensorservice help` exposes UID-state commands only. The vendor Sensors 2.0 multihal service is running and `ro.vendor.mtk.sensor.support=yes`, but no sensor handles were enumerated | Hardware sensor inventory/handles remain unknown. Do not enable Sensor Block, Shake, Pickup, or sensor-driven Doze based only on service presence. |
| Biometrics | Fingerprint and biometric services are present; vendor fingerprint 2.1, FocalTech and Silead service/binary files are listed; `persist.sys.udfps.custom=false`; the report does not identify the active HAL | Fingerprint stack components exist, but the active HAL and sensor placement/type are not established. Treat UDFPS animation/icon as unsupported unless under-display hardware is independently confirmed. |
| Display / refresh | Lunaris display version property and refresh-rate list `60,90,120,144` are reported | Existing ROM display integration is present, but it does not prove Singularity Dynamic Bar, Smart Pixels, or other feature hooks. |
| Input | `mtk-kpd`, `tran-keys`, and touchscreen input devices are listed; event modaliases are captured (`mtk-kpd` vendor 2454/product 6500 and `tran-keys`), but no matching device-specific keylayout mapping is established; `mtk-tpd.kl` is present but its mapping is not verified | Physical key/backlight action mapping remains unverified. |
| Audio | Vendor audio policy/effects files list playback/input ports and effects (including equalizer, bassboost and DTS); `tinymix` and `amixer` are absent; `audio_effects.xml` declares equalizer, bassboost, virtualizer, loudness enhancer, dynamics processing and DTS audio | Audio framework effects are declared, but runtime mixer controls and a safe tuning interface remain unknown. No mixer writes. |
| ROM components | SystemUI, Lineage Settings, Lunaris-related display property, wallpaper services and overlays are present | These are clues only. Feature-specific SystemUI/framework hooks and exact APIs still require source-level matching. |
| Device tree / vendor init | MTK device-tree entries and vendor init services are present | No specific Singularity feature support can be inferred from generic MTK nodes or service files. |

### Audit limitations

Both standard and extended sensor dumps were empty; `cmd sensorservice help` only exposed UID-state commands. The MTK sensor HAL service/property are present but no inventory was enumerated. The biometric report lists Android fingerprint service and generic 2.1, FocalTech and Silead components, but does not establish the active HAL or sensor placement. The latest backlight snapshot reads `64` (earlier snapshot `0`); the node has world-writable DAC mode bits, but no write was attempted. The shell context is `u:r:magisk:s0`; `sesearch` is unavailable, so SELinux authorization remains unknown. Input event modaliases were captured, but no matching device-specific physical-key mapping was established; `mtk-tpd.kl` was listed without a verified mapping. Audio policy/effects declare ports and effects (including equalizer, bassboost and DTS), but `tinymix`/`amixer` are unavailable and runtime mixer controls remain unknown. These are open evidence gaps, not proof that the corresponding hardware is absent.

## Feature work queue

| Singularity area | Main dependencies | Current class after audit | Gate before implementation |
|---|---|---|---|
| Buttons / backlight | LineageOS device resource flags, `DeviceKeysConstants`, `LineageSettings` secure/system keys, input/keylayout and device backlight driver | ROM integration for the Singularity UI/controller; X6831 hardware backlight node exists, but it is not evidence of a Lineage button-backlight backend | Confirm `config_deviceSupportsButtonBrightnessControl`, hardware-key resource flags, and the matching Lineage provider/driver implementation in ProjectInfinity-X. Do not map the LCD backlight node to button brightness |
| Lockscreen clocks / widgets / media art | Keyguard and SystemUI APIs | ROM integration | Match ProjectInfinity-X SystemUI/framework APIs |
| UDFPS animation / icon | under-display fingerprint HAL and SystemUI | Unsupported unless UDFPS is confirmed | Confirm sensor location/type and biometric service |
| Sensor Block / Shake Gestures | SensorService framework filtering, `Settings.Global` keys, sensor HAL and privileged Settings integration | ROM integration / unverified on X6831 | Sensor Block UI writes `SENSOR_BLOCK` and `SENSOR_BLOCKED_APP`; actual per-app blocking needs framework SensorService support. Obtain non-empty sensor inventory and trace the framework implementation before considering it |
| Idle Manager / Doze / Pickup | framework config resources, SystemUI `doze.pulse` broadcast, Secure Settings, SensorManager and sensor-specific resources | ROM integration / sensor-dependent | Singularity Doze service checks `config_dozePulseTilt/Pickup/Proximity`, registers sensor listeners and reacts to screen state; confirm target resource flags, sensors, service permission/lifecycle and SystemUI receiver |
| Pixel / app spoofing / integrity tools | property APIs and third-party root integrations | Unverified / high risk | No blanket spoofing or integrity bypass; require explicit safe scope |
| Notification light | notification pipeline and LED hardware | No separate notification LED observed | Recheck actual hardware/ROM support before considering implementation |
| Quick Settings layout / header | SystemUI resources and controllers | ROM integration | Match SystemUI resource IDs and overlay policy |
| Sound customization | audio policy, vendor audio HAL, mixer paths | Unverified | Inspect actual vendor config and runtime controls; never guess mixer values |
| Status bar / battery bar / Dynamic Bar | SystemUI rendering/event listeners plus Secure Settings contract | ROM integration | Dynamic Bar preferences use `ax_dynamic_bar_enabled`, `ax_dynamic_bar_keyguard_enabled`, `ax_dynamic_bar_events`, compact-notification and battery-chip keys; matching SystemUI consumers are required |
| Charging animation / Edge Light | SystemUI hooks | ROM integration | Trace ROM implementation and display behavior |
| Fonts | framework font configuration / overlay | Magisk only if target supports it | Verify supported font overlay mechanism and rollback |
| Video wallpaper | WallpaperManager and wallpaper service | Companion | Package and test a compatible WallpaperService |
| Smart Pixels | panel driver / display compositor | Unverified / likely ROM+panel dependent | Confirm panel and compositor support for pixel-off behavior |

## Current development boundary

The repository contains a diagnostics-only Magisk scaffold. It does not yet install feature backends, replace system APKs, change kernel nodes, alter audio mixer values, spoof properties, or broaden SELinux policy.

The X6831 read-only audits have been collected. The follow-up collector now additionally tries `dumpsys sensorservice -a` / `cmd sensorservice help`, records the current SELinux domain and an optional read-only `sesearch` query for backlight write permission, and matches input event vendor/product IDs to exact keylayout filenames when available. These new checks are pending a fresh device report; they do not write to the device. Hardware-facing work remains blocked on unresolved sensor inventory, active fingerprint HAL/placement, SELinux backlight authorization/runtime behavior, device-specific key mapping, and audio mixer controls. The latest report records input modaliases and the Magisk SELinux process context, but not the missing authorizations or mappings.

## Implementation order

1. Stabilize installer, packaging, shell validation and device identification.
2. Trace upstream Singularity controllers and exact Settings/provider/framework dependencies.
3. Close the remaining X6831 evidence gaps for candidate hardware-facing features.
4. Implement only low-risk Magisk-compatible features with proven target support.
5. Build companion services for features that can use public Android APIs.
6. Maintain a separate ProjectInfinity-X source patch set for ROM-only features.
7. Test boot, logs, feature behavior and uninstall/rollback after each change.

## Safety rules

- No guessed sysfs paths, properties, mixer controls, key events or SELinux allow rules.
- No broad SELinux permissive mode or blanket policy grants.
- No core SystemUI/framework APK replacement as a first-line strategy.
- Never advertise an inert preference as a working feature.
- Keep unsupported features absent or explicitly marked unavailable.


## Upstream controller trace (Singularity 16.2)

This pass traced controller code and preference XML in `Lunaris-AOSP/packages_apps_Singularity`. It establishes what the upstream UI expects; it does **not** establish that ProjectInfinity-X contains the corresponding backend.

### Buttons / backlight

- `Buttons.java` builds its button controls from device resource flags such as `config_deviceHardwareKeys` and `config_deviceHardwareWakeKeys`; it does not infer hardware keys from arbitrary input-device names.
- `DeviceUtils.hasButtonBacklightSupport()` requires `config_deviceSupportsButtonBrightnessControl` and at least one supported hardware-key bit (home/back/menu/assist/app-switch).
- `ButtonBacklightBrightness` uses LineageOS provider settings: `LineageSettings.Secure.BUTTON_BRIGHTNESS` and `LineageSettings.System.BUTTON_BACKLIGHT_ONLY_WHEN_PRESSED`. The keyboard path separately uses `KEYBOARD_BRIGHTNESS` and `config_deviceSupportsKeyboardBrightnessControl`.
- Therefore the X6831 LCD panel node `/sys/class/leds/lcd-backlight` is **not** a valid substitute for the LineageOS button-backlight provider/driver. The device audit did not establish capacitive/navigation backlight hardware or its mapping.

### Sensor Block

- `sensor_block_settings.xml` exposes a `GlobalSettingMainSwitchPreference` with key `sensor_block`.
- `SensorBlock.java` stores the per-app package list in `Settings.Global.SENSOR_BLOCKED_APP`; reset also writes `Settings.Global.SENSOR_BLOCK`.
- The Settings UI and Global keys only represent the control surface. Per-app sensor suppression requires a matching framework SensorService implementation that reads those keys and filters sensor delivery. A Magisk service that merely writes the keys would be an inert toggle on a ROM without that framework consumer.
- X6831's audit still has no usable sensor inventory, so no app-level sensor feature is enabled.

### Shake / Doze / Pickup

- The current `ShakeGestures.java` fragment only loads its preference XML; the source inspected here does not establish a standalone Magisk backend.
- Singularity's Doze `Utils` reads framework resource flags `config_dozePulseTilt`, `config_dozePulsePickup`, and `config_dozePulseProximity`, plus Secure Settings such as `DOZE_TILT_GESTURE`, `DOZE_PICK_UP_GESTURE`, `DOZE_HANDWAVE_GESTURE`, `DOZE_POCKET_GESTURE`, and `RAISE_TO_WAKE_GESTURE`.
- `DozeService` starts only when supported sensor resources and enabled settings allow it; it listens for screen on/off and registers Tilt, Pickup and Proximity listeners. Those listeners use Android SensorManager, PowerManager/wakelocks and SystemUI's `com.android.systemui.doze.pulse` broadcast.
- These are service + framework resource + SystemUI dependencies, not a boot script alone. X6831's empty sensor dump leaves actual sensor support unverified.

### Dynamic Bar

- `dynamic_bar.xml` defines the main Secure Setting `ax_dynamic_bar_enabled` and related keyguard, compact-notification and event preferences.
- `DynamicBar.kt` persists `ax_dynamic_bar_keyguard_enabled`, `ax_dynamic_bar_events`, `ax_dynamic_bar_compact_notifications`, and `ax_dynamic_bar_keyguard_battery_chip_mode`; event IDs include media, call, notification, timer, charging, torch and biometric unlock.
- The fragment only persists preference state. The actual Dynamic Bar visuals and event behavior need corresponding SystemUI code to observe those settings and render/update the bar. Writing the keys from Magisk cannot add that missing consumer.

### Port decision from this trace

No feature above is promoted to implemented. First viable work remains limited to features whose complete consumer/backend already exists on ProjectInfinity-X and can be safely configured systemlessly. Buttons, Sensor Block, Doze gestures and Dynamic Bar remain ROM-integration work until the target ROM's matching resources, providers, framework hooks and SystemUI consumers are verified.
