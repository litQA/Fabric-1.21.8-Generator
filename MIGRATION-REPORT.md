# Migration Report — Fabric 1.21.8 Generator for MCreator 2026.3 (EAP 2026344621)

## 1. Scope and baseline

| Item | Value |
| --- | --- |
| Baseline generator | Fabric-Generator-MCreator 1.21.8 / 2026.1-2.6.1 (upstream, `fabric-1.21.8`) |
| Target MCreator | 2026.3.44621 EAP (`202600344621`), plugin `supportedversions` `[202600344621, 202600399999]` |
| Generator id | `generator-fabric-1.21.8` |
| Minecraft | 1.21.8 |
| Fabric Loader | 0.20.1 |
| Fabric API | 0.136.1+1.21.8 |
| Java | 25 toolchain (MCreator JDK 25), 21 bytecode (`options.release = 21`) |
| Gradle | 9.8.0, local `file:///` distribution |
| License | CC BY-NC 4.0 |
| Version | 2026.3-1.0.1-beta |

Reference material used during the port:

- MCreator 2026.1 built-in `generator-1.21.8` (NeoForge 1.21.8, datapack 1.21.8, resourcepack 1.21.8).
- MCreator 2026.1 and 2026.3 built-in `generator-1.21.1` (the authoritative 2026.1 → 2026.3 delta for a
  1.21.x generator).
- Upstream Fabric-Generator-MCreator `26.3-2026.3-2.9-beta` (Fabric implementations of the 2026.3 features
  for Minecraft 26.3, used where the loader-specific code could be translated to 1.21.8 APIs).
- MCreator 2026.3 source tree (`DefinitionsProvider`, `Generator`, `FragmentsUtils`, `GeneratorConfiguration`,
  `GeneratorFile`, `UserFolderManager`) to verify the new definition, fragment and template semantics.

## 2. Plugin architecture

The upstream Fabric generator imports the built-in `datapack-1.21.8` and `neoforge-1.21.8` generators. MCreator
2026.3 no longer ships a 1.21.8 built-in generator, so the plugin now ships both layers privately, under a
namespace that belongs to this plugin only:

```
plugin.json
LICENSE
fabric-1.21.8/                     # the Fabric generator (generator.yaml, definitions, templates, procedures, triggers)
fabric-1.21.8-base/datapack/       # private base layer, no generator.yaml -> not listed as a generator
fabric-1.21.8-base/neoforge/       # private base layer, no generator.yaml -> not listed as a generator
```

`fabric-1.21.8/generator.yaml` imports `fabric-1.21.8-base/datapack` and `fabric-1.21.8-base/neoforge` with
`procedures` and `triggers` excluded. MCreator resolves imported files by path, so the base layers work without
being registered as selectable generators. Only `fabric-1.21.8` appears in the generator list.

The `fabric-1.21.8-base/` prefix is deliberately unique. MCreator resolves plugin resources globally by path
(the plugin classloader and `YamlMerge` merge resources with the same path across all installed plugins), so
keeping the base files at `datapack-1.21.8` / `neoforge-1.21.8` would have collided with any other NeoForge
1.21.8 generator plugin: its definitions and templates would be merged with ours, and our 2026.1-era
`workspacebase` could override its build files (and vice versa). The namespaced paths make the two base layers
private to this plugin. The plugin weight was also reduced from 11 to 10, the maximum recommended by the
MCreator plugin API for non-core plugins.

The base layers were updated to the 2026.3 format by a three-way merge: files that were identical between the
2026.1 1.21.1 and 1.21.8 generators were replaced with the 2026.3 1.21.1 version; files that differ between
Minecraft 1.21.1 and 1.21.8 were merged manually or kept at their 1.21.8 implementation. All NeoForge-specific
templates in `fabric-1.21.8-base/neoforge` are unreachable from the Fabric generator; generated Fabric code
contains no `net.neoforged` imports, annotations or capability code.

## 3. 2026.3 breaking changes handling

### 3.1 `types` map and base types

