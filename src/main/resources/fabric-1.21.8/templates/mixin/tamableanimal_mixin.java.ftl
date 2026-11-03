<#-- @formatter:off -->
package ${package}.mixin;

@Mixin(TamableAnimal.class)
public class TamableAnimalMixin {

	@Inject(method = "tame", at = @At("RETURN"), require = 0)
	private void onTame(Player player, CallbackInfo ci) {
		TamableAnimal animal = (TamableAnimal) (Object) this;
		if (player != null && player.level() != null && !player.level().isClientSide)
			LivingEntityEvents.TAMED.invoker().onTamed(animal, player);
	}
}
<#-- @formatter:on -->
