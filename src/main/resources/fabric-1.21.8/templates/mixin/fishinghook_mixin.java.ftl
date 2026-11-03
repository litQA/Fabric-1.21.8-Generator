<#-- @formatter:off -->
package ${package}.mixin;

@Mixin(FishingHook.class)
public class FishingHookMixin {

	@Inject(method = "retrieve", at = @At("HEAD"), require = 0)
	private void onRetrieve(ItemStack stack, CallbackInfoReturnable<Integer> cir) {
		FishingHook hook = (FishingHook) (Object) this;
		Player owner = hook.getPlayerOwner();
		if (owner != null && owner.level() != null && !owner.level().isClientSide)
			PlayerEvents.FISHED_ITEM.invoker().onFishedItem(owner, stack.copy());
	}
}
<#-- @formatter:on -->