MCreator 2026.3 always populates the FreeMarker `types` map with every mod element type (as a possibly empty
list) and uses the `base_<plural>` key format for base-type collections. The old `types["base:blocks"]`
format no longer resolves, and `types["particles"]??` is now always true. `templates/modbase/mod.java.ftl` and
`templates/modbase/mod_client.java.ftl` were converted to `types.<name>?has_content` checks, and base types
are declared in the element definitions:

- item, tool, armor → `item`
- block, plant → `block`, `item` (conditional), `configuredfeature` (conditional), `blockentity` (conditional)
- fluid → `block`, `item` (conditional)
- livingentity → `entity`, `item` (spawn egg), `enumextension` (raider)
- projectile → `entity`
- specialentity → `item`, `enumextension`, `dispensebehavior`
- dimension → `block` (portal), `item` (igniter)
- feature → `configuredfeature`, `feature`
- itemextension → `dispensebehavior`

`common.features.yaml` was added so `base_features` is populated and `Features.load()` runs when blocks, plants
or features generate worldgen content. Existing `common.blocks.yaml`, `common.items.yaml`, `common.entities.yaml`
and `common.blockentities.yaml` are used for the remaining base types.

### 3.2 YAML definitions and merging

Definition files keep the 2026.3 `field_exclusions` semantics. New 2026.3 fields that this generator does not
implement are excluded instead of being silently ignored:

- `block.definition.yaml`: `multipartModel` excluded (multipart states are not implemented, see limitations).
- `dimension.definition.yaml`: custom skybox / sun / moon fields excluded (26.x render pipeline feature).
- `loottable.definition.yaml`: loot modifier fields excluded (NeoForge data-map feature).
- `specialentity.definition.yaml`: `onPlayerCollidesWith` excluded.
- `biome.definition.yaml`: `dryFoliageColor` is intentionally left to the definitions; the 1.21.8 block tint
  fallback used by the generator returns a constant for the dry foliage tint type.

`fabric-1.21.8/generator.yaml` was updated to the 2026.3 condition style (`types.*`), the base templates were
kept in the upstream order, and `subversion` was bumped so existing workspaces regenerate their base files.

### 3.3 Generator fragments (mixin / access transformer)

The 2026.3 fragments system is used for custom mixin configuration and class tweaker entries:

- `biome.definition.yaml` and `feature.definition.yaml` now declare `fragments:` entries of type
  `accesstransformer` and `mixin` with their conditions and content.
- `templates/modbase/accesswidener.ftl` renders `fragments.accesstransformer` and no longer hardcodes the
  biome / feature class tweaker lines.
- `templates/modbase/mixin.json.ftl` merges `fragments.mixin` into the generated mixin list and no longer
  hardcodes the biome mixin.

The two template files remain unconditional base templates, so the mixin configuration and class tweaker file
are always generated; the optional entries themselves are contributed by the definitions through the fragments
system, which is the part the 2026.3 feature adds.

## 4. `new_features.txt` status

Legend: **Done** = implemented and statically validated; **Partial** = generic/shared implementation present,
1.21.8-specific verification pending; **N/A** = the feature does not exist in the EAP element model for
1.21.8; **Not implemented** = not wired to the Fabric generator yet.

### 2026.2.x

