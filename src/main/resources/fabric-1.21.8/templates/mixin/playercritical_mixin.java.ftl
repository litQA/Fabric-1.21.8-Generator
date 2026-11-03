<#-- @formatter:off -->
package ${package}.mixin;

@Mixin(Player.class)
public class PlayerCriticalMixin {

	@Inject(method = "attack", at = @At("HEAD"), require = 0)
	private void onAttack(Entity target, CallbackInfo ci) {
		Player player = (Player) (Object) this;
		if (player.level() == null || player.level().isClientSide || target == null)
			return;
		boolean critical = player.fallDistance > 0.0F && !player.onGround() && !player.onClimbable()
				&& !player.isInWater() && !player.isPassenger() && !player.hasEffect(MobEffects.BLINDNESS);
		PlayerEvents.CRITICAL_HIT.invoker().onCriticalHit(player, target, critical);
	}
}
<#-- @formatter:on -->
