# Fabric 1.21.8 Generator 功能对齐审计报告

- 审计日期：2026-11-03
- 基准（Baseline）：MCreator 2026.3 内置 **NeoForge 26.3** 生成器（`generator-26.3.x/neoforge-26.3` + `datapack-26.3.x`）
- 对象（Target）：当前插件 2026.3-1.0.1-beta 的有效 Fabric 1.21.8 生成器（`fabric-1.21.8` + `fabric-1.21.8-base/{datapack,neoforge}`）
- 参考：Fabric-Generator-MCreator `26.3-2026.3-2.9-beta`（上游 Fabric 26.3 实现）、1.21.8 官方映射 jar
- 方法：对 mod element 定义、procedure block、trigger、AI task、变量类型、cmdarg、jsontrigger、feature、enchantment effect、模板路径、mapping key 做文件/键集合差集；逐项检查模板中的 NeoForge API 依赖；对上游 Fabric 2.9 做二次比对；对 1.21.8 jar 做 API 存在性抽查。**未做逐项游戏内行为验证**。

> **P1 实施状态（2026.3-1.0.1-beta）**：本报告最初基于 P1 前的审计快照；P1 已补以下能力，下文的 procedure/trigger 统计也已同步为 P1 后状态：
> - 8 个 trigger：`entity_change_equipment`、`entity_ticks`、`entity_tamed`、`item_crafted`、`mod_load`、`player_completes_advancement`、`player_critical_hit`、`player_fishes_item`；
> - 7 个 procedure：`entity_submerged_height` + `item_nbt_{logic,num,text}_{get,set}`；
> - 对应的事件类扩展与 5 个 mixin（`ResultSlotMixin`、`PlayerAdvancementsMixin`、`PlayerCriticalMixin`、`FishingHookMixin`、`TamableAnimalMixin`）。
>
> 当前有效覆盖约 **460/506 procedures（90.9%）**、**48/65 triggers（73.8%）**；下文的 procedure/trigger 统计已同步为 P1 后状态。

## 0. 结论摘要

| 能力类别 | NeoForge 26.3 | Fabric 1.21.8（有效） | 覆盖率 | 缺失 | 主要缺口性质 |
| --- | --- | --- | --- | --- | --- |
| Mod element 类型 | 37 | 37 | 100% | 0 | — |
| Common 基础类型 YAML | 9 | 5（名称） | 56%（名称） | 4 | 2 项有等价实现，2 项为 NeoForge data map |
| Procedure blocks | 506 | 460 | 90.9% | 46 | 多为 NeoForge Capability / persistent data；少量可移植 |
| Triggers | 65 | 48 | 73.8% | 17 | 其余需新 Fabric 事件/mixin |
| AI tasks | 36 | 36 | 100% | 0 | — |
| 变量类型 | 10 | 10 | 100% | 0 | — |
| Command arguments | 12 | 12 | 100% | 0 | — |
| JSON triggers | 21 | 21 | 100% | 0 | — |
| Feature 类型 | 107 | 110 | 103% | 0 | Fabric 侧多 3 个 1.21.8 feature |
| Enchantment effects | 20 | 20 | 100% | 0 | — |
| 模板路径（按文件名） | 203 | 182 同名 + 54 自有 | 89.7%（同名） | 21 | 多数是不同实现；实际功能缺口约 3–5 项 |
| Mapping key | 1956 | 1819 | 93.0% | 137 | 全部为 26.3 新内容（`itemuseanimations.bundle` 已在 2026.3-1.0.1-beta 补上） |

最需要处理的功能缺口（按优先级）：

1. **盔甲纹饰 atlas 纹理路径错误**（`templates/armortrim/trims_atlas.json.ftl` 仍使用 1.21.1 的 `trims/models/armor`）——1.21.8 与 MCreator `ArmorTrim` 都使用 `trims/entity/humanoid` / `humanoid_leggings`。此项已在 2026.3-1.0.1-beta 修正。
2. **`itemuseanimations` 缺少 `bundle`**——1.21.8 存在 `ItemUseAnimation.BUNDLE`；已在 2026.3-1.0.1-beta 补充。
3. **P1 已补 8 个 trigger**：`entity_change_equipment`、`entity_ticks`、`entity_tamed`、`item_crafted`、`mod_load`、`player_completes_advancement`、`player_critical_hit`、`player_fishes_item`；剩余 17 个需新事件/mixin。
4. **P1 已补 procedure**：`entity_submerged_height` 和 6 个 `item_nbt_{logic,num,text}_{get,set}`；剩余可移植项主要是 `block_inv_*`、槽位/物品处理器。
5. **transformable（斧头转换/去皮）块能力缺失**（26.3 data map；1.21.8 需要 `AxeItem` 映射/mixin）。

> **审计修正（2026-11-03，2026.3-1.0.1-beta）**：初版报告把“盔甲纹饰 palette mcmeta”和“药水自动喷溅/滞留配方”列为 P0。复核 1.21.8 后修正：
> - 1.21.8 的原版 `armor_trims` atlas 使用 `trims/entity/humanoid`，纹饰纹理没有 `.png.mcmeta`；`trim_palette.mcmeta` 是 26.3 装备渲染体系的产物，1.21.8 不需要。真正的缺口是 Fabric 生成的 atlas 路径。
> - 1.21.8 的 `PotionBrewing.addVanillaMixes` 已注册通用的 `POTION + gunpowder → SPLASH_POTION`、`SPLASH_POTION + dragon_breath → LINGERING_POTION` 容器配方，并保留任意药水的 `POTION_CONTENTS`，因此自定义药水无需逐条生成配方；26.3 的 `potion/potion_recipe.json` 是 26.3 数据驱动体系的要求。

## 1. Mod element 定义

- 定义文件：**37/37 全部存在**（含 `armortrim.definition.yaml`）。
- 9 个定义文件存在可选 section 结构差异，逐项判断如下：

| 定义 | NeoForge 26.3 有、Fabric 缺少 | 判定 | 说明 |
| --- | --- | --- | --- |
| `armor` | `fragments`（26.3 渲染管线 AT） | N/A | 1.21.8 盔甲渲染走旧管线，不需要该 AT |
| `bannerpattern` | `tags` | 等价 | Fabric 使用 `global_templates` 生成同一 tag |
| `fluid` | `fragments`（26.3 流体 travel AT） | N/A | 26.3 流体物理专用 |
| `itemextension` | `templates`（fuel/compost data map JSON） | 等价 | Fabric 使用 `FuelRegistryEvents` / `CompostingChanceRegistry` |
| `livingentity` | `global_templates`（monster_room_mobs data map） | 等价 | Fabric 使用 `MonsterRoomFeatureMixin` + AW |
| `painting` | `tags` | 等价 | Fabric 使用 `json/painting.json.ftl` + `global_templates` tag |
| `potion` | `templates`（自动生成 gunpowder / dragon_breath 酿造配方） | 等价（N/A） | 1.21.8 原版 `PotionBrewing.addVanillaMixes` 的通用容器配方已覆盖自定义药水的喷溅/滞留转换；26.3 才需要逐药水数据驱动配方 |
| `villagerprofession` | `tags` | 等价 | Fabric 使用 `json/villagerprofessions_poi_tag.json.ftl` |
| `villagertrade` | `list_templates` + `tags`（26.3 数据驱动交易与分类） | **部分缺口** | Fabric 代码式交易可用，但 wandering trader category / tag-based trade set 缺失 |

额外发现：

- `block.definition.yaml` 未声明 `transformable` 基础类型，也没有 `strippingResult` 相关模板；NeoForge 26.3 通过 `common.transformables.yaml` + `transformable` base type 支持自定义斧头转换/去皮。**Fabric 侧缺失**（1.21.8 需 `AxeItem.STRIPPABLES` 映射或 mixin）。
- `flammable` 能力未走 `common.flammables.yaml`，但 `block.java.ftl` 使用 `FlammableBlockRegistry` 实现，**功能等价**。

## 2. Procedure blocks（P1 后缺失 46 / 506）

统计口径：`procedures/` 根目录 `.ftl`，排除 `_` 前缀辅助模板。