| Feature | Status | Notes |
| --- | --- | --- |
| Wandering villager trade category | N/A | The EAP `VillagerTrade.TradeEntry` model has no category field; the generator now reads the 2026.3 `VillagerTrade.trades` list and keeps the wandering trader pool path working. |
| Blockly enchantment effect builder | Partial | Generated through the 2026.3 shared datapack `enchantment.json.ftl`; Fabric-side build verification pending. |
| Custom armor attribute modifiers | Done | `templates/armor/armor.java.ftl` builds `ItemAttributeModifiers` including default armor values and per-piece custom modifiers. |
| Dimension custom skybox, sun and moon | Not implemented | Fields excluded; the 2026.3 implementation depends on 26.x render pipelines. |
| Armor trims mod element | Done | `armortrim.definition.yaml` plus trim pattern, smithing recipe and atlas templates; atlas uses the 1.21.8 `trims/entity/humanoid` / `humanoid_leggings` texture paths. |
| Special entity raft / chest raft | Not implemented | Custom `Boat` subclasses cannot select the vanilla bamboo raft variant without a separate entity type and renderer. |
| Special entity item rarity | Done | Rarity is applied to the generated boat item properties. |
| Enchantment effects: XP modifiers, unequip, vanish on death | Partial | Shared 2026.3 datapack template. |
| Enchantment value modifiers: set / multiply / increase | Partial | Shared 2026.3 datapack template. |
| Follow item in hand AI: item list and item tags | Not implemented | The 1.21.8 `aitasks/follow_item_in_hands.java.ftl` still expects a single item. |
| Advancement item predicate components (damage, enchantments) | Not implemented | 1.21.8 datapack trigger templates were not migrated. |
| Advancement triggers with item predicates | Not implemented | Same as above. |
| Advancement trigger: item with use duration used | Not implemented | Same as above. |
| Explosion source type: trigger (wind charge) | Not implemented | 1.21.8 procedure template not migrated. |
| Math blocks: clamp, linear interpolation | Done | `math_clamp.java.ftl`, `math_lerp.java.ftl`. |
| Block block: is point inside solid part of any block | Done | `world_data_is_point_inside_block_collision_shape.java.ftl` and util. |
| Entity block: get eye position as vector | Done | `entity_eyepos.java.ftl`. |

### 2026.3.x

| Feature | Status | Notes |
| --- | --- | --- |
| Multipart block states | Not implemented | `multipartModel` excluded. The blockstate JSON side is present in the shared base, but state-based block models and the shape union are not generated for 1.21.8. |
| Synced data as animation conditions | Not implemented | 1.21.8 living entity templates still use procedure conditions only. |
| Shadow blocks for procedure blocks | N/A | MCreator core feature, no generator change required. |
| Force redstone conduction block parameter | Done | `.isRedstoneConductor((bs, br, bp) -> true)` generated before the transparency branch. |
| Custom loot tables as loot modifiers | N/A | NeoForge data-map feature; fields excluded. |
| Dimension world gen type: void | Done | `dimension_void.json.ftl` is emitted for `Void gen`. |
| Enchantment: weapon damage / knockback, armor effectiveness | Partial | Shared 2026.3 datapack template. |
| Enchantment value modifiers in order | Partial | Shared 2026.3 datapack template. |
| Level-based enchantment effect number inputs | Partial | Shared 2026.3 datapack template. |
| Raytrace water and fall damage resetting modes | Not implemented | 1.21.8 raytrace procedure templates not migrated. |
| Strong power emission for a block face | Done | `world_data_get_emitted_strong_redstone_power.java.ftl`. |
| Vector blocks: dot product and cross product | Partial | Dot product implemented; the EAP 1.21.1 template set has no cross product template to port. |
| Entity: line of sight between two entities | Done | `entity_has_line_of_sight.java.ftl`. |
| Entity: get/set invulnerable time | Done | `entity_invulnerabletime.java.ftl`, `entity_set_invulnerabletime.java.ftl`. |
| Entity: get attack cooldown scale / reset | Done | `entity_attackcooldown.java.ftl`, `entity_attackcooldown_reset.java.ftl`. |
| Entity: force entity to attack another entity | Done | `entity_forceplayerattack.java.ftl`. |
| Armor unbreakable by durability 0 | Done | `ArmorItem` with a 0 armor durability is unbreakable in 1.21.8; the attribute modifier macro keeps this behaviour. |
| Synced data as entity layer conditions | Not implemented | 1.21.8 renderer templates use procedure conditions only. |
| Attribute modifiers enchantment component | Partial | Shared 2026.3 datapack template. |
| Creative tab: hide tab title | Done | `.hideTitle()` emitted when the tab has `hideTitle`. |
| Entity AI task: custom attack with procedure | Done | `aitasks/attack_with_procedure.java.ftl` plus `_mcitem`, `any_item_in` and `tag_item` helpers. |
| Entity block: is entity moving | Done | `entity_is_moving.java.ftl`. |
| Item blocks: can item repair item, is stack empty, is piglin currency, can damage source hurt item | Done | `item_can_repair`, `item_is_empty`, `item_is_piglin_currency`, `item_can_be_hurt_by`. |

