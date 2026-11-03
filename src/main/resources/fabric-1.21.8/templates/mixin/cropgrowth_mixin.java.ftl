<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(CropBlock.class)
public class CropGrowthMixin {

	@Inject(method = "growCrops", at = @At("HEAD"), cancellable = true, require = 0)
	private void onGrowCrops(Level level, BlockPos pos, BlockState state, CallbackInfo callback) {
		if (!${JavaModName}Triggers.fireCropGrowth(level, pos, state))
			callback.cancel();
	}
}
<#-- @formatter:on -->
