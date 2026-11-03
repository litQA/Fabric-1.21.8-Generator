<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.EXPLOSION.add((world, x, y, z) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "x", "y": "y", "z": "z", "world": "world"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
		});
	}