## 5. Element and template changes

- Items and tools: the 2026.3 mapped `EquipmentSlotEntry` values are emitted directly and `"default"` falls back
  to `EquipmentSlotGroup.MAINHAND`. `ItemUseAnimation` is emitted as the mapped value, and food/drink checks use
  `getUnmappedValue()`. The animation mapping targets `ItemUseAnimation` (the 1.21.8 class name) rather than the
  2026.3 1.21.1 `UseAnim` value, and includes the 1.21.8 `bundle` value.
- Magic item expressions (for example `procedure_retval_itemstack`) are trimmed before the `/*@ItemStack*/` /
  `/*@BlockState*/` marker checks, so procedure return values are not wrapped in a second `new ItemStack(...)`.
- Armor: custom attribute modifiers per armor piece, default armor/toughness/knockback modifiers preserved, and
  the existing 1.21.8 custom model handling kept.
- Blocks: force redstone conduction added; multipart and other unsupported 2026.3 features excluded.
- Villager trades: ported from the 2026.3 `trades` list (`VillagerTrade.trades`) instead of the removed
  `tradeEntries` grouping; wandering trader trades and villager level offers are both generated.
- Tabs: `hideTitle` support.
- New procedures and AI tasks listed in section 4 were added under `fabric-1.21.8/procedures` and
  `fabric-1.21.8/aitasks`.
- P1 additions (2026.3-1.0.1-beta): `entity_submerged_height`, six `item_nbt_*` blocks, and 23 triggers
  (the first eight use generated `LivingEntityEvents`/`ItemEvents`/`PlayerEvents`; the second batch uses a
  generated `Triggers` event bus for crop growth, attack targets, lightning, hand switching, totems, explosions,
  farmland, dropped/expired items, destroyed/smelted items, air clicks, hoe use and sapling growth). The 16 new
  mixins all use `require = 0` so a future Minecraft signature change degrades to a missing trigger instead of a
  startup crash. `entity_grief` and `village_siege` remain NeoForge-only.
- P2 additions (2026.3-1.0.1-beta): all 13 `block_inv_*` procedures and the 3 entity slot/inventory procedures.
  They use vanilla `Container` / player `Inventory` instead of NeoForge item capabilities; modded inventories that
  expose only a NeoForge capability are not covered.

## 6. Workspace base and Gradle

`fabric-1.21.8/workspacebase` was refreshed:

- Fabric Loom `1.15.5`, Fabric Loader `0.20.1`, Fabric API `0.136.1+1.21.8`.
- Java 21 bytecode (`options.release = 21`) compiled with the MCreator JDK 25; `sourceCompatibility` and
  `targetCompatibility` are 21 so the produced mod runs on Java 21+.
- `gradle-wrapper.properties` points at the local Gradle 9.8.0 archive
  (`file:///B:/QA/Documents/App/Mods/DSH/Fabric_Generator_1.21.8/Reference%20resources/gradle-9.8.0-bin.zip`).
- Gradle wrapper scripts and wrapper jar were taken from the local 9.8.0 distribution / working test project.

## 7. Verification performed

The full MCreator GUI and the Gradle build could not run in the development sandbox: the JVM reports all
directories as non-writable (a sandbox ACL effect), which makes MCreator's JNA bootstrap, its Gradle project
validation and `gradlew` fail before generator code runs. To verify the generator without the GUI, an offline
smoke test drives the real MCreator 2026.3 classes directly.

### 7.1 Offline smoke test through MCreator 2026.3 (`plugin/tools/smoke-test.ps1`)

The smoke test loads the packaged plugin with MCreator's own `PluginLoader`, constructs the generator
configuration, creates a real workspace, renders every base template and generates a block, item and
procedure from the fixtures in `workspace/test-min/elements`. Result of the run in this workspace:

