# Singularity Port Matrix

Target: Infinix X6831 (MT6768), Android 16 / API 36, arm64.
Upstream: `Lunaris-AOSP/packages_apps_Singularity`, branch `16.2`.
Scope: **Singularity only**. No additional Lunaris Settings features are in scope.

This is an implementation inventory, not a claim that the features are already ported. The upstream tree is an AOSP Settings source package: its preference screens depend on framework/SystemUI services, privileged permissions, resource overlays, and in some cases ROM-specific providers. A Magisk ZIP alone cannot recreate missing framework or SystemUI hooks.

## Source feature inventory

| Area | Upstream source files / feature groups | Likely implementation layer | Initial assessment |
|---|---|---|---|
| Buttons | `ButtonBacklightBrightness`, `Buttons`, `PowerMenuActions`, `PowerOffVerify` | Settings provider, input/keylayout, SystemUI/global actions, device kernel | Mixed. Backlight node and key support must be discovered on X6831; power-menu actions need SystemUI support. |
| Lockscreen | Clock styles/picker, widgets, media art, Now Playing/Pulse, UDFPS animation/icon, wallpaper depth | SystemUI/Keyguard, framework overlays, Settings, fingerprint HAL | Mostly ROM/framework-dependent. UDFPS-specific items may not apply unless this device has an under-display sensor. |
| Miscellaneous | Sensor Block, Shake Gestures, Idle Manager, QuickSwitch, Pixel Props, app spoofing, Play Integrity/TrickyStore/Duck RKP/Tensor targets | Privileged services, Zygisk/root integrations, device properties, kernel sensors | Mixed and high-risk. Hardware- and module-specific checks required; no blanket spoofing or integrity bypass is assumed. |
| Notifications | Essential Notifications, notification light | SystemUI notification pipeline, notification manager, device LED hardware | ROM-dependent; notification-light feature depends on actual LED hardware and vendor implementation. |
| Quick Settings | QS layout, header image | SystemUI resources/plugins/overlays | Requires compatible SystemUI hooks or resource overlays; a settings toggle alone cannot add the behavior. |
| Sound | Sound customization | Audio framework, vendor audio HAL, mixer paths, audio effects | Requires inspection of X6831 audio policy/HAL; never write guessed mixer paths. |
| Status Bar | Battery bar, clock, cutout progress, lyrics, Dynamic Bar/Dynamic Island, Lunaris Bar cards/editor | SystemUI status bar/notification shade/keyguard | Primarily SystemUI integration; standalone Magisk can only support compatible overlays/configuration. |
| Themes | Charging animation, forced fullscreen cutout, Doze, Edge Light, Gradient, lockscreen glimpse, Smart Pixels, video wallpaper, fonts | SystemUI, framework overlays, WallpaperManager/service, display panel/kernel | Mixed. Smart Pixels needs panel support; video wallpaper can be a companion service; Doze/edge light require SystemUI hooks. |

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

## Next audit / implementation sequence

- [ ] Read every feature controller and its referenced preference XML/string/resource keys.
- [ ] Trace settings keys and calls into SystemUI/framework/vendor services.
- [ ] Inspect target device hardware: fingerprint type, notification LED, display panel, backlight, audio HAL, sensor list, keylayout, sysfs.
- [ ] Build a feature-by-feature compatibility report with exact upstream source references.
- [ ] Implement safe Magisk-backed items first, then companion-service items.
- [ ] Keep ROM/framework-only items documented as requiring a matching ProjectInfinity-X source patch; do not simulate them with inert toggles.

## Build boundary

The current repository is an early Magisk scaffold. It is not yet a complete Singularity port and should not be presented as a release-ready feature pack. Magisk's supported module model provides systemless files, boot scripts, properties, and narrowly scoped SELinux rules; it does not automatically provide the privileged Settings/SystemUI APIs used by upstream Singularity.
