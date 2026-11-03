<#assign mixins = []>
<#assign client_mixins = []>
<#-- Mixins contributed by mod element definitions through the 2026.3 fragments system -->
<#if fragments.mixin??><#assign mixins = mixins + fragments.mixin></#if>
<#if w.hasElementsOfBaseType('item')>
	<#assign mixins = mixins + ['RepairItemRecipeMixin']>
	<#assign mixins = mixins + ['ServerPlayerMixin']>
</#if>
<#if w.hasElementsOfType('attribute')>
	<#assign mixins = mixins + ['AttributeSupplierAccessor']>
</#if>
<#if w.hasElementsOfType('armor')>
	<#assign mixins = mixins + ['PiglinAiMixin']>
	<#assign client_mixins = client_mixins + ['EquipmentLayerRendererMixin']>
</#if>
<#if w.getGElementsOfType('livingentity')?filter(e -> e.spawnInDungeons)?size != 0>
	<#assign mixins = mixins + ['MonsterRoomFeatureMixin']>
</#if>
<#assign mixins = mixins + ['LivingEntityMixin']>
<#assign mixins = mixins + ['PlayerMixin']>
<#assign mixins = mixins + ['ItemStackMixin']>
<#assign mixins = mixins + ['BlockItemMixin']>
<#assign mixins = mixins + ['BoneMealItemMixin']>
<#assign mixins = mixins + ['CommandsMixin']>
<#assign mixins = mixins + ['ExperienceOrbMixin']>
<#assign mixins = mixins + ['ResultSlotMixin']>
<#assign mixins = mixins + ['PlayerAdvancementsMixin']>
<#assign mixins = mixins + ['PlayerCriticalMixin']>
<#assign mixins = mixins + ['FishingHookMixin']>
<#assign mixins = mixins + ['TamableAnimalMixin']>
<#assign mixins = mixins + ['CropGrowthMixin']>
<#assign mixins = mixins + ['EntityThunderMixin']>
<#assign mixins = mixins + ['ExplosionMixin']>
<#assign mixins = mixins + ['FarmBlockMixin']>
<#assign mixins = mixins + ['FurnaceResultSlotMixin']>
<#assign mixins = mixins + ['HoeItemMixin']>
<#assign mixins = mixins + ['ItemEntityMixin']>
<#assign mixins = mixins + ['MobMixin']>
<#assign mixins = mixins + ['SaplingGrowthMixin']>
<#assign mixins = mixins + ['PlayerEventsMixin']>
<#assign mixins = mixins + ['ServerGamePacketListenerImplMixin']>
{
  "required": true,
  "package": "${package}.mixin",
  "compatibilityLevel": "JAVA_21",
  "refmap": "${modid}.refmap.json",
  "mixins": [
	<#list mixins as mixin>"${mixin}"<#sep>,</#list>
  ],
  "client": [
	<#list client_mixins as mixin>"${mixin}"<#sep>,</#list>
  ],
  "injectors": {
	"defaultRequire": 1
  },
  "minVersion": "0.8.4"
}