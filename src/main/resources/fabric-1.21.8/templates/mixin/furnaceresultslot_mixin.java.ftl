<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(FurnaceResultSlot.class)
public class FurnaceResultSlotMixin {

	@Inject(method = "onTake", at = @At("RETURN"), require = 0)
	private void onTake(Player player, ItemStack stack, CallbackInfo callback) {
		${JavaModName}Triggers.fireItemSmelted(player, stack);
	}
}
<#-- @formatter:on -->
