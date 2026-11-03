<img width="1000" alt="fabric generator banner 1 21 8" src="https://github.com/user-attachments/assets/23a3ec8a-6c23-4c8a-a659-08e63a0c1d8a" />

# Fabric 1.21.8 Generator for MCreator 2026.3

Generator plugin for MCreator 2026.3.44621 EAP that produces Fabric mods for Minecraft 1.21.8.

| Property | Value |
| --- | --- |
| Generator id | `generator-fabric-1.21.8` |
| Minecraft | 1.21.8 |
| Fabric Loader | 0.20.1 |
| Fabric API | 0.136.1+1.21.8 |
| Java | 25 toolchain, 21 bytecode |
| Gradle | 9.8.0 |
| Author | LitQA |
| License | CC BY-NC 4.0 |

## Layout

```
plugin.json                     Plugin metadata (id, version 2026.3-1.0.1-beta, supported MCreator versions)
LICENSE
README.md                       This document
CHANGELOG.md                    Release notes
MIGRATION-REPORT.md             Port status, 2026.3 feature status and known limitations
FEATURE-ALIGNMENT-REPORT.md     Capability gap audit against the NeoForge 26.3 generator
build.gradle, settings.gradle, gradle.properties, gradlew*, gradle/wrapper/
fabric-1.21.8/                  Fabric generator: generator.yaml, definitions, templates, procedures, triggers
fabric-1.21.8-base/datapack/    Private datapack base layer (no generator.yaml, imported by path)
fabric-1.21.8-base/neoforge/    Private NeoForge base layer (no generator.yaml, imported by path)
tools/                          Static validation, smoke test, workspace build and packaging scripts
```

The two base layers are imported through `fabric-1.21.8/generator.yaml`. They intentionally have no
`generator.yaml`, so MCreator lists only the Fabric generator. Because their paths live in the
`fabric-1.21.8-base/` namespace, they cannot collide with the `datapack-1.21.8` / `neoforge-1.21.8` paths
of another generator plugin installed by the user.

## Architecture decision: namespaced private base layers

### Background

The upstream Fabric generator imports the MCreator built-in `datapack-1.21.8` and `neoforge-1.21.8` generators.
MCreator 2026.3 no longer ships a 1.21.8 built-in generator, so this plugin must carry both base layers itself.
They are stored under `fabric-1.21.8-base/` and deliberately have no `generator.yaml`: MCreator discovers
generators by scanning for `generator.yaml`, so only `fabric-1.21.8` appears in the generator list.

### Problem

MCreator resolves plugin resources by path through one global plugin classloader:

- `YamlMerge.multiLoadYAML(...)` collects every plugin resource with the same path and merges them. Maps are
  merged recursively, lists are appended (with the adaptive merge policy), and scalar values are overridden by
  the plugin with the higher weight. `Plugin` loads higher-weight plugins first.
- `TemplateGeneratorConfiguration` uses `ClassTemplateLoader`; a template lookup returns the first matching
  resource across plugins, i.e. the one from the highest-weight plugin.
- `WorkspaceGeneratorSetup.setupWorkspaceBase()` also resolves `workspacebase` resources by path across plugins.

If this plugin kept the paths `datapack-1.21.8/` and `neoforge-1.21.8/`, installing another NeoForge 1.21.8
generator would create two writers for the same paths. Depending on weight, one side's definitions, templates,
mappings or `workspacebase` files would override or merge into the other's, causing field overrides, broken
template references, wrong Gradle setup, or cross-contamination between workspaces of different generators.

### Decision: namespace, do not merge into the Fabric generator

The base layers were moved to `fabric-1.21.8-base/datapack/` and `fabric-1.21.8-base/neoforge/`, the
`generator.yaml` imports were updated, and the plugin weight was set to 10 (the maximum recommended for a
non-core plugin). This keeps every resource in a path owned exclusively by this plugin.

Merging the two layers physically into `fabric-1.21.8/` was rejected:

| Criterion | Namespace (chosen) | Merge into `fabric-1.21.8/` |
| --- | --- | --- |
| Change size | Rename two directories and update two import entries | Resolve duplicate files across ~1,150 base files and replicate YAML merge semantics |
| Behaviour preservation | Exact: imports still resolve the same content | Risk of changing definition merges, template precedence and unused base files |
| Coexistence with other generators | Complete isolation; both plugins can use their own paths | Also isolates, but only after a high-risk rewrite |
| Maintenance | Low; paths are documented and checked by the validator/smoke test | High; every base update requires re-merging and full regression |

Coexistence was verified with a synthetic NeoForge 1.21.8 generator plugin using `weight: 12` (higher than
this plugin) and marker files under `neoforge-1.21.8/` and `datapack-1.21.8/`. Both plugins loaded, the fake
paths resolved to the fake plugin, the `fabric-1.21.8-base/*` paths resolved to this plugin, and a Fabric block
generated with both installed contained no fake content.

## Local commands

```powershell
# Parse every shipped YAML definition and Freemarker template and verify template references
pwsh plugin/tools/validate.ps1

# Package build/dist/generator-fabric-1.21.8-2026.3-1.0.1-beta.zip
pwsh plugin/tools/build-plugin.ps1

# Offline smoke test: plugin load, workspace creation and code generation through MCreator 2026.3 classes
pwsh plugin/tools/smoke-test.ps1

# Build a generated workspace with Gradle caches redirected to <repo>/caches/gradle
pwsh plugin/tools/verify-workspace.ps1 -Workspace "B:\path\to\workspace" -Tasks build
```

`validate.ps1` needs the MCreator EAP installation for its JDK and the Freemarker / SnakeYAML libraries. Pass
`-MCreatorPath` if the installation is not at the default location.

## Installation

1. Run `pwsh plugin/tools/build-plugin.ps1`.
2. Install `build/dist/generator-fabric-1.21.8-2026.3-1.0.1-beta.zip` through MCreator's plugin manager, or copy it to
   `%USERPROFILE%\.mcreator\plugins`.
3. Create a new workspace and select **Minecraft Fabric 1.21.8 Generator**.

See `MIGRATION-REPORT.md` for the full port status, implemented 2026.3 features and known limitations.
See `FEATURE-ALIGNMENT-REPORT.md` for the capability gap audit against the built-in NeoForge 26.3 generator.

## DSH Empowers Accelerated Plugin Development

<img width="1000" alt="dsh" src="https://github.com/user-attachments/assets/1b0b22c9-5213-48eb-9e51-6de70e852dec" />

This project includes code generated with **DSH (AI)** assistance.

## Credits

Generator architecture based on the MCreator NeoForge 1.21.8 generator. Fabric implementation derived from the
[Fabric-Generator-MCreator](https://github.com/Goldorion/Fabric-Generator-MCreator) project by Goldorion,
NerdyPuzzle and Spectrall.

# MCreator - Minecraft Mod Maker

[![MCreator](https://mcreator.net/image/brand/mcreator300s.png)](https://mcreator.net/)

MCreator is an open-source software used to make Minecraft Java Edition mods, Minecraft Bedrock Edition Add-Ons, resource packs, and data packs using an intuitive easy-to-learn interface or with an integrated code editor. It is used worldwide by Minecraft players, aspiring mod developers, for education, online classes, and STEM workshops. 

NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.