```
  ok   plugin generator-fabric-1.21.8 loaded
  ok   no failed plugins
  ok   generator configuration loaded
  ok   base templates declared
  ok   definitions loaded: 37
  ok   armor trim definition present
  ok   workspace created with the Fabric generator
  ok   base templates rendered: 44
  ok   mod base class written
  ok   mixin configuration written
  ok   armor trim atlas written
  ok   armor trim atlas uses 1.21.8 texture paths
  ok   element files generated: 35
  ok   block class written
  ok   item class written
  ok   procedure class written
  ok   P1 trigger procedures written
SMOKE TEST PASSED
```

This exercises plugin discovery and compatibility checks, `generator.yaml` parsing, import resolution of the
private `fabric-1.21.8-base/datapack` and `fabric-1.21.8-base/neoforge` layers, YAML definition merging, mapping
loading, workspace creation and the Freemarker pipeline for both base and element templates. Generated output
includes `PorttestMod.java`, `fabric.mod.json`, `porttest.mixins.json` (base and item mixins),
`porttest.classtweaker`, the block/item JSON models and the Java classes for the block, item and procedure.

The smoke test deliberately does not invoke Gradle, so import formatting (which needs the project classpath)
is not applied in the generated files; MCreator applies it during a real workspace build.

### 7.2 Real-machine verification (user-confirmed)

The minimal workspace `workspace/test-min` (one block, one item and one procedure) was installed on the target
MCreator EAP 2026344621 and tested by the user. The reported result:

- the generated workspace compiles;
- the Fabric 1.21.8 client starts successfully.

This confirms end-to-end loading, workspace setup, code generation and compilation on the target MCreator build,
including the `types.base_*` registration fix, the villager trade model change and the 2026.3 item/animation
mapping.

An additional offline audit loaded the three larger user test workspaces through the same MCreator 2026.3
classes and rendered every element in memory:

| Workspace | Elements | Base templates | Result |
| --- | --- | --- | --- |
| `test-croparium` (`cp_lib`) | 334 | 36 | all render |
| `test-everrose` (`everrose`) | 181 | 33 | all render |
| `test-betterMelon` (`qa_better_melon`) | 430 | 43 | all render |
| **Total** | **945** | - | **945/945 elements, 2947 files, 0 template failures** |

The audit found one missing trigger template (`player_useitem_finish`) used by the better melon workspace. The
trigger was implemented with a new `FINISH_USING_ITEM` Fabric event and a `completeUsingItem` mixin injection,
and the player stop using item trigger's `itemstack` dependency typo was fixed at the same time. After the fix
the audit reports zero failures. Full code generation and Gradle builds of these workspaces are still under
real-machine testing.

The remaining 2026.3 features listed in section 4 still need their own verification.

### 7.3 Root cause notes for the 1.21.8 API build errors

Two build error classes were reported on the larger workspaces. Neither is caused by the `types` empty-list
semantics, the YAML base type sources or the YAML merge behaviour:

- `cannot find symbol: UseAnim` was **introduced by the 2026.3 adaptation**. The 2026.1 Fabric item template
  emitted `ItemUseAnimation.<NAME>` directly and had no `itemuseanimations` mapping. The 2026.3 port adopted
  the 2026.3 mapped animation value (`${data.animation}`) together with the 2026.3 1.21.1
  `mappings/itemuseanimations.yaml`, which maps to `UseAnim.*`. That class was renamed to `ItemUseAnimation` in
  Minecraft 1.21.8, so the mapping now targets the 1.21.8 class name.
- `no suitable constructor found for ItemStack(ItemStack)` is a **pre-existing Fabric generator gap**, not a
  2026.3 regression. The 2026.1 and 2026.3 NeoForge 1.21.8/1.21.1 generators already trim magic item markers
  with `mappedBlock?trim?starts_with("/*@ItemStack*/")`; the Fabric `utils/mcitems.ftl` override kept the older
  `?starts_with` check. The `procedure_retval_itemstack` template output begins with whitespace, so the marker
  was missed and the returned stack was wrapped in a second `new ItemStack(...)`. The Fabric override now trims
  before the marker checks.

Both fixes only affect emitted Java expressions; the definitions, base types and YAML merge results were already
loading correctly (the 945-element audit found no definition or template resolution errors).

### 7.4 Static checks

