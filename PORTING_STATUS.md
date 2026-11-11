# Porting status

This file tracks real implementations, not UI-only placeholders.

| Area | Current state | Next work |
|---|---|---|
| Source inventory | In progress | Enumerate Singularity screens, controllers, services, resources and dependencies |
| Settings integration | Not started | Map Lunaris Settings references and identify ROM-only APIs |
| Magisk backend | Scaffold only | Implement verified device-supported controls individually |
| Companion app | Not started | Determine required privileged APIs and feasible app integration |
| SELinux | Not started | Add only narrowly scoped rules proven necessary |
| Installer | Basic development scaffold | Add packaging and compatibility tests |
| Device validation | Pending | Confirm actual Android API, ROM build, kernel and root manager on target device |

## Implementation rules

- Never claim a feature works because its preference or toggle is visible.
- Every feature needs a backend, capability detection, error handling and a verification method.
- Do not apply guessed sysfs nodes, vendor properties, kernel interfaces or broad SELinux allow rules.
- Keep unsupported controls disabled with a clear reason.
- Framework-dependent features may require a rebuilt ROM component or a compatible hook/service; root alone does not recreate missing framework APIs.
