<#include "mcelements.ftl">
<@addTemplate file="utils/block_inventory/block_inventory.java.ftl"/>
extractFromBlockInventory(world, ${toBlockPos(input$x, input$y, input$z)}, ${opt.toInt(input$slotid)}, ${opt.toInt(input$amount)}, false);
