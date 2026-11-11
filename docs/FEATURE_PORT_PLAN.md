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

## Feature work queue

| Singularity area | Main dependencies | Initial class | Gate before implementation |
|---|---|---|---|
| Buttons / backlight | input keylayout, SystemUI global actions, backlight driver | Unverified / ROM | Read-only device audit; trace exact node and key handling |
| Lockscreen clocks / widgets / media art | Keyguard and SystemUI APIs | ROM integration | Match ProjectInfinity-X SystemUI/framework APIs |
| UDFPS animation / icon | under-display fingerprint HAL and SystemUI | Device unsupported until proven | Confirm sensor type and biometric service |
| Sensor Block / Shake Gestures | sensor HAL, privileged service, sensor privacy | Companion / ROM | Identify sensor handles and upstream service contract |
| Idle Manager / Doze / Pickup | DeviceIdle, SystemUI Doze, sensor APIs | ROM integration | Trace receivers, permissions and service lifecycle |
| Pixel / app spoofing / integrity tools | property APIs and third-party root integrations | Unverified / high risk | No blanket spoofing or integrity bypass; require explicit safe scope |
| Notification light | notification pipeline and LED hardware | Device unsupported until proven | Confirm LED class/device and ROM notification support |
| Quick Settings layout / header | SystemUI resources and controllers | ROM integration | Match SystemUI resource IDs and overlay policy |
| Sound customization | audio policy, vendor audio HAL, mixer paths | Unverified | Inspect actual vendor config; never guess mixer controls |
| Status bar / battery bar / Dynamic Bar | SystemUI status bar and notification shade | ROM integration | Requires matching SystemUI hooks or source patch |
| Charging animation / Edge Light | SystemUI charging and screen-off animation hooks | ROM integration | Trace ROM implementation and display behavior |
| Fonts | framework font configuration / overlay | Magisk only if target supports it | Verify supported font overlay mechanism and rollback |
| Video wallpaper | WallpaperManager and wallpaper service | Companion | Package and test a compatible WallpaperService |
| Smart Pixels | panel driver / display compositor | Device unsupported until proven | Confirm panel supports pixel-off behavior |

## Current development boundary

The repository currently contains a diagnostics-only Magisk scaffold. It does not yet install feature backends, replace system APKs, change kernel nodes, alter audio mixer values, spoof properties, or broaden SELinux policy.

The read-only collector at `tools/collect-device-audit.sh` is required before hardware-facing work. Run it with root and review/redact the report before sharing it.

## Implementation order

1. Stabilize installer, packaging, shell validation and device identification.
2. Collect the X6831 audit and trace upstream Singularity controllers.
3. Implement only low-risk Magisk-compatible features with proven target support.
4. Build companion services for features that can use public Android APIs.
5. Maintain a separate ProjectInfinity-X source patch set for ROM-only features.
6. Test boot, logs, feature behavior and uninstall/rollback after each change.

## Safety rules

- No guessed sysfs paths, properties, mixer controls, key events or SELinux allow rules.
- No broad SELinux permissive mode or blanket policy grants.
- No core SystemUI/framework APK replacement as a first-line strategy.
- Never advertise an inert preference as a working feature.
- Keep unsupported features absent or explicitly marked unavailable.
