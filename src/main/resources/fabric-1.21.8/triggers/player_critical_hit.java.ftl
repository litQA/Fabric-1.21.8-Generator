<#include "procedures.java.ftl">
public ${name}Procedure() {
	PlayerEvents.CRITICAL_HIT.register((player, target, critical) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "player.getX()",
				"y": "player.getY()",
				"z": "player.getZ()",
				"world": "player.level()",
				"entity": "target",
				"sourceentity": "player",
				"damagemodifier": "critical ? 1.5f : 1.0f",
				"isvanillacritical": "critical"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
