# True Astronaut

A device-targeted porting project for bringing Lunaris Singularity features to Infinix Hot 30 (X6831) on ProjectInfinity-X.

## Project goal

Port every feature from the selected Lunaris source revision that can be made compatible with the target ROM/device. Features will be implemented through the safest viable layer:

1. Magisk module scripts and overlays where root-level integration is sufficient.
2. A companion privileged app/service where a user-facing control surface or persistent service is required.
3. ROM/framework integration patches where Android platform APIs, Settings resources, privileged permissions, or framework hooks are required.

A feature is not considered ported merely because a toggle is displayed. Each implementation must have a working backend, compatibility checks, and documented verification steps.

## Target device

- Device: Infinix Hot 30
- Product/device identifier reported: `Infinix-X6831`
- ROM: ProjectInfinity-X (user-reported Android 16)
- Kernel reported: `4.19.191-g5048da07dcbc-dirty`

The supplied build fingerprint reports Android 12, so the active Android release/API level must be confirmed on-device before installing release builds.

## Source baseline

- [Lunaris Singularity](https://github.com/Lunaris-AOSP/packages_apps_Singularity/tree/16.2)
- [Lunaris Settings](https://github.com/Lunaris-AOSP/packages_apps_Settings/tree/16.2)

## Safety

This project will not blindly apply undocumented kernel nodes, vendor properties, SELinux relaxations, or framework replacements. Unsupported controls will be gated or reported instead of pretending to work.

## Status

Initial repository scaffold. Feature inventory, dependency mapping, and implementation are in progress. No flashable release is claimed yet.
