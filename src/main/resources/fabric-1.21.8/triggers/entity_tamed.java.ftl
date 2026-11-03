<#include "procedures.java.ftl">
public ${name}Procedure() {
	LivingEntityEvents.TAMED.register((animal, player) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "animal.getX()",
				"y": "animal.getY()",
				"z": "animal.getZ()",
				"world": "animal.level()",
				"entity": "animal",
				"sourceentity": "player"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
