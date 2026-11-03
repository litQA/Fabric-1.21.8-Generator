<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(ItemEntity.class)
public class ItemEntityMixin {

	@org.spongepowered.asm.mixin.Unique private ItemStack mcreatorPickupStack = ItemStack.EMPTY;

	@Inject(method = "playerTouch", at = @At("HEAD"), require = 0)
	private void onPlayerTouchStart(Player player, CallbackInfo callback) {
		this.mcreatorPickupStack = ((ItemEntity) (Object) this).getItem().copy();
	}

	@Inject(method = "playerTouch", at = @At("RETURN"), require = 0)
	private void onPlayerTouchEnd(Player player, CallbackInfo callback) {
		ItemEntity entity = (ItemEntity) (Object) this;
		if (entity.isRemoved() && !this.mcreatorPickupStack.isEmpty())
			${JavaModName}Triggers.fireItemPickup(player, this.mcreatorPickupStack);
	}

	@Inject(method = "tick", at = @At("RETURN"), require = 0)
	private void onTick(CallbackInfo callback) {
		ItemEntity entity = (ItemEntity) (Object) this;
		if (entity.isRemoved() && !entity.getItem().isEmpty())
			${JavaModName}Triggers.fireItemExpired(entity, entity.getItem().copy());
	}
}
<#-- @formatter:on -->
