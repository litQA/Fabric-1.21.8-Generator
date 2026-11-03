<#-- @formatter:off -->
package ${package}.trigger;

import net.minecraft.core.BlockPos;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.LightningBolt;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.Mob;
import net.minecraft.world.entity.TamableAnimal;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.commands.CommandSourceStack;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class ${JavaModName}Triggers {

	public interface BlockPlace { void on(Level world, BlockPos pos, BlockState state, BlockState placedAgainst, Entity entity); }
	public interface ItemCrafted { void on(Player player, ItemStack stack); }
	public interface ItemSmelted { void on(Player player, ItemStack stack); }
	public interface ItemDestroyed { void on(LivingEntity entity, ItemStack stack); }
	public interface Advancement { void on(ServerPlayer player, net.minecraft.advancements.AdvancementHolder advancement); }
	public interface Command { void on(CommandSourceStack source, String command, com.mojang.brigadier.context.CommandContext<CommandSourceStack> arguments); }
	public interface EquipmentChange { void on(LivingEntity entity, EquipmentSlot slot, ItemStack oldStack, ItemStack newStack); }
	public interface Healed { void on(LivingEntity entity, float amount); }
	public interface Falls { void on(LivingEntity entity, float distance, float multiplier, DamageSource source); }
	public interface Jumps { void on(LivingEntity entity); }
	public interface StruckByLightning { void on(Entity entity, LightningBolt bolt); }
	public interface Tamed { void on(TamableAnimal animal, Player player); }
	public interface SwitchHand { void on(LivingEntity entity, ItemStack main, ItemStack off); }
	public interface TargetChange { void on(Mob mob, LivingEntity oldTarget, LivingEntity newTarget); }
	public interface UseTotem { void on(LivingEntity entity, DamageSource source, ItemStack totem); }
	public interface InBed { void on(Player player, BlockPos pos); }
	public interface ItemExpired { void on(net.minecraft.world.entity.item.ItemEntity entity, ItemStack stack); }
	public interface ShieldBlock { void on(LivingEntity entity, DamageSource source, float amount); }
	public interface WakesUp { void on(Player player); }
	public interface FishedItem { void on(Player player, ItemStack stack); }
	public interface UseHoe { void on(Player player, BlockPos pos, BlockState state); }
	public interface UseItemStart { void on(LivingEntity entity, ItemStack stack, int duration); }
	public interface UseItemStop { void on(LivingEntity entity, ItemStack stack, int duration); }
	public interface UseItemFinish { void on(LivingEntity entity, ItemStack stack, int duration); }
	public interface XpChange { void on(Player player, int amount); }
	public interface XpLevelChange { void on(Player player, int levels); }
	public interface DropXp { void on(LivingEntity entity, int dropped, int original, Entity source); }
	public interface PickupXp { void on(Player player); }
	public interface ItemPickup { void on(Player player, ItemStack stack); }
	public interface GemDropped { void on(Player player, ItemStack stack); }
	public interface Explosion { void on(Level world, double x, double y, double z); }
	public interface FarmlandTrampled { void on(Level world, BlockPos pos, BlockState state, Entity entity, float distance); }

	public static final List<BlockPlace> BLOCK_PLACE = new CopyOnWriteArrayList<>();
	public static final List<ItemCrafted> ITEM_CRAFTED = new CopyOnWriteArrayList<>();
	public static final List<ItemSmelted> ITEM_SMELTED = new CopyOnWriteArrayList<>();
	public static final List<ItemDestroyed> ITEM_DESTROYED = new CopyOnWriteArrayList<>();
	public static final List<Advancement> ADVANCEMENT = new CopyOnWriteArrayList<>();
	public static final List<Command> COMMAND = new CopyOnWriteArrayList<>();
	public static final List<EquipmentChange> EQUIPMENT_CHANGE = new CopyOnWriteArrayList<>();
	public static final List<Healed> HEALED = new CopyOnWriteArrayList<>();
	public static final List<Falls> FALLS = new CopyOnWriteArrayList<>();
	public static final List<Jumps> JUMPS = new CopyOnWriteArrayList<>();
	public static final List<StruckByLightning> STRUCK_BY_LIGHTNING = new CopyOnWriteArrayList<>();
	public static final List<Tamed> TAMED = new CopyOnWriteArrayList<>();
	public static final List<SwitchHand> SWITCH_HAND = new CopyOnWriteArrayList<>();
	public static final List<TargetChange> TARGET_CHANGE = new CopyOnWriteArrayList<>();
	public static final List<UseTotem> USE_TOTEM = new CopyOnWriteArrayList<>();
	public static final List<InBed> IN_BED = new CopyOnWriteArrayList<>();
	public static final List<ItemExpired> ITEM_EXPIRED = new CopyOnWriteArrayList<>();
	public static final List<ShieldBlock> SHIELD_BLOCK = new CopyOnWriteArrayList<>();
	public static final List<WakesUp> WAKES_UP = new CopyOnWriteArrayList<>();
	public static final List<FishedItem> FISHED_ITEM = new CopyOnWriteArrayList<>();
	public static final List<UseHoe> USE_HOE = new CopyOnWriteArrayList<>();
	public static final List<UseItemStart> USE_ITEM_START = new CopyOnWriteArrayList<>();
	public static final List<UseItemStop> USE_ITEM_STOP = new CopyOnWriteArrayList<>();
	public static final List<UseItemFinish> USE_ITEM_FINISH = new CopyOnWriteArrayList<>();
	public static final List<XpChange> XP_CHANGE = new CopyOnWriteArrayList<>();
	public static final List<XpLevelChange> XP_LEVEL_CHANGE = new CopyOnWriteArrayList<>();
	public static final List<DropXp> DROP_XP = new CopyOnWriteArrayList<>();
	public static final List<PickupXp> PICKUP_XP = new CopyOnWriteArrayList<>();
	public static final List<ItemPickup> ITEM_PICKUP = new CopyOnWriteArrayList<>();
	public static final List<GemDropped> GEM_DROPPED = new CopyOnWriteArrayList<>();
	public static final List<Explosion> EXPLOSION = new CopyOnWriteArrayList<>();
	public static final List<FarmlandTrampled> FARMLAND_TRAMPLED = new CopyOnWriteArrayList<>();

	public static void fireBlockPlace(Level world, BlockPos pos, BlockState state, BlockState placedAgainst, Entity entity) {
		for (BlockPlace listener : BLOCK_PLACE) listener.on(world, pos, state, placedAgainst, entity);
	}

	public static void fireItemCrafted(Player player, ItemStack stack) {
		for (ItemCrafted listener : ITEM_CRAFTED) listener.on(player, stack);
	}

	public static void fireItemSmelted(Player player, ItemStack stack) {
		for (ItemSmelted listener : ITEM_SMELTED) listener.on(player, stack);
	}

	public static void fireItemDestroyed(LivingEntity entity, ItemStack stack) {
		for (ItemDestroyed listener : ITEM_DESTROYED) listener.on(entity, stack);
	}

	public static void fireAdvancement(ServerPlayer player, net.minecraft.advancements.AdvancementHolder advancement) {
		for (Advancement listener : ADVANCEMENT) listener.on(player, advancement);
	}

	public static void fireCommand(CommandSourceStack source, String command, com.mojang.brigadier.context.CommandContext<CommandSourceStack> arguments) {
		for (Command listener : COMMAND) listener.on(source, command, arguments);
	}

	public static void fireEquipmentChange(LivingEntity entity, EquipmentSlot slot, ItemStack oldStack, ItemStack newStack) {
		for (EquipmentChange listener : EQUIPMENT_CHANGE) listener.on(entity, slot, oldStack, newStack);
	}

	public static void fireHealed(LivingEntity entity, float amount) {
		for (Healed listener : HEALED) listener.on(entity, amount);
	}

	public static void fireFalls(LivingEntity entity, float distance, float multiplier, DamageSource source) {
		for (Falls listener : FALLS) listener.on(entity, distance, multiplier, source);
	}

	public static void fireJumps(LivingEntity entity) {
		for (Jumps listener : JUMPS) listener.on(entity);
	}

	public static void fireStruckByLightning(Entity entity, LightningBolt bolt) {
		for (StruckByLightning listener : STRUCK_BY_LIGHTNING) listener.on(entity, bolt);
	}

	public static void fireTamed(TamableAnimal animal, Player player) {
		for (Tamed listener : TAMED) listener.on(animal, player);
	}

	public static void fireSwitchHand(LivingEntity entity, ItemStack main, ItemStack off) {
		for (SwitchHand listener : SWITCH_HAND) listener.on(entity, main, off);
	}

	public static void fireTargetChange(Mob mob, LivingEntity oldTarget, LivingEntity newTarget) {
		for (TargetChange listener : TARGET_CHANGE) listener.on(mob, oldTarget, newTarget);
	}

	public static void fireUseTotem(LivingEntity entity, DamageSource source, ItemStack totem) {
		for (UseTotem listener : USE_TOTEM) listener.on(entity, source, totem);
	}

	public static void fireShieldBlock(LivingEntity entity, DamageSource source, float amount) {
		for (ShieldBlock listener : SHIELD_BLOCK) listener.on(entity, source, amount);
	}


	public static void fireWakesUp(Player player) {
		for (WakesUp listener : WAKES_UP) listener.on(player);
	}

	public static void fireFishedItem(Player player, ItemStack stack) {
		for (FishedItem listener : FISHED_ITEM) listener.on(player, stack);
	}

	public static void fireUseHoe(Player player, BlockPos pos, BlockState state) {
		for (UseHoe listener : USE_HOE) listener.on(player, pos, state);
	}

	public static void fireUseItemStart(LivingEntity entity, ItemStack stack, int duration) {
		for (UseItemStart listener : USE_ITEM_START) listener.on(entity, stack, duration);
	}

	public static void fireUseItemStop(LivingEntity entity, ItemStack stack, int duration) {
		for (UseItemStop listener : USE_ITEM_STOP) listener.on(entity, stack, duration);
	}

	public static void fireUseItemFinish(LivingEntity entity, ItemStack stack, int duration) {
		for (UseItemFinish listener : USE_ITEM_FINISH) listener.on(entity, stack, duration);
	}

	public static void fireXpChange(Player player, int amount) {
		for (XpChange listener : XP_CHANGE) listener.on(player, amount);
	}

	public static void fireXpLevelChange(Player player, int levels) {
		for (XpLevelChange listener : XP_LEVEL_CHANGE) listener.on(player, levels);
	}

	public static void fireDropXp(LivingEntity entity, int dropped, int original, Entity source) {
		for (DropXp listener : DROP_XP) listener.on(entity, dropped, original, source);
	}

	public static void firePickupXp(Player player) {
		for (PickupXp listener : PICKUP_XP) listener.on(player);
	}

	public static void fireItemPickup(Player player, ItemStack stack) {
		for (ItemPickup listener : ITEM_PICKUP) listener.on(player, stack);
	}

	public static void fireGemDropped(Player player, ItemStack stack) {
		for (GemDropped listener : GEM_DROPPED) listener.on(player, stack);
	}

	public static void fireExplosion(Level world, double x, double y, double z) {
		for (Explosion listener : EXPLOSION) listener.on(world, x, y, z);
	}

	public static void fireFarmlandTrampled(Level world, BlockPos pos, BlockState state, Entity entity, float distance) {
		for (FarmlandTrampled listener : FARMLAND_TRAMPLED) listener.on(world, pos, state, entity, distance);
	}
	public interface CropGrowth { boolean on(Level world, BlockPos pos, BlockState state); }
	public interface SaplingGrowth { boolean on(Level world, BlockPos pos, BlockState state); }
	public interface DimensionTravel { boolean on(Entity entity); }
	public interface LeftClickAir { boolean on(Player player); }
	public interface RightClickEmptyHand { boolean on(Player player); }
	public interface CriticalHit { boolean on(Player player, Entity target); }

	public static final List<CropGrowth> CROP_GROWTH = new CopyOnWriteArrayList<>();
	public static final List<SaplingGrowth> SAPLING_GROWTH = new CopyOnWriteArrayList<>();
	public static final List<DimensionTravel> DIMENSION_TRAVEL = new CopyOnWriteArrayList<>();
	public static final List<LeftClickAir> LEFT_CLICK_AIR = new CopyOnWriteArrayList<>();
	public static final List<RightClickEmptyHand> RIGHT_CLICK_EMPTY_HAND = new CopyOnWriteArrayList<>();
	public static final List<CriticalHit> CRITICAL_HIT = new CopyOnWriteArrayList<>();

	/** Set to false by the cancel block, read by the event mixins after the listeners ran. */
	public static boolean eventResult = true;

	public static boolean fireCropGrowth(Level world, BlockPos pos, BlockState state) {
		eventResult = true;
		for (CropGrowth listener : CROP_GROWTH) listener.on(world, pos, state);
		return eventResult;
	}

	public static boolean fireSaplingGrowth(Level world, BlockPos pos, BlockState state) {
		eventResult = true;
		for (SaplingGrowth listener : SAPLING_GROWTH) listener.on(world, pos, state);
		return eventResult;
	}

	public static boolean fireDimensionTravel(Entity entity) {
		eventResult = true;
		for (DimensionTravel listener : DIMENSION_TRAVEL) listener.on(entity);
		return eventResult;
	}

	public static boolean fireLeftClickAir(Player player) {
		eventResult = true;
		for (LeftClickAir listener : LEFT_CLICK_AIR) listener.on(player);
		return eventResult;
	}

	public static boolean fireRightClickEmptyHand(Player player) {
		eventResult = true;
		for (RightClickEmptyHand listener : RIGHT_CLICK_EMPTY_HAND) listener.on(player);
		return eventResult;
	}

	public static boolean fireCriticalHit(Player player, Entity target) {
		eventResult = true;
		for (CriticalHit listener : CRITICAL_HIT) listener.on(player, target);
		return eventResult;
	}
	public static void fireItemExpired(net.minecraft.world.entity.item.ItemEntity entity, ItemStack stack) {
		for (ItemExpired listener : ITEM_EXPIRED) listener.on(entity, stack);
	}

	public static void fireInBed(Player player, BlockPos pos) {
		for (InBed listener : IN_BED) listener.on(player, pos);
	}
}
<#-- @formatter:on -->
