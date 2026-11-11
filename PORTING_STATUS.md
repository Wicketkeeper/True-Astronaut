# Porting status

This file tracks verified implementations, not UI-only placeholders.

| Area | Current state | Next work |
|---|---|---|
| Source inventory | Upstream Singularity 16.2 controllers traced for Buttons/backlight, Sensor Block, Shake/Doze and Dynamic Bar | Match required LineageOS resources/providers, framework SensorService and SystemUI consumers against ProjectInfinity-X source |
| Feature plan | Updated with X6831 audit evidence | Close remaining hardware evidence gaps |
| Installer / packaging | Development foundation | Run CI and test install/uninstall on target |
| Device audit | Two read-only reports collected; extended collector now checks alternate sensor dumps, optional SELinux policy query and device-ID-matched keylayouts | Run the updated read-only collector and close remaining sensor, fingerprint-placement, backlight authorization, key mapping and audio-control gaps |
| Settings integration | Dependency map started; no ROM patch yet | Verify target resource flags, LineageSettings provider implementation, SensorService keys/filters and Dynamic Bar SystemUI consumer |
| Magisk backend | Diagnostics only | Implement only verified, reversible device controls |
| Companion app | Not started | Identify features that can use documented Android APIs |
| ROM integration | Not started | Prepare ProjectInfinity-X patches for SystemUI/framework features |
| SELinux | Not started | Add only narrowly scoped rules proven necessary |
| Device validation | Pending | Test on X6831 Android 16 / API 36 |

## Latest upstream trace

The Singularity 16.2 source pass confirms that Buttons/backlight depends on LineageOS hardware-key resource flags and `LineageSettings` provider keys; Sensor Block needs a framework SensorService consumer for `SENSOR_BLOCK` / `SENSOR_BLOCKED_APP`; Doze gestures depend on framework sensor resource flags, Secure Settings, a sensor-listener service and SystemUI's doze-pulse broadcast; Dynamic Bar needs SystemUI code consuming its `ax_dynamic_bar_*` Secure Settings. These are not delivered by writing settings from a Magisk boot script. The X6831 LCD backlight node is not assumed to be a button-backlight device.

No Singularity feature is implemented or device-tested yet. The source trace is recorded in `docs/FEATURE_PORT_PLAN.md`.

## Current build status

The development ZIP is a diagnostics-only scaffold. It does not yet provide Lunaris Singularity feature functionality. The installer identifies the device/API and the late-start service writes a local diagnostic log; no guessed sysfs writes, audio tuning, property spoofing, framework replacement, or broad SELinux rules are applied.

## X6831 audit findings

The read-only audits confirm Infinix X6831 / MT6768, Android 16 / API 36, arm64, and Magisk Kitsune v30.71. The LCD backlight node reports `max_brightness=3750`; its `brightness` file has `-rw-rw-rw-` mode and SELinux type `sysfs_backlight_file`, but no write was attempted and SELinux authorization/runtime behavior are unproven. The captured brightness value was `0`. The listed LED classes were LCD backlight, flashlight, and vibrator; no separate notification LED was listed.

Sensor service exists but its inventory dump was empty. Fingerprint services and FocalTech/Silead components are present, but the active HAL and sensor placement were not established. Physical input devices were listed without a device-specific key mapping. Vendor audio policy/effects declare supported ports and effects, but `tinymix` and `amixer` are unavailable, so runtime mixer controls remain unknown. See `docs/FEATURE_PORT_PLAN.md` for the evidence table and limitations.

## Implementation rules

- Every feature needs a traced upstream controller, backend, capability detection, error handling and verification method.
- Do not claim a feature works because its preference or toggle is visible.
- Do not apply guessed sysfs nodes, vendor properties, kernel interfaces, mixer values or broad SELinux allow rules.
- Keep unsupported controls absent or disabled with a clear reason.
- Framework-dependent features require compatible ProjectInfinity-X source integration or a demonstrably supported hook; root alone does not recreate missing framework APIs.
