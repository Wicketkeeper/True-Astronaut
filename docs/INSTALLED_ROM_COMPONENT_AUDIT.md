# Installed ROM Component Audit

This read-only follow-up inventories the actual Settings, SystemUI, framework and overlay components installed on the X6831. It complements the hardware capability audit; it does not decompile APKs or prove that a Singularity backend exists.

## Run from Windows

Download the script from the working branch, then run:

```bat
adb push collect-rom-components.sh /data/local/tmp/ta-rom-components.sh
adb shell su -c "sh /data/local/tmp/ta-rom-components.sh" > ta-rom-components.txt
```

If the script is in the repository's `tools` directory locally, use its local path in the first command:

```bat
adb push tools/collect-rom-components.sh /data/local/tmp/ta-rom-components.sh
```

Upload `ta-rom-components.txt` back to the project chat for analysis.

## What it collects

- Android release/API, ROM display/build identifiers and device identity.
- System package paths for SystemUI, Settings, wallpaper, biometric and ROM Settings packages.
- Installed SystemUI and Settings version metadata.
- Relevant Binder services and active overlay inventory.
- Metadata and SHA-256 hashes for common framework and privileged APK paths, when present.

## Safety and limits

The collector is read-only: it does not change settings, properties, permissions, overlays, packages, or files. It does not collect personal app data, biometric templates, accounts, or user files.

Package names and file paths can vary by ROM. Missing paths are not proof that a component is absent; the package path output is the authoritative starting point for any later pull/decompile step. Hashes identify the exact installed artifacts for comparison, but do not reveal their source code.