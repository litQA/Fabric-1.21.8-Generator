<#-- @formatter:off -->
package ${package}.mixin;

@Mixin(ResultSlot.class)
public class ResultSlotMixin {

	@Inject(method = "onTake", at = @At("RETURN"), require = 0)
	private void onTake(Player player, ItemStack itemStack, CallbackInfo ci) {
		if (player != null && player.level() != null && !player.level().isClientSide)
			ItemEvents.ITEM_CRAFTED.invoker().onItemCrafted(player, itemStack.copy());
	}
}
<#-- @formatter:on -->
