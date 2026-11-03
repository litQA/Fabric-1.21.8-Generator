<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(HoeItem.class)
public class HoeItemMixin {

	@Inject(method = "useOn", at = @At("HEAD"), require = 0)
	private void onUseOn(UseOnContext context, CallbackInfoReturnable<InteractionResult> callback) {
		if (context.getPlayer() != null)
			${JavaModName}Triggers.fireUseHoe(context.getPlayer(), context.getClickedPos(), context.getLevel().getBlockState(context.getClickedPos()));
	}
}
<#-- @formatter:on -->
