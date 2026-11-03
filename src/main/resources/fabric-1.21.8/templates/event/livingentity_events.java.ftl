<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2020-2025, Goldorion, opensource contributors
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
package ${package}.event;

public class LivingEntityEvents {

	public static final Event<StartUseItem> START_USE_ITEM = EventFactory.createArrayBacked(StartUseItem.class, (callbacks) -> (entity, itemstack) -> Arrays.stream(callbacks).forEach(callback -> callback.onStartUseItem(entity, itemstack)));

	public static final Event<EntityHeal> ENTITY_HEAL = EventFactory.createArrayBacked(EntityHeal.class, (callbacks) -> (entity, amount) -> {
		for (EntityHeal event : callbacks) {
			boolean result = event.onEntityHeal(entity, amount);
			if (!result) {
				return false;
			}
		}
		return true;
	});
	
    public static final Event<EntityBlock> ENTITY_BLOCK = EventFactory.createArrayBacked(EntityBlock.class, (callbacks) -> (entity, damagesource, amount) -> {
		for (EntityBlock event : callbacks) {
			boolean result = event.onEntityBlock(entity, damagesource, amount);
			if (!result) {
				return false;
			}
		}
		return true;
	});

    public static final Event<EntityDropXp> ENTITY_DROP_XP = EventFactory.createArrayBacked(EntityDropXp.class, (callbacks) -> (entity, sourceentity, amount) -> {
		for (EntityDropXp event : callbacks) {
			boolean result = event.onEntityDropXp(entity, sourceentity, amount);
			if (!result) {
				return false;
			}
		}
		return true;
	});

    public static final Event<EntityFall> ENTITY_FALL = EventFactory.createArrayBacked(EntityFall.class, (callbacks) -> (entity, falldistance, damagemultiplier) -> {
		for (EntityFall event : callbacks) {
			boolean result = event.onEntityFall(entity, falldistance, damagemultiplier);
			if (!result) {
				return false;
			}
		}
		return true;
	});

	public static final Event<EntityPickupItem> ENTITY_PICKUP_ITEM = EventFactory.createArrayBacked(EntityPickupItem.class, (callbacks) -> (entity, itemstack) -> Arrays.stream(callbacks).forEach(callback -> callback.onEntityPickupItem(entity, itemstack)));
    public static final Event<EntityJump> ENTITY_JUMP = EventFactory.createArrayBacked(EntityJump.class, (callbacks) -> (entity) -> Arrays.stream(callbacks).forEach(callback -> callback.onEntityJump(entity)));
	public static final Event<EntityStopUsingItem> ENTITY_STOP_USING_ITEM = EventFactory.createArrayBacked(EntityStopUsingItem.class, (callbacks) -> (entity, itemstack, duration) -> Arrays.stream(callbacks).forEach(callback -> callback.onStopUsingItem(entity, itemstack, duration)));
	public static final Event<FinishUsingItem> FINISH_USING_ITEM = EventFactory.createArrayBacked(FinishUsingItem.class, (callbacks) -> (entity, itemstack, duration) -> Arrays.stream(callbacks).forEach(callback -> callback.onFinishUsingItem(entity, itemstack, duration)));
	/**
	 * Fired when a living entity changes an equipment slot. The listener receives the previous and the new stack.
	 */
	public static final Event<EquipmentChange> EQUIPMENT_CHANGE = EventFactory.createArrayBacked(EquipmentChange.class, (callbacks) -> (entity, slot, previous, current) -> Arrays.stream(callbacks).forEach(callback -> callback.onEquipmentChange(entity, slot, previous, current)));
	/**
	 * Fired at the end of the living entity tick.
	 */
	public static final Event<TickEnd> END_ENTITY_TICK = EventFactory.createArrayBacked(TickEnd.class, (callbacks) -> (entity) -> Arrays.stream(callbacks).forEach(callback -> callback.onEndTick(entity)));
	/**
	 * Fired after a tamable animal has been tamed by a player.
	 */
	public static final Event<Tamed> TAMED = EventFactory.createArrayBacked(Tamed.class, (callbacks) -> (animal, player) -> Arrays.stream(callbacks).forEach(callback -> callback.onTamed(animal, player)));

	@FunctionalInterface
	public interface StartUseItem {
		void onStartUseItem(Entity entity, ItemStack itemstack);
	}

	@FunctionalInterface
	public interface EntityHeal {
		boolean onEntityHeal(Entity entity, float amount);
	}

	@FunctionalInterface
	public interface EntityBlock {
		boolean onEntityBlock(Entity entity, DamageSource damagesource, double amount);
	}

	@FunctionalInterface
	public interface EntityDropXp {
		boolean onEntityDropXp(Entity entity, Entity sourceentity, double amount);
	}

	@FunctionalInterface
	public interface EntityFall {
		boolean onEntityFall(Entity entity, double falldistance, double damagemultiplier);
	}

	@FunctionalInterface
	public interface EntityPickupItem {
		void onEntityPickupItem(Entity entity, ItemStack itemstack);
	}

	@FunctionalInterface
	public interface EntityJump {
		void onEntityJump(Entity entity);
	}

	@FunctionalInterface
	public interface EntityStopUsingItem {
		void onStopUsingItem(Entity entity, ItemStack itemstack, int duration);
	}

	@FunctionalInterface
	public interface FinishUsingItem {
		void onFinishUsingItem(Entity entity, ItemStack itemstack, int duration);
	}

	@FunctionalInterface
	public interface EquipmentChange {
		void onEquipmentChange(LivingEntity entity, EquipmentSlot slot, ItemStack previous, ItemStack current);
	}

	@FunctionalInterface
	public interface TickEnd {
		void onEndTick(LivingEntity entity);
	}

	@FunctionalInterface
	public interface Tamed {
		void onTamed(TamableAnimal animal, Player player);
	}
		
}
<#-- @formatter:on -->