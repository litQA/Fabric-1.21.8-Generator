classTweaker v1 named

<#-- Mixin and access transformer entries contributed by mod element definitions through the 2026.3 fragments system -->
<#if fragments.accesstransformer??>
<#list fragments.accesstransformer as fragment>
${fragment}
</#list>
</#if>

<#if w.getGElementsOfType('tool')?filter(e -> e.toolType.equals('Fishing rod'))?size != 0>
extendable method net/minecraft/world/entity/projectile/FishingHook shouldStopFishing (Lnet/minecraft/world/entity/player/Player;)Z
</#if>

<#if w.getGElementsOfType('livingentity')?filter(e -> e.spawnInDungeons)?size != 0>
accessible method net/minecraft/world/level/levelgen/feature/MonsterRoomFeature randomEntityId (Lnet/minecraft/util/RandomSource;)Lnet/minecraft/world/entity/EntityType;
</#if>

<#if w.hasElementsOfType("armor")>
accessible class net/minecraft/client/renderer/entity/layers/EquipmentLayerRenderer$LayerTextureKey
accessible class net/minecraft/client/renderer/entity/layers/EquipmentLayerRenderer$TrimSpriteKey
accessible method net/minecraft/client/renderer/entity/layers/EquipmentLayerRenderer$TrimSpriteKey <init> (Lnet/minecraft/world/item/equipment/trim/ArmorTrim;Lnet/minecraft/client/resources/model/EquipmentClientInfo$LayerType;Lnet/minecraft/resources/ResourceKey;)V
accessible method net/minecraft/client/renderer/entity/layers/EquipmentLayerRenderer$LayerTextureKey <init> (Lnet/minecraft/client/resources/model/EquipmentClientInfo$LayerType;Lnet/minecraft/client/resources/model/EquipmentClientInfo$Layer;)V
extendable method net/minecraft/client/model/Model renderToBuffer (Lcom/mojang/blaze3d/vertex/PoseStack;Lcom/mojang/blaze3d/vertex/VertexConsumer;III)V
</#if>

<#if w.hasElementsOfType("gui")>
accessible method net/minecraft/client/gui/components/AbstractSliderButton getSprite ()Lnet/minecraft/resources/ResourceLocation;
accessible method net/minecraft/client/gui/components/AbstractSliderButton getHandleSprite ()Lnet/minecraft/resources/ResourceLocation;
</#if>

accessible field net/minecraft/world/item/BucketItem content Lnet/minecraft/world/level/material/Fluid;
accessible field net/minecraft/world/level/block/LiquidBlock fluid Lnet/minecraft/world/level/material/FlowingFluid;

accessible method net/minecraft/world/item/CreativeModeTab$Builder type (Lnet/minecraft/world/item/CreativeModeTab$Type;)Lnet/minecraft/world/item/CreativeModeTab$Builder;

# Start of user code block custom AWs
# End of user code block custom AWs