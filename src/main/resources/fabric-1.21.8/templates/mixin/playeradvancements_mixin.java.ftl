<#-- @formatter:off -->
package ${package}.mixin;

@Mixin(PlayerAdvancements.class)
public class PlayerAdvancementsMixin {

	@Shadow private ServerPlayer player;

	@Inject(method = "award", at = @At("RETURN"), require = 0)
	private void onAward(AdvancementHolder advancement, String criterion, CallbackInfoReturnable<Boolean> cir) {
		if (cir.getReturnValueZ() && this.player != null)
			PlayerEvents.ADVANCEMENT.invoker().onAdvancement(this.player, advancement);
	}
}
<#-- @formatter:on -->
