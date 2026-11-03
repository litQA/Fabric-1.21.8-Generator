<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(TreeGrower.class)
public class SaplingGrowthMixin {

	@Inject(method = "growTree", at = @At("RETURN"), require = 0)
	private void onGrowTree(ServerLevel level, ChunkGenerator generator, BlockPos pos, BlockState state, RandomSource random, CallbackInfoReturnable<Boolean> callback) {
		if (callback.getReturnValueZ() && level.getBlockState(pos).getBlock() != state.getBlock())
			${JavaModName}Triggers.fireSaplingGrowth(level, pos, state);
	}
}
<#-- @formatter:on -->