| 分组 | 数量 | 缺失名称 | 判定 | 说明 |
| --- | --- | --- | --- | --- |
| `block_energy_*` | 8 | can_extract / can_receive / check_extract / check_receive / extract / get / get_max / receive | **Loader-specific（N/A）** | 依赖 NeoForge `IEnergyStorage`、`Capabilities.Energy`、`ILevelExtension`；Fabric 无标准能量 API |
| `block_fluidtank_*` | 7 | check_drain / check_fill / drain / fill / get / get_max / tanks | **Loader-specific（N/A/重设计）** | 依赖 NeoForge FluidHandler capability；Fabric 需自建 tank 抽象 |
| `block_inv_*` | 13 | can_insert / clear_slot / damage_item / extract_items / extract_items_get_result / get_amount_inslot / get_item_inslot / get_slot_count / get_slot_stack_limit / insert_items / insert_items_get_result / remove_items / set_items | **可移植（需重设计）** | 现实现依赖 `IItemHandler`；Fabric 可用 vanilla `Container` 或 Fabric Transfer API `ItemStorage`，工作量大；上游 Fabric 2.9 未实现 |
| `block_nbt_*` | 6 | logic_get / logic_set / num_get / num_set / text_get / text_set | **Loader-specific/重设计** | 依赖 NeoForge `BlockEntity#getPersistentData()`；Fabric 无通用 BE 持久 NBT，需 SavedData/mixin |
| `entity_nbt_*` | 6 | logic_get / logic_set / num_get / num_set / text_get / text_set | **Loader-specific/重设计** | 依赖 `Entity#getPersistentData()`；Fabric 无等价通用持久数据 |
| `entity_get_slot` / `entity_set_slot` / `entity_inventory_foreach` | 3 | 见左 | **可移植（需重设计）** | 依赖 NeoForge item capability；可用 `LivingEntity.getItemBySlot` / `Container` 近似实现 |
| `itemhandler_get_slot` / `itemhandler_set_slot` | 2 | 见左 | **可移植（需重设计）** | 同上，需 Fabric Transfer API/容器抽象 |
| `blockat_enchant_power_bonus` | 1 | 见左 | **可移植（mixin，低优先级）** | 1.21.8 无 `BlockState#getEnchantPowerBonus` 扩展点，需 mixin |
| **合计** | **46** | | | |

结论：P1 已补 `item_nbt_*` 6 项和 `entity_submerged_height`；剩余 46 项中，可直接移植的仅 `blockat_enchant_power_bonus`，其余大多需要 Fabric 专属重设计。

## 3. Triggers（P1 后缺失 17 / 65）

P1 已实现 8 个 trigger：`entity_change_equipment`、`entity_ticks`、`entity_tamed`、`item_crafted`、`mod_load`、`player_completes_advancement`、`player_critical_hit`、`player_fishes_item`。剩余 17 个：

| 分类 | 数量 | Trigger | 判定 |
| --- | --- | --- | --- |
| 可由 vanilla 事件/mixin 实现 | 13 | `entity_switch_hand`, `entity_sets_attack_target`, `entity_struck_by_lightning`, `entity_uses_totem`, `item_destroyed`, `item_smelted`, `farmland_trampled`, `crop_attempts_growth`, `sapling_glow`, `gem_dropped`, `gem_expired`, `player_left_click_air`, `player_use_hoe` | 可移植（需新 mixin/事件，P2） |
| 需要较深 mixin/自定义语义 | 4 | `entity_grief`, `village_siege`, `explosion_occurs`, `player_right_click_empty_hand` | 可移植但高风险（P3） |

说明：17 项全部有 1.21.8 对应机制，不存在“26.3 独有、1.21.8 无法实现”的 trigger；剩余项在 Blockly 中仍不可用。

## 4. 其他生成器能力

| 能力 | 结果 | 说明 |
| --- | --- | --- |
| AI tasks | 36/36 | 有效集合来自 `fabric` + `fabric-1.21.8-base/neoforge`；含 2026.3 新增 `attack_with_procedure` 及其 helpers |
| 变量类型 | 10/10 | 与 26.3 完全一致 |
| Command arguments | 12/12 | 完全一致 |
| JSON triggers | 21/21 | 来自 datapack base，完全一致 |
| Features | 110/107 | Fabric 侧多 3 个，无缺失 |
| Enchantment effects | 20/20 | 来自 datapack base，完全一致 |

## 5. 资源生成器 / 模板（21 个路径缺失）

NeoForge 26.3 有 203 个唯一模板路径，Fabric 有效集合 231 个（Fabric 自有模板更多）；按文件名缺少 21 个。逐项判定：

| 缺失模板 | 判定 | 说明 / Fabric 对应实现 |
| --- | --- | --- |
| `armortrim/trim_palette.mcmeta.ftl` | N/A（26.3 专用） | 1.21.8 纹饰纹理无 `.png.mcmeta`；**实际缺口**是 `trims_atlas.json.ftl` 的纹理路径，已在 2026.3-1.0.1-beta 修正 |
| `biome/material_rule.json.ftl` | **缺口（P2）** | 自定义生物群系 surface/material rule；1.21.8 有 surface rules，可移植 datapack 模板 |
| `dimension/effects_timeline.json.ftl` | N/A | 26.3 timeline 体系，1.21.8 无对应概念 |
| `dimension/fixed_timeline.json.ftl` | N/A | 同上 |
| `elementinits/flammable.json.ftl` | 等价 | `block.java.ftl` 使用 `FlammableBlockRegistry` |
| `elementinits/transformables.json.ftl` | **缺口（P2）** | 自定义斧头转换/去皮；需 `AxeItem` 映射或 mixin |
| `itemextension/compostable_items.java.ftl` | 等价 | `CompostingChanceRegistry` |
| `itemextension/compostable_provider.json.ftl` | 等价 | 同上（Fabric 代码注册，非 data map） |
| `itemextension/fuel_provider.json.ftl` | 等价 | `FuelRegistryEvents` |
| `itemextension/fuels.java.ftl` | 等价 | `elementinits/item_extensions.java.ftl` |
| `json/txblock/sign_model.json.ftl` 等 4 个 sign 模板 | **不同实现（需验证）** | Fabric 侧使用通用 `block.java.ftl` + `block_states.json.ftl` 生成 sign；未发现等价性测试 |
| `livingentity/monster_room_mobs.json.ftl` | 等价 | `json/monster_room_mobs.json.ftl` + `MonsterRoomFeatureMixin` |
| `painting/painting.json.ftl` | 等价 | `json/painting.json.ftl` |
| `potion/potion_recipe.json.ftl` | 等价（N/A） | 1.21.8 原版通用容器配方已覆盖喷溅/滞留转换；26.3 数据驱动配方不适用于 1.21.8 |
| `recipe/brewing.json.ftl` | 等价 | `elementinits/brewingrecipes.java.ftl`（Fabric API 仅 potion→potion） |
| `villager_trade.json.ftl` | **部分缺口（P1）** | 代码式交易可用，但 26.3 的数据驱动分类/tag 交易缺失 |
| `villagerprofession/profession_hat.mcmeta.ftl` | 等价 | 根目录 `profession_hat.mcmeta.ftl` |
| `villagerprofession/trade_set.json.ftl` | 部分等价 | 代码式 profession 交易可用，trade set 数据驱动缺失 |

## 6. Mapping key 覆盖

- 43/43 个 mapping 文件均存在。
- NeoForge 26.3 共 1956 个 key，Fabric 有效集合 1819 个（93.0%），缺少 137 个；`itemuseanimations.bundle` 已在 2026.3-1.0.1-beta 补上。
- 抽查 1.21.8 映射 jar 后，剩余 137 个缺失 key 全部属于 **26.3 新内容**（新生物、方块、粒子、结构、动画、gamerule、attribute 等），对 1.21.8 不适用：

| 文件 | 缺失 key | 判定 |
| --- | --- | --- |
| `itemuseanimations.yaml` | `trident` | N/A（1.21.8 无 `TRIDENT`） |
| `animations.yaml` | 31 项 | N/A（26.3 新生物动画） |
| `attributes.yaml` | `AIR_DRAG_MODIFIER`, `BELOW_NAME_DISTANCE`, `BOUNCINESS`, `FRICTION_MODIFIER` | N/A（1.21.8 无这些 attribute） |
| `gamerules.yaml` | `PVP`, `SPAWN_MONSTERS`, `COMMAND_BLOCKS_WORK`, `SPAWNER_BLOCKS_WORK`, `FIRE_SPREAD_RADIUS_AROUND_PLAYER`, `ALLOW_ENTERING_NETHER_USING_PORTALS` | N/A（1.21.8 无这些 gamerule） |
| `biomes.yaml` / `configuredfeatures.yaml` / `structures.yaml` / `blockstateproperties.yaml` / `damagesources.yaml` / `effects.yaml` / `enchantments.yaml` / `entities.yaml` / `gameevents.yaml` / `noteblockinstruments.yaml` / `particles.yaml` / `pathnodetypes.yaml` / `screens.yaml` / `stepsounds.yaml` | 其余 136 项 | N/A（26.3 新内容） |

完整缺失计数（按文件）：

```
animations 31, attributes 4, biomes 2, blockstateproperties 3,
configuredfeatures 18, damagesources 2, effects 1, enchantments 1,
entities 11, gameevents 1, gamerules 6, itemuseanimations 1,
noteblockinstruments 4, particles 10, pathnodetypes 1, screens 13,
stepsounds 10, structures 18
```

## 7. 功能等价但实现不同的能力

以下能力在文件/模板名称上不同，但 Fabric 1.21.8 有等价实现，不应计入“缺失”：

- 燃料/堆肥：NeoForge data map → `FuelRegistryEvents` / `CompostingChanceRegistry`
- 可燃性：NeoForge data map → `FlammableBlockRegistry`
- 怪物房刷怪：NeoForge data map → `MonsterRoomFeatureMixin`
- 酿造配方：NeoForge 数据驱动 JSON → `FabricBrewingRecipeRegistryBuilder`
- 村民交易：NeoForge 数据驱动 JSON → `TradeOfferHelper`（wandering / villager levels）
- 药水：NeoForge `Potions` registry → Fabric `elementinits/potions.java.ftl`
- 画：NeoForge `painting/painting.json` → Fabric `json/painting.json`
- 村民职业帽子：NeoForge 子目录模板 → Fabric 根目录模板

## 8. 建议修复顺序

### P0（2026.3-1.0.1-beta 已处理）

1. 修正 `templates/armortrim/trims_atlas.json.ftl` 的纹理路径：`trims/models/armor` → `trims/entity/humanoid` / `humanoid_leggings`，与 1.21.8 原版 atlas 和 MCreator `ArmorTrim` 的文件复制路径一致。
2. `mappings/itemuseanimations.yaml` 增加 `bundle: ItemUseAnimation.BUNDLE`。
3. 审计修正：`trim_palette.mcmeta` 与药水自动酿造配方经 1.21.8 验证不是缺口，不再列入 P0（见开头“审计修正”）。

### P1（2026.3-1.0.1-beta 已处理）

4. 移植 `entity_submerged_height`（上游 Fabric 2.9 已有）。
5. 移植 `entity_change_equipment`、`entity_ticks` trigger（上游 Fabric 2.9 已有）。
6. 常见 trigger：`item_crafted`、`player_completes_advancement`、`player_critical_hit`、`player_fishes_item`、`mod_load`、`entity_tamed`。
7. `item_nbt_*` 6 个 procedure block（`DataComponents.CUSTOM_DATA`）。

### P2（需要重设计）

8. `block_inv_*` / `entity_*_slot` / `itemhandler_*`（Fabric Transfer API 或 vanilla Container）。
9. `transformable` 块能力（`AxeItem` 映射/mixin）。
10. `biome/material_rule` 模板。
11. 其余 trigger 通过 Fabric 事件/mixin 补齐。

### P3 / N/A

12. `block_energy_*`、`block_fluidtank_*`、`block_nbt_*`、`entity_nbt_*`：NeoForge Capability/persistent data 专用；Fabric 需自建能量/流体/NBT 抽象，不建议按原模板移植。
13. 26.3 内容型 mapping key、timeline 模板、sign 模板差异：属于 Minecraft 26.3 专属，1.21.8 不适用。

## 9. 审计限制

- 本报告是静态集合比对 + 模板 API 抽查，未逐项在游戏中验证行为。
- 文件名相同不代表实现相同，反之亦然；已对已知的 Fabric 替代实现做人工映射。
- 基准 NeoForge 26.3 包含 Minecraft 26.3 的新内容，大量 mapping/template 缺失属于版本差异，不应全部视为 Fabric 移植缺陷。
- `block_inv`、`item_nbt`、trigger 等的“可移植”结论是可行性判断，不是已实现证明；实际实现需要对应的 Fabric API/mixin 设计和回归测试。
- 审计未覆盖游戏内配方、渲染、网络同步等运行时语义。
