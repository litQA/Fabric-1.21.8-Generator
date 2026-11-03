<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.TARGET_CHANGE.add((mob, oldTarget, newTarget) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "mob.getX()",
					"y": "mob.getY()",
					"z": "mob.getZ()",
					"world": "mob.level()",
					"entity": "oldTarget",
					"sourceentity": "mob"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
		});
	}
