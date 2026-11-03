<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.FARMLAND_TRAMPLED.add((world, pos, state, entity, distance) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "pos.getX()", "y": "pos.getY()", "z": "pos.getZ()",
					"world": "world", "entity": "entity", "blockstate": "state",
					"falldistance": "distance"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
		});
	}
