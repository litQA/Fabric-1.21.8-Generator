<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(ServerExplosion.class)
public class ExplosionMixin {

	@Inject(method = "explode", at = @At("HEAD"), require = 0)
	private void onExplode(CallbackInfo callback) {
		ServerExplosion explosion = (ServerExplosion) (Object) this;
		Vec3 center = explosion.center();
		${JavaModName}Triggers.fireExplosion(explosion.level(), center.x, center.y, center.z);
	}
}
<#-- @formatter:on -->
