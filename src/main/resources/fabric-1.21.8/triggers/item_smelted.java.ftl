<#include "procedures.java.ftl">
public ${name}Procedure() {
		${package}.trigger.${JavaModName}Triggers.ITEM_SMELTED.add((player, stack) -> {
			<#assign dependenciesCode>
				<@procedureDependenciesCode dependencies, {
					"x": "player.getX()",
					"y": "player.getY()",
					"z": "player.getZ()",
					"world": "player.level()",
					"entity": "player",
					"itemstack": "stack"
				}/>
			</#assign>
			execute(<#if dependenciesCode?has_content>${dependenciesCode}</#if>);
		});
	}