1. `plugin/tools/validate.ps1` (static validator built against MCreator 2026.3 libraries):
   - 172 YAML files parse;
   - 1686 Freemarker templates parse;
   - 634 template references and 830 includes resolve;
   - validation passes.
2. The plugin archive is produced by `plugin/tools/build-plugin.ps1` and contains exactly one
   `generator.yaml` (`fabric-1.21.8/generator.yaml`), so the base layers are not registered as generators.
3. The packaged archive contains `plugin.json`, `LICENSE`, the Fabric generator and both namespaced base layers
   (`fabric-1.21.8-base/datapack`, `fabric-1.21.8-base/neoforge`); no `datapack-1.21.8/` or `neoforge-1.21.8/`
   entries remain.

Verification steps for the user:

```powershell
# 1. Static validation
pwsh plugin/tools/validate.ps1

# 2. Package the plugin
pwsh plugin/tools/build-plugin.ps1

# 3. Offline smoke test (plugin load, workspace creation, code generation)
pwsh plugin/tools/smoke-test.ps1

# 4. Install the ZIP from build/dist into MCreator (Preferences > Manage plugins) or copy it to
#    %USERPROFILE%\.mcreator\plugins

# 5. Create a Fabric 1.21.8 workspace with a block, an item and a procedure, then generate and build.

# 6. Build a workspace with all caches redirected to <repo>/caches/gradle
pwsh plugin/tools/verify-workspace.ps1 -Workspace "B:\path\to\workspace" -Tasks build
```

### 7.5 Coexistence test

A synthetic NeoForge 1.21.8 generator plugin was installed next to this plugin to verify the namespace
separation. The fake plugin uses `weight: 12` (higher than this plugin), ships `neoforge-1.21.8/` and
`datapack-1.21.8/` resources with marker templates, and is therefore loaded before this plugin. Results:

- both plugins load, and the fake generator configuration loads without errors;
- `neoforge-1.21.8/templates/json/block.json.ftl`, `datapack-1.21.8/templates/tags.json.ftl` and
  `neoforge-1.21.8/workspacebase/build.gradle` resolve to the fake plugin, as expected;
- `fabric-1.21.8-base/neoforge/...` and `fabric-1.21.8-base/datapack/...` resolve to this plugin;
- a Fabric block generated with both plugins installed contains no fake template content and uses the namespaced
  model template;
- all base templates still render (18 in the coexistence run).

The 945-element audit was also repeated with the namespaced package: 945/945 elements, 2947 files, no template,
`UseAnim` or wrapped `ItemStack` errors.

## 8. Known limitations

- The MCreator GUI and `gradlew build` could not be executed in this sandbox (see section 7); plugin loading,
  workspace creation and code generation were verified through the offline smoke test, and the minimal
  block/item/procedure workspace was confirmed by the user to compile and start the Fabric 1.21.8 client.
  Regression coverage for larger workspaces and the remaining 2026.3 features is still pending.
- Multipart block states, dimension skybox/sun/moon rendering, loot modifiers, synced data animation/layer
  conditions, rafts, advancement item predicates and the 1.21.8 raytrace modes are not implemented; the
  corresponding element fields are excluded where the EAP model allows it, and are listed in section 4.
- Raft and chest raft special entities fall back to boat rendering; the elements are accepted, but the result is
  not a bamboo raft.
- Enchantment effects, value modifiers and attribute-modifier components rely on the shared 2026.3 datapack
  template; they are not Fabric-specific and were not runtime verified.
- The `fabric-1.21.8-base/neoforge` base layer is a private resource superset. It is never used by the Fabric base
  templates, but its NeoForge files remain inside the archive to keep inherited definition paths resolvable. No
  generated Fabric code references `net.neoforged`.
- The Gradle wrapper URL is an absolute local path (`file:///B:/...`) as required by the delivery rules; moving
  the repository requires updating `workspacebase/gradle/wrapper/gradle-wrapper.properties`,
  `plugin/gradle/wrapper/gradle-wrapper.properties` and `plugin/gradle.properties`.
- Item, block, villager trade and living entity elements created with 2026.1 workspaces are converted by
  MCreator on load; the migration was not exercised here.
