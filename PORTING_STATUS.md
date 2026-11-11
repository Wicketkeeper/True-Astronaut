# Porting status

This file tracks verified implementations, not UI-only placeholders.

| Area | Current state | Next work |
|---|---|---|
| Source inventory | Baseline mapped | Trace each upstream controller and dependency |
| Feature plan | Updated with X6831 audit evidence | Close remaining hardware evidence gaps |
| Installer / packaging | Development foundation | Run CI and test install/uninstall on target |
| Device audit | Collected 2026-11-11 | Inspect backlight write access, sensor inventory, key mappings and audio controls |
| Settings integration | Not started | Map Lunaris Settings references and ROM-only APIs |
| Magisk backend | Diagnostics only | Implement only verified, reversible device controls |
| Companion app | Not started | Identify features that can use documented Android APIs |
| ROM integration | Not started | Prepare ProjectInfinity-X patches for SystemUI/framework features |
| SELinux | Not started | Add only narrowly scoped rules proven necessary |
| Device validation | Pending | Test on X6831 Android 16 / API 36 |

## Current build status

The development ZIP is a diagnostics-only scaffold. It does not yet provide Lunaris Singularity feature functionality. The installer identifies the device/API and the late-start service writes a local diagnostic log; no guessed sysfs writes, audio tuning, property spoofing, framework replacement, or broad SELinux rules are applied.

## X6831 audit findings

The read-only audit confirms Infinix X6831 / MT6768, Android 16 / API 36, arm64, and Magisk Kitsune v30.71. It found an LCD backlight node at `/sys/class/leds/lcd-backlight` with a reported maximum of 3750, but did not establish writable access or safe runtime control. The listed LED classes were LCD backlight, flashlight, and vibrator; no separate notification LED was listed.

Sensor and biometric services exist, but the sensor dump was empty and fingerprint sensor placement was not established. Vendor audio services/configuration exist, but mixer controls were not identified. See `docs/FEATURE_PORT_PLAN.md` for the evidence table and limitations.

## Implementation rules

- Every feature needs a traced upstream controller, backend, capability detection, error handling and verification method.
- Do not claim a feature works because its preference or toggle is visible.
- Do not apply guessed sysfs nodes, vendor properties, kernel interfaces, mixer values or broad SELinux allow rules.
- Keep unsupported controls absent or disabled with a clear reason.
- Framework-dependent features require compatible ProjectInfinity-X source integration or a demonstrably supported hook; root alone does not recreate missing framework APIs.
