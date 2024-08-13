trigger OrderItemTrigger on OrderItem__c (after insert, after update, after delete, after undelete) {
    Map<Id, OrderItem__c> newOrderItemsMap = Trigger.newMap;
    Map<Id, OrderItem__c> oldOrderItemsMap = Trigger.oldMap;
    Set<Id> orderIds = new Set<Id>();

    if (newOrderItemsMap != null) {
        for (OrderItem__c item : newOrderItemsMap.values()) {
            orderIds.add(item.OrderId__c);
        }
    }

    if (oldOrderItemsMap != null) {
        for (OrderItem__c item : oldOrderItemsMap.values()) {
            orderIds.add(item.OrderId__c);
        }
    }

    List<Order__c> ordersToUpdate = [SELECT Id, TotalProductCount__c, TotalPrice__c FROM Order__c WHERE Id IN :orderIds];
        
    Map<Id, Decimal> orderTotalPriceMap = new Map<Id, Decimal>();
    Map<Id, Integer> orderTotalProductCountMap = new Map<Id, Integer>();

    
    for (OrderItem__c item : [SELECT OrderId__c, Quantity__c, Price__c FROM OrderItem__c WHERE OrderId__c IN :orderIds]) {
        if (!orderTotalPriceMap.containsKey(item.OrderId__c)) {
            orderTotalPriceMap.put(item.OrderId__c, 0);
            orderTotalProductCountMap.put(item.OrderId__c, 0);
        }
        orderTotalPriceMap.put(item.OrderId__c, orderTotalPriceMap.get(item.OrderId__c) + item.Price__c);
        orderTotalProductCountMap.put(item.OrderId__c, orderTotalProductCountMap.get(item.OrderId__c) + item.Quantity__c.intValue());
    }

    for (Order__c order : ordersToUpdate) {
        order.TotalPrice__c = orderTotalPriceMap.containsKey(order.Id) ? orderTotalPriceMap.get(order.Id) : 0;
        order.TotalProductCount__c = orderTotalProductCountMap.containsKey(order.Id) ? orderTotalProductCountMap.get(order.Id) : 0;
    }

    update ordersToUpdate;
}