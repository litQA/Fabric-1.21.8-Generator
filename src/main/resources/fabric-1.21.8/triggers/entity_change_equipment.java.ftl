<#include "procedures.java.ftl">
public ${name}Procedure() {
	LivingEntityEvents.EQUIPMENT_CHANGE.register((entity, slot, previous, current) -> {
		<#assign dependenciesCode>
			<@procedureDependenciesCode dependencies, {
				"x": "entity.getX()",
				"y": "entity.getY()",
				"z": "entity.getZ()",
				"world": "entity.level()",
				"entity": "entity",
				"equipmentslot": "slot.getId()",
				"olditemstack": "previous",
				"newitemstack": "current"
			}/>
		</#assign>
		execute(${dependenciesCode});
	});
}
