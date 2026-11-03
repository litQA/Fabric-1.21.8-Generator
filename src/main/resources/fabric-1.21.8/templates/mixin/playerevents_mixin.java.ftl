<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(ServerPlayer.class)
public class PlayerEventsMixin {

	@Inject(method = "drop(Lnet/minecraft/world/item/ItemStack;ZZ)Lnet/minecraft/world/entity/item/ItemEntity;", at = @At("RETURN"), require = 0)
	private void onDrop(ItemStack stack, boolean dropAround, boolean traceItem, CallbackInfoReturnable<ItemEntity> callback) {
		ItemEntity dropped = callback.getReturnValue();
		if (dropped != null && !dropped.getItem().isEmpty())
			${JavaModName}Triggers.fireGemDropped((ServerPlayer) (Object) this, dropped.getItem());
	}
}
<#-- @formatter:on -->
