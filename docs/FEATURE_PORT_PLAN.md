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
| Backlight | `/sys/class/leds/lcd-backlight` exists; `max_brightness=3750`; `brightness` is `-rw-rw-rw-` with SELinux type `sysfs_backlight_file`; captured brightness was `0` | DAC mode bits permit writes, but no write was attempted and SELinux authorization from the Magisk service domain is not proven. The captured `0` is only a snapshot. Do not write until a controlled, reversible runtime test is designed. |
| LED devices | `lcd-backlight`, `led_flashlight`, and `vibrator` appear under `/sys/class/leds`; no separate notification LED node was listed | Notification-light feature remains unsupported/unverified on this evidence; flashlight/backlight are not notification LEDs. |
| Sensors | `sensorservice` and a vendor Sensors 2.0 multihal init service are present, but the captured `dumpsys sensorservice` section is empty | Hardware sensor inventory/handles remain unknown. Do not enable Sensor Block, Shake, Pickup, or sensor-driven Doze based only on service presence. |
| Biometrics | Fingerprint and biometric services are present; vendor fingerprint 2.1, FocalTech and Silead service/binary files are listed; `persist.sys.udfps.custom=false` | Fingerprint stack components exist, but the active HAL and sensor placement/type are not established. Treat UDFPS animation/icon as unsupported unless under-display hardware is independently confirmed. |
| Display / refresh | Lunaris display version property and refresh-rate list `60,90,120,144` are reported | Existing ROM display integration is present, but it does not prove Singularity Dynamic Bar, Smart Pixels, or other feature hooks. |
| Input | `mtk-kpd`, `tran-keys`, and touchscreen input devices are listed; the report contains Generic.kl mappings but does not identify a device-specific mapping for the physical key devices | Physical key/backlight action mapping remains unverified. |
| Audio | Vendor audio policy/effects files list playback/input ports and effects (including equalizer, bassboost and DTS); `tinymix` and `amixer` are absent | Audio framework effects are declared, but runtime mixer controls and a safe tuning interface remain unknown. No mixer writes. |
| ROM components | SystemUI, Lineage Settings, Lunaris-related display property, wallpaper services and overlays are present | These are clues only. Feature-specific SystemUI/framework hooks and exact APIs still require source-level matching. |
| Device tree / vendor init | MTK device-tree entries and vendor init services are present | No specific Singularity feature support can be inferred from generic MTK nodes or service files. |

### Audit limitations

The sensor dump was empty and the biometric dump did not establish the active fingerprint HAL or sensor placement. The backlight node has world-writable DAC mode bits, but the collector did not attempt a write and did not establish SELinux authorization or safe control behavior. Input devices were listed and Generic.kl entries were emitted, but no device-specific physical-key mapping was established. Audio configuration declares ports/effects, but `tinymix`/`amixer` are unavailable and runtime mixer controls remain unknown. These are open evidence gaps, not proof that the corresponding hardware is absent.

## Feature work queue

| Singularity area | Main dependencies | Current class after audit | Gate before implementation |
|---|---|---|---|
| Buttons / backlight | input keylayout, SystemUI global actions, backlight driver | Backlight node and DAC write bits confirmed; SELinux/runtime control and key mapping unverified / ROM for UI | Design a reversible, user-confirmed write test with read-back and restore; identify physical key mapping; trace exact controller |
| Lockscreen clocks / widgets / media art | Keyguard and SystemUI APIs | ROM integration | Match ProjectInfinity-X SystemUI/framework APIs |
| UDFPS animation / icon | under-display fingerprint HAL and SystemUI | Unsupported unless UDFPS is confirmed | Confirm sensor location/type and biometric service |
| Sensor Block / Shake Gestures | sensor HAL, privileged service, sensor privacy | Unverified / ROM | Obtain non-empty sensor inventory and identify handles/service contract |
| Idle Manager / Doze / Pickup | DeviceIdle, SystemUI Doze, sensor APIs | ROM integration / sensor-dependent | Trace receivers, permissions, sensor handles and service lifecycle |
| Pixel / app spoofing / integrity tools | property APIs and third-party root integrations | Unverified / high risk | No blanket spoofing or integrity bypass; require explicit safe scope |
| Notification light | notification pipeline and LED hardware | No separate notification LED observed | Recheck actual hardware/ROM support before considering implementation |
| Quick Settings layout / header | SystemUI resources and controllers | ROM integration | Match SystemUI resource IDs and overlay policy |
| Sound customization | audio policy, vendor audio HAL, mixer paths | Unverified | Inspect actual vendor config and runtime controls; never guess mixer values |
| Status bar / battery bar / Dynamic Bar | SystemUI hooks | ROM integration | Requires matching SystemUI hooks or source patch |
| Charging animation / Edge Light | SystemUI hooks | ROM integration | Trace ROM implementation and display behavior |
| Fonts | framework font configuration / overlay | Magisk only if target supports it | Verify supported font overlay mechanism and rollback |
| Video wallpaper | WallpaperManager and wallpaper service | Companion | Package and test a compatible WallpaperService |
| Smart Pixels | panel driver / display compositor | Unverified / likely ROM+panel dependent | Confirm panel and compositor support for pixel-off behavior |

## Current development boundary

The repository contains a diagnostics-only Magisk scaffold. It does not yet install feature backends, replace system APKs, change kernel nodes, alter audio mixer values, spoof properties, or broaden SELinux policy.

The X6831 read-only audit has been collected. Hardware-facing work is now narrowed by the evidence above; unresolved sensor inventory, active fingerprint HAL/placement, SELinux backlight write authorization and runtime behavior, device-specific key mapping, and audio mixer controls must be measured before implementation.

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
