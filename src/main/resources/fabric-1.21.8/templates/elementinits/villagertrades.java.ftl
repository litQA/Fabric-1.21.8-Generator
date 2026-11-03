<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2020-2026, Goldorion, opensource contributors
 #
 # Fabric-Generator-MCreator is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Fabric-Generator-MCreator is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with Fabric-Generator-MCreator. If not, see <https://www.gnu.org/licenses/>.
-->

<#-- @formatter:off -->
<@javacompress>
<#include "../mcitems.ftl">

/*
*	MCreator note: This file will be REGENERATED on each build.
*/

package ${package}.init;

import net.minecraft.world.entity.npc.VillagerTrades;

public class ${JavaModName}Trades {

    private static final ResourceLocation CUSTOM_WANDERING_TRADER_POOL = ResourceLocation.fromNamespaceAndPath(${JavaModName}.MODID, "custom_wandering_trader_pool");

	public static void registerTrades() {
		<#list villagertrades as trade>
			<#if trade.isWanderingTrader()>
			TradeOfferHelper.registerWanderingTraderOffers(builder -> {
				builder.pool(CUSTOM_WANDERING_TRADER_POOL, 5,
					<#list trade.trades as entry>
						<@basicTrade entry.price1, entry.countPrice1, !entry.price2.isEmpty(), entry.price2, entry.countPrice2, entry.offer, entry.countOffer, entry.maxTrades, entry.xp, entry.priceMultiplier/><#sep>,
					</#list>
				);
			});
			<#else>
			<#list 1..5 as level>
				<#assign levelTrades = trade.trades?filter(entry -> entry.level == level)>
				<#if levelTrades?has_content>
				TradeOfferHelper.registerVillagerOffers(${trade.villagerProfession}, ${level},
					builder -> {
						<#list levelTrades as entry>
							builder.add(<@basicTrade entry.price1, entry.countPrice1, !entry.price2.isEmpty(), entry.price2, entry.countPrice2, entry.offer, entry.countOffer, entry.maxTrades, entry.xp, entry.priceMultiplier/>);
						</#list>
					});
				</#if>
			</#list>
			</#if>
		</#list>
	}

	private record BasicTrade(ItemStack price, ItemStack price2, ItemStack offer, int maxTrades, int xp,
							  float priceMult) implements VillagerTrades.ItemListing {
		@Override
		public @NotNull MerchantOffer getOffer(Entity entity, RandomSource random) {
			return new MerchantOffer(new ItemCost(price.getItem(), price.getCount()), Optional.of(new ItemCost(price2.getItem(), price2.getCount())), offer, maxTrades, xp, priceMult);
		}
	}
}
</@javacompress>

<#macro basicTrade price1 countPrice1 hasPrice2 price2 countPrice2 offer countOffer maxTrades xp priceMultiplier>
new BasicTrade(${mappedMCItemToItemStackCode(price1, countPrice1)},
    <#if hasPrice2>${mappedMCItemToItemStackCode(price2, countPrice2)}
	<#else> ItemStack.EMPTY</#if>, ${mappedMCItemToItemStackCode(offer, countOffer)},
	${maxTrades}, ${xp}, ${priceMultiplier}f
)
</#macro>
