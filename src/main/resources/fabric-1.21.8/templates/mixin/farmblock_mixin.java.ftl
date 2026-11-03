<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(FarmBlock.class)
public class FarmBlockMixin {

	@Inject(method = "fallOn", at = @At("HEAD"), require = 0)
	private void onFallOn(Level level, BlockState state, BlockPos pos, Entity entity, double distance, CallbackInfo callback) {
		${JavaModName}Triggers.fireFarmlandTrampled(level, pos, state, entity, (float) distance);
	}
}
<#-- @formatter:on -->
