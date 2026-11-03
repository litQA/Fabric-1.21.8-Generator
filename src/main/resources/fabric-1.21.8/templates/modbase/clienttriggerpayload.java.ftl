<#-- @formatter:off -->
package ${package}.trigger;

public record ClientTriggerPayload(byte id) implements CustomPacketPayload {

	public static final CustomPacketPayload.Type<ClientTriggerPayload> TYPE = new CustomPacketPayload.Type<>(
			ResourceLocation.fromNamespaceAndPath(${package}.${JavaModName}.MODID, "client_trigger"));

	public static final StreamCodec<RegistryFriendlyByteBuf, ClientTriggerPayload> STREAM_CODEC = CustomPacketPayload
			.codec(ClientTriggerPayload::write, ClientTriggerPayload::new);

	private void write(RegistryFriendlyByteBuf buf) {
		buf.writeByte(this.id);
	}

	public ClientTriggerPayload(RegistryFriendlyByteBuf buf) {
		this(buf.readByte());
	}

	@Override
	public CustomPacketPayload.Type<? extends CustomPacketPayload> type() {
		return TYPE;
	}
}
<#-- @formatter:on -->
