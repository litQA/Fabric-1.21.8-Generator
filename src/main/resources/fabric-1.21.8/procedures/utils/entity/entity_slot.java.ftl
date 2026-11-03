private static ItemStack getEntitySlot(Entity entity, int slot) {
	if (entity instanceof Player player)
		return slot >= 0 && slot < player.getInventory().getContainerSize() ? player.getInventory().getItem(slot).copy() : ItemStack.EMPTY;
	if (entity instanceof Container container)
		return slot >= 0 && slot < container.getContainerSize() ? container.getItem(slot).copy() : ItemStack.EMPTY;
	return ItemStack.EMPTY;
}

private static void setEntitySlot(Entity entity, int slot, ItemStack stack, int amount) {
	if (entity instanceof Player player) {
		if (slot >= 0 && slot < player.getInventory().getContainerSize()) {
			ItemStack copy = stack.copy();
			copy.setCount(amount);
			player.getInventory().setItem(slot, copy);
		}
		return;
	}
	if (entity instanceof Container container && slot >= 0 && slot < container.getContainerSize()) {
		ItemStack copy = stack.copy();
		copy.setCount(amount);
		container.setItem(slot, copy);
	}
}
