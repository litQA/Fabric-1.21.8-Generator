<#list fragments.accesstransformer as fragment>
${fragment}
</#list>

<#if w.hasElementsOfType("armor")>
public-f net.minecraft.client.model.Model renderToBuffer(Lcom/mojang/blaze3d/vertex/PoseStack;Lcom/mojang/blaze3d/vertex/VertexConsumer;III)V
</#if>

# Start of user code block custom ATs
# End of user code block custom ATs
