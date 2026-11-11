# Porting status

This file tracks verified implementations, not UI-only placeholders.

| Area | Current state | Next work |
|---|---|---|
| Source inventory | Baseline mapped | Trace each upstream controller and dependency |
| Feature plan | Added | Validate classes against upstream source and X6831 audit |
| Installer / packaging | Development foundation | Run CI and test install/uninstall on target |
| Device audit | Read-only collector available | Collect and review X6831 report |
| Settings integration | Not started | Map Lunaris Settings references and ROM-only APIs |
| Magisk backend | Diagnostics only | Implement only verified, reversible device controls |
| Companion app | Not started | Identify features that can use documented Android APIs |
| ROM integration | Not started | Prepare ProjectInfinity-X patches for SystemUI/framework features |
| SELinux | Not started | Add only narrowly scoped rules proven necessary |
| Device validation | Pending | Test on X6831 Android 16 / API 36 |

## Current build status

The development ZIP is a diagnostics-only scaffold. It does not yet provide Lunaris Singularity feature functionality. The installer identifies the device/API and the late-start service writes a local diagnostic log; no guessed sysfs writes, audio tuning, property spoofing, framework replacement, or broad SELinux rules are applied.

## Required next input

Run `tools/collect-device-audit.sh` as root on the X6831 and share the reviewed report. Redact serial numbers and other private identifiers first. Hardware-facing work (backlight, LEDs, sensors, fingerprint, Doze, Smart Pixels and audio) must wait for that evidence.

## Implementation rules

- Every feature needs a traced upstream controller, backend, capability detection, error handling and verification method.
- Do not claim a feature works because its preference or toggle is visible.
- Do not apply guessed sysfs nodes, vendor properties, kernel interfaces, mixer values or broad SELinux allow rules.
- Keep unsupported controls absent or disabled with a clear reason.
- Framework-dependent features require compatible ProjectInfinity-X source integration or a demonstrably supported hook; root alone does not recreate missing framework APIs.
