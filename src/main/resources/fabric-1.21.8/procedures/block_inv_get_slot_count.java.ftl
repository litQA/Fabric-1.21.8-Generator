<#include "mcelements.ftl">
<@addTemplate file="utils/block_inventory/block_inventory.java.ftl"/>
/*@int*/(getBlockInventorySlotCount(world, ${toBlockPos(input$x, input$y, input$z)}))
