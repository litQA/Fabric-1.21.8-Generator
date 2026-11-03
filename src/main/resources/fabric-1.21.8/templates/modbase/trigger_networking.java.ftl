<#-- @formatter:off -->
package ${package}.trigger;

public final class ${JavaModName}TriggerNetworking {

	private ${JavaModName}TriggerNetworking() {
	}

	public static void register() {
		PayloadTypeRegistry.playC2S().register(ClientTriggerPayload.TYPE, ClientTriggerPayload.STREAM_CODEC);
		ServerPlayNetworking.registerGlobalReceiver(ClientTriggerPayload.TYPE, (payload, context) -> {
			context.server().execute(() -> {
				ServerPlayer player = context.player();
				if (player != null && payload.id() == 1)
					${JavaModName}Triggers.fireRightClickEmptyHand(player);
			});
		});
	}
}
<#-- @formatter:on -->
