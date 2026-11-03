<#include "mcitems.ftl">
<@addTemplate file="utils/entity/entity_slot.java.ftl"/>
setEntitySlot(${input$entity}, ${opt.toInt(input$slotid)}, ${mappedMCItemToItemStackCode(input$slotitem, 1)}, ${opt.toInt(input$amount)});
