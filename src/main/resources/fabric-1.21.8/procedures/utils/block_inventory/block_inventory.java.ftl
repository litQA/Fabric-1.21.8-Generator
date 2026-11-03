private static Container getBlockContainer(LevelAccessor world, BlockPos pos) {
	if (world instanceof Level level) {
		BlockEntity blockEntity = level.getBlockEntity(pos);
		if (blockEntity instanceof Container container)
			return container;
	}
	return null;
}

private static ItemStack itemFromBlockInventory(LevelAccessor world, BlockPos pos, int slot) {
	Container container = getBlockContainer(world, pos);
	if (container != null && slot >= 0 && slot < container.getContainerSize())
		return container.getItem(slot);
	return ItemStack.EMPTY;
}

private static int getBlockInventorySlotCount(LevelAccessor world, BlockPos pos) {
	Container container = getBlockContainer(world, pos);
	return container != null ? container.getContainerSize() : 0;
}

private static int getBlockInventorySlotStackLimit(LevelAccessor world, BlockPos pos, int slot) {
	Container container = getBlockContainer(world, pos);
	if (container != null && slot >= 0 && slot < container.getContainerSize())
		return container.getMaxStackSize(container.getItem(slot));
	return 0;
}

private static boolean canInsertInBlockInventory(LevelAccessor world, BlockPos pos, int slot, int amount, ItemStack stack) {
	Container container = getBlockContainer(world, pos);
	if (container == null || slot < 0 || slot >= container.getContainerSize() || !container.canPlaceItem(slot, stack))
		return false;
	ItemStack existing = container.getItem(slot);
	if (existing.isEmpty())
		return amount <= Math.min(container.getMaxStackSize(stack), stack.getMaxStackSize());
	if (!ItemStack.isSameItemSameComponents(existing, stack))
		return false;
	return existing.getCount() + amount <= Math.min(container.getMaxStackSize(existing), existing.getMaxStackSize());
}

private static int insertInBlockInventory(LevelAccessor world, BlockPos pos, int slot, int amount, ItemStack stack, boolean simulate) {
	Container container = getBlockContainer(world, pos);
	if (container == null || slot < 0 || slot >= container.getContainerSize() || amount <= 0)
		return Math.max(amount, 0);
	ItemStack existing = container.getItem(slot);
	int maxStack = container.getMaxStackSize(stack);
	if (existing.isEmpty()) {
		if (!container.canPlaceItem(slot, stack))
			return amount;
		int inserted = Math.min(amount, Math.min(maxStack, stack.getMaxStackSize()));
		if (!simulate) {
			ItemStack result = stack.copy();
			result.setCount(inserted);
			container.setItem(slot, result);
		}
		return amount - inserted;
	}
	if (!ItemStack.isSameItemSameComponents(existing, stack))
		return amount;
	int inserted = Math.min(amount, Math.min(container.getMaxStackSize(existing), existing.getMaxStackSize()) - existing.getCount());
	if (inserted <= 0)
		return amount;
	if (!simulate)
		existing.grow(inserted);
	return amount - inserted;
}

private static ItemStack extractFromBlockInventory(LevelAccessor world, BlockPos pos, int slot, int amount, boolean simulate) {
	Container container = getBlockContainer(world, pos);
	if (container == null || slot < 0 || slot >= container.getContainerSize() || amount <= 0)
		return ItemStack.EMPTY;
	ItemStack existing = container.getItem(slot);
	if (existing.isEmpty())
		return ItemStack.EMPTY;
	int extracted = Math.min(amount, existing.getCount());
	ItemStack result = existing.copy();
	result.setCount(extracted);
	if (!simulate)
		container.removeItem(slot, extracted);
	return result;
}
