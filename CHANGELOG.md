# Changelog

## 2026.3-1.0.1-beta

### New Content
- P1 trigger support: `entity_change_equipment`, `entity_ticks`, `entity_tamed`, `item_crafted`, `mod_load`, `player_completes_advancement`, `player_critical_hit` and `player_fishes_item`, backed by new generated events and mixins (`ResultSlotMixin`, `PlayerAdvancementsMixin`, `PlayerCriticalMixin`, `FishingHookMixin`, `TamableAnimalMixin`) plus the `LivingEntityMixin` equipment/tick hooks.
- P1 second batch: 15 more triggers (`crop_attempts_growth`, `entity_sets_attack_target`, `entity_struck_by_lightning`, `entity_switch_hand`, `entity_uses_totem`, `explosion_occurs`, `farmland_trampled`, `gem_dropped`, `gem_expired`, `item_destroyed`, `item_smelted`, `player_left_click_air`, `player_right_click_empty_hand`, `player_use_hoe`, `sapling_glow`) backed by a generated `Triggers` event bus and 11 additional mixins. `entity_grief` and `village_siege` remain NeoForge-only events.
- `entity_submerged_height` procedure block and the six `item_nbt_*` logic/number/text get/set blocks, using 1.21.8 `FluidTags` and `DataComponents.CUSTOM_DATA`.
- P2 inventory procedures: all 13 `block_inv_*` blocks and the 3 entity slot/inventory blocks, implemented against vanilla `Container` / player inventory instead of NeoForge item capabilities.

### Changes
- Version bumped to 2026.3-1.0.1-beta after the first real-machine build passed.
- Capability audit corrections: 1.21.8 already registers generic POTION + gunpowder -> splash and splash + dragon's breath -> lingering brewing mixes, so no per-potion recipe generation is required; the 26.3 `trim_palette.mcmeta` output is part of the 26.3 equipment pipeline and has no 1.21.8 counterpart.

### Fixes
Fixed 7 bug(s).
- Armor trim atlas textures were referenced at the pre-1.21.2 `trims/models/armor` paths; the generated atlas now uses `trims/entity/humanoid` and `trims/entity/humanoid_leggings`, matching 1.21.8 and the MCreator `ArmorTrim` texture copy paths.
- The item use animation mapping was missing `bundle`, which is a valid `ItemUseAnimation` value in 1.21.8.
- The generated client used `Options.useKey.isPressed()`; 1.21.8 exposes `Options.keyUse.isDown()`.
- `gem_dropped` now hooks `ServerPlayer.drop(ItemStack, boolean, boolean)`, so pressing Q in the inventory triggers it on the server.
- `sapling_glow` now fires only after `TreeGrower.growTree` returns `true` and the sapling block has been replaced, avoiding bone-meal false positives.
- `player_left_click_air` now fires from the serverbound `handleAnimate` handler (with a MISS raycast check), and `player_right_click_empty_hand` is forwarded from the client tick to a small serverbound payload, so procedures that use server-side blocks (for example the chat message block) execute correctly.
- Block entity inventories now use at least the GUI's highest slot index + 1, preventing slots beyond the configured block inventory size from being lost when a GUI and its block inventory have different sizes.

## 1.0.0-beta

First beta release of the Fabric 1.21.8 generator for MCreator 2026.3 EAP 2026344621. This is the first beta
version that can be loaded on the target MCreator build and has completed a build of the minimal
block/item/procedure workspace (code generation, compilation and client start).

### New Content
- Fabric 1.21.8 generator archive now carries the 1.21.8 datapack and NeoForge base layers privately, so it loads on a MCreator release that no longer ships a 1.21.8 built-in generator.
- Armor trim mod element with trim pattern, smithing recipe and armor trim atlas generation.
- Custom armor attribute modifiers, including the default armor, toughness and knockback resistance values.
- Force redstone conduction for custom blocks.
- Void world generation type for custom dimensions.
- Hide tab title support for creative tabs.
- New procedure blocks: clamp, linear interpolation, point inside block collision shape, entity eye position, strong redstone power for a block face, line of sight between entities, invulnerable time get/set, attack cooldown get/reset, forced entity attack, entity moving, item repair/empty/piglin currency/damage source checks and vector dot product.
- New entity AI task for custom attacks driven by procedures.
- Wandering trader and villager trade generation for the 2026.3 villager trade model.
- Special entity item rarity support.
- Mixin and access transformer entries can now be contributed by mod element definitions through the 2026.3 generator fragments system.
- Player finish using item trigger, backed by a dedicated `completeUsingItem` event and mixin injection.

### Changes
- Generator definitions migrated to the 2026.3 base type, `types` map, `field_exclusions` and fragment semantics.
- Added an offline smoke test that drives the real MCreator 2026.3 plugin loader and template engine to verify plugin loading, workspace creation and code generation without the GUI.
- Minimal block/item/procedure workspace verified on MCreator EAP 2026344621: generated code compiles and the Fabric 1.21.8 client starts.
- Offline audit of three real 1.21.8 workspaces (334, 181 and 430 elements): 945 of 945 elements and all base templates render without template errors.
- `types` conditions in base templates converted from the removed `base:<plural>` keys to `base_<plural>` with `?has_content` checks.
- Definition conditions use the 2026.3 plural element lists where applicable.
- Workspace base updated to Fabric Loom 1.15.5, Fabric Loader 0.20.1, Fabric API 0.136.1+1.21.8 and the local Gradle 9.8.0 distribution.
- Item use animations and attribute modifier equipment slots now use the 2026.3 mapped element values.
- Generator subversion bumped to force base regeneration of existing workspaces.
- Private base layers moved to the `fabric-1.21.8-base/` namespace and the plugin weight lowered to 10, so installed 1.21.8 generator plugins can no longer merge or override each other's definitions, templates or workspace base files.
- Coexistence tested with a synthetic higher-weight NeoForge 1.21.8 generator plugin: both plugins load, namespaced resources stay private and Fabric generation is unaffected.

### Fixes
Fixed 7 bug(s).
- `types["base:blocks"]`, `types["base:items"]`, `types["base:entities"]`, `types["base:blockentities"]` and `types["base:features"]` no longer resolve on 2026.3 and prevented the corresponding registries from loading.
- Villager trades used the removed `tradeEntries` grouping and would generate no offers on 2026.3.
- `ItemUseAnimation` and equipment slot values are mapped objects on 2026.3; the old template emitted invalid enum and slot expressions.
- The item use animation mapping still pointed at `UseAnim`, which was renamed to `ItemUseAnimation` in 1.21.8; all values now map to `ItemUseAnimation`.
- `procedure_retval_itemstack` output starts with whitespace, so the `/*@ItemStack*/` marker was not detected and the value was wrapped in `new ItemStack(...)`; the magic item marker checks now trim the expression first.
- The player stop using item trigger referenced a non-existent `eitemstack` variable instead of the `itemstack` dependency.
- The player start using item trigger included the procedures template twice.

### Known Limitations
- Multipart block states, dimension skybox/sun/moon rendering, loot modifiers, synced data animation and layer conditions, rafts, advancement item predicates and 1.21.8 raytrace reset modes are not implemented.
- Enchantment effect and value modifier features rely on the shared 2026.3 datapack template and were not runtime verified.
- Compilation and client start were confirmed for the minimal block/item/procedure workspace. The three larger user workspaces (945 elements) pass the offline template audit, but their full code generation and Gradle builds are still under real-machine testing.
