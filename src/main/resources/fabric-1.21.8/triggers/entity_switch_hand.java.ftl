<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.SWITCH_HAND.add((entity, main, off) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "entity.getX()", "y": "entity.getY()", "z": "entity.getZ()",
					"world": "entity.level()", "entity": "entity",
					"newmainhanditem": "main", "newoffhanditem": "off"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
		});
	}
