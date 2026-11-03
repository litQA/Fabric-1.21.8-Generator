<#include "procedures.java.ftl">
public ${name}Procedure() {
	PlayerEvents.FISHED_ITEM.register((player, itemstack) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "player.getX()",
				"y": "player.getY()",
				"z": "player.getZ()",
				"world": "player.level()",
				"entity": "player"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
