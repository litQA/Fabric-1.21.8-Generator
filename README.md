# Fabric 1.21.8 Generator for MCreator 2026.3

Generator plugin for MCreator 2026.3.44621 EAP that produces Fabric mods for Minecraft 1.21.8.

| Property | Value |
| --- | --- |
| Generator id | `generator-fabric-1.21.8` |
| Minecraft | 1.21.8 |
| MCreator | 2026.3.44621 EAP (`202600344621`) |
| Fabric Loader | 0.20.1 |
| Fabric API | 0.136.1+1.21.8 |
| Java | 25 toolchain, 21 bytecode |
| Gradle | 9.8.0 (local distribution) |
| Author | LitQA |
| License | CC BY-NC 4.0 |

## Layout

```
plugin.json
LICENSE
fabric-1.21.8/       Fabric generator: generator.yaml, element definitions, templates, procedures, triggers
datapack-1.21.8/     Private base layer (no generator.yaml, imported by path)
neoforge-1.21.8/     Private base layer (no generator.yaml, imported by path)
tools/               Static validation and packaging scripts
```

The two base layers are imported through `fabric-1.21.8/generator.yaml`. They intentionally have no
`generator.yaml`, so MCreator lists only the Fabric generator.

## Local commands

```powershell
# Parse every shipped YAML definition and Freemarker template and verify template references
pwsh plugin/tools/validate.ps1

# Package build/dist/generator-fabric-1.21.8-<version>.zip
pwsh plugin/tools/build-plugin.ps1

# Build a generated workspace with Gradle caches redirected to <repo>/caches/gradle
pwsh plugin/tools/verify-workspace.ps1 -Workspace "B:\path\to\workspace" -Tasks build
```

`validate.ps1` needs the MCreator EAP installation for its JDK and the Freemarker / SnakeYAML libraries. Pass
`-MCreatorPath` if the installation is not at the default location.

## Installation

1. Run `pwsh plugin/tools/build-plugin.ps1`.
2. Install `build/dist/generator-fabric-1.21.8-<version>.zip` through MCreator's plugin manager, or copy it to
   `%USERPROFILE%\.mcreator\plugins`.
3. Create a new workspace and select **Minecraft Fabric 1.21.8 Generator**.

See `MIGRATION-REPORT.md` for the full port status, implemented 2026.3 features and known limitations.

## Credits

Generator architecture based on the MCreator NeoForge 1.21.8 generator. Fabric implementation derived from the
[Fabric-Generator-MCreator](https://github.com/Goldorion/Fabric-Generator-MCreator) project by Goldorion,
NerdyPuzzle and Spectrall.

This project is not official. It is not affiliated with Fabric, Minecraft, MCreator or their maintainers.
