<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(Entity.class)
public class EntityThunderMixin {

	@Inject(method = "thunderHit", at = @At("HEAD"), require = 0)
	private void onThunderHit(ServerLevel level, LightningBolt bolt, CallbackInfo callback) {
		${JavaModName}Triggers.fireStruckByLightning((Entity) (Object) this, bolt);
	}
}
<#-- @formatter:on -->
