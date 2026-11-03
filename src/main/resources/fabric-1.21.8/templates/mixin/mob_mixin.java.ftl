<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(Mob.class)
public class MobMixin {

	@Inject(method = "setTarget", at = @At("HEAD"), require = 0)
	private void onSetTarget(LivingEntity target, CallbackInfo callback) {
		Mob mob = (Mob) (Object) this;
		${JavaModName}Triggers.fireTargetChange(mob, mob.getTarget(), target);
	}
}
<#-- @formatter:on -->
