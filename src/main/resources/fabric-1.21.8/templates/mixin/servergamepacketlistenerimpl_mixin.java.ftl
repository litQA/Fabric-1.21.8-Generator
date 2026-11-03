<#-- @formatter:off -->
package ${package}.mixin;

import ${package}.trigger.${JavaModName}Triggers;

@Mixin(ServerGamePacketListenerImpl.class)
public class ServerGamePacketListenerImplMixin {

	@Inject(method = "handleAnimate", at = @At("HEAD"), require = 0)
	private void onAnimate(ServerboundSwingPacket packet, CallbackInfo callback) {
		ServerGamePacketListenerImpl listener = (ServerGamePacketListenerImpl) (Object) this;
		if (listener.player != null && packet.getHand() == InteractionHand.MAIN_HAND
				&& listener.player.pick(4.5D, 0.0F, false).getType() == HitResult.Type.MISS)
			${JavaModName}Triggers.fireLeftClickAir(listener.player);
	}
}
<#-- @formatter:on -->
