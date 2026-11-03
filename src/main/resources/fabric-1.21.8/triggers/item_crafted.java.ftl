<#include "procedures.java.ftl">
public ${name}Procedure() {
	ItemEvents.ITEM_CRAFTED.register((player, itemstack) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "player.getX()",
				"y": "player.getY()",
				"z": "player.getZ()",
				"world": "player.level()",
				"entity": "player",
				"itemstack": "itemstack"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
