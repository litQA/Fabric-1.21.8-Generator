<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.CROP_GROWTH.add((world, pos, state) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "pos.getX()", "y": "pos.getY()", "z": "pos.getZ()",
					"world": "world", "blockstate": "state"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
			return true;
		});
	}
