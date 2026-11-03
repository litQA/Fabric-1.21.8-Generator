<@addTemplate file="utils/entity/entity_slot.java.ftl"/>
if (${input$entity} instanceof Player _playerIter) {
	for (int _idx = 0; _idx < _playerIter.getInventory().getContainerSize(); _idx++) {
		ItemStack itemstackiterator = _playerIter.getInventory().getItem(_idx);
		${statement$foreach}
	}
} else if (${input$entity} instanceof Container _containerIter) {
	for (int _idx = 0; _idx < _containerIter.getContainerSize(); _idx++) {
		ItemStack itemstackiterator = _containerIter.getItem(_idx);
		${statement$foreach}
	}
}
