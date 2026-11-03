# Changelog

## 2026.3-1.0.0-beta

Port of the Fabric 1.21.8 generator to MCreator 2026.3.44621 EAP.

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

### Changes
- Generator definitions migrated to the 2026.3 base type, `types` map, `field_exclusions` and fragment semantics.
- `types` conditions in base templates converted from the removed `base:<plural>` keys to `base_<plural>` with `?has_content` checks.
- Definition conditions use the 2026.3 plural element lists where applicable.
- Workspace base updated to Fabric Loom 1.15.5, Fabric Loader 0.20.1, Fabric API 0.136.1+1.21.8 and the local Gradle 9.8.0 distribution.
- Item use animations and attribute modifier equipment slots now use the 2026.3 mapped element values.
- Generator subversion bumped to force base regeneration of existing workspaces.

### Fixes
Fixed 3 bug(s).
- `types["base:blocks"]`, `types["base:items"]`, `types["base:entities"]`, `types["base:blockentities"]` and `types["base:features"]` no longer resolve on 2026.3 and prevented the corresponding registries from loading.
- Villager trades used the removed `tradeEntries` grouping and would generate no offers on 2026.3.
- `ItemUseAnimation` and equipment slot values are mapped objects on 2026.3; the old template emitted invalid enum and slot expressions.

### Known Limitations
- Multipart block states, dimension skybox/sun/moon rendering, loot modifiers, synced data animation and layer conditions, rafts, advancement item predicates and 1.21.8 raytrace reset modes are not implemented.
- Enchantment effect and value modifier features rely on the shared 2026.3 datapack template and were not runtime verified.
- Runtime verification (MCreator load, code generation, Gradle build) was not possible in the restricted development sandbox; the plugin was validated statically and packaged, and is ready for the user's real-machine test.
