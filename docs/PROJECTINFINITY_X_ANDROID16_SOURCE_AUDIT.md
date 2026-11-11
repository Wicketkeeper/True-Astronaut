# ProjectInfinity-X Android 16 Source Compatibility Audit

Target ROM reported by device owner: ProjectInfinity-X Android 16 / API 36 on Infinix X6831.
Scope: inspect the public Android 16 build manifest and identify the exact source repositories that own Settings, framework, and SystemUI-related code. This is source mapping, not proof that a feature is present in the installed device build.

## Verified manifest facts

Source manifest: [ProjectInfinity-X/manifest, branch 16](https://github.com/ProjectInfinity-X/manifest/tree/16)
Files inspected:
- [default.xml](https://github.com/ProjectInfinity-X/manifest/blob/16/default.xml)
- [snippets/infinity.xml](https://github.com/ProjectInfinity-X/manifest/blob/16/snippets/infinity.xml)

The default manifest sets the common Android base revision to LineageOS `lineage-23.2` and includes `snippets/infinity.xml`.

The Infinity snippet defines:
- remote `infinity`: GitHub `https://github.com/ProjectInfinity-X`, revision `16`
- remote `lfs`: Gitea `https://gitea.com/projectInfinity-x`, revision `16`

Relevant source ownership:
| Source path in ROM tree | Manifest repository | Remote / branch | Meaning |
|---|---|---|---|
| `frameworks/base` | `frameworks_base` | Gitea remote `lfs`, revision `16` | Framework and the in-tree SystemUI app implementation |
| `packages/apps/Settings` | `packages_apps_Settings` | Gitea remote `lfs`, revision `16` | ROM Settings application and its custom preference fragments |
| `frameworks/libs/systemui` | `frameworks_libs_systemui` | GitHub remote `infinity`, revision `16` | Shared SystemUI libraries, not by itself the SystemUI app renderer |
| `lineage-sdk` | `custom-sdk` | GitHub remote `infinity`, revision `16` | Lineage-derived platform APIs used by Settings integrations |
| `infinity-sdk` | `prebuilts_infinity-sdk` | GitHub remote `infinity`, revision `16` | Infinity SDK API surface |

The default manifest's upstream LineageOS entries for `frameworks/base`, `frameworks/libs/systemui`, and `packages/apps/Settings` are commented out; the Infinity snippet supplies the active replacements. This matters: auditing only LineageOS upstream would miss ProjectInfinity-X's actual custom forks.

## What was checked and what remains unverified

- The ProjectInfinity-X GitHub repository `frameworks_libs_systemui` has a branch named `16`; its repository tree was inspected. This is a shared library repository, not sufficient to conclude whether Battery Bar or Dynamic Bar rendering is implemented.
- The active ProjectInfinity-X Settings and frameworks/base repositories are hosted on Gitea according to the manifest. Their source contents were not successfully retrieved in this audit, so no claim is made that a specific Singularity preference key or renderer exists there.
- The device's installed ROM package contents have not been dumped or compared against these exact source commits. A public manifest mapping alone cannot prove the installed build came from an identical source revision.
- The ROM's exact build fingerprint is not reliable as a source commit identifier; the device audit reported a legacy-looking fingerprint while Android release/API report 16/36.

## Implications for the Singularity port

1. A proper compatibility check must inspect the ProjectInfinity-X branch-16 `packages_apps_Settings` and `frameworks_base` Gitea repositories, not just AOSP/LineageOS sources.
2. For Battery Bar and Dynamic Bar, search the ProjectInfinity-X framework/SystemUI app source for the actual setting keys and rendering consumers. A matching Settings UI alone is not enough.
3. For Sensor Block, inspect the ProjectInfinity-X SensorService implementation and the Global setting consumers before considering any UI.
4. For button backlight, verify the Lineage/Infinity device resource flags and actual physical key-backlight hardware. The existing X6831 audit only proves an LCD panel backlight node.
5. Until these consumers are verified, keep the Magisk module diagnostics-only. Do not write speculative settings, properties, sysfs nodes, overlays, or SELinux rules.

## Build validation

The True-Astronaut source-trace documentation commit `ed0186e5a7ccb90983c110cbbe98e0d53a0ec9f8` completed GitHub Actions Build #26 successfully. This validates the module packaging workflow only; it does not validate runtime Singularity features on the phone.
