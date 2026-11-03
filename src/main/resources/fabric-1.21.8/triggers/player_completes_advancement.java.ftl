<#include "procedures.java.ftl">
public ${name}Procedure() {
	PlayerEvents.ADVANCEMENT.register((player, advancement) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "player.getX()",
				"y": "player.getY()",
				"z": "player.getZ()",
				"world": "player.level()",
				"entity": "player",
				"advancement": "advancement.value()"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
