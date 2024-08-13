public with sharing class orderManagementPageController {
    @AuraEnabled(cacheable=true)
    public static List<String> getProductTypePicklistValues() {
        List<String> picklistValues = new List<String>();

        Schema.SObjectType productType = Product__c.SObjectType;
        Schema.DescribeSObjectResult productDescribe = productType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = productDescribe.fields.getMap().get('Type__c').getDescribe();

        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }

        return picklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getProductFamilyPicklistValues() {
        List<String> picklistValues = new List<String>();

        Schema.SObjectType productType = Product__c.SObjectType;
        Schema.DescribeSObjectResult productDescribe = productType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = productDescribe.fields.getMap().get('Family__c').getDescribe();

        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }

        return picklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static OrderManagementPageResult getProducts(String searchKey, String type, String family, Integer pageNumber) {
        String searchPattern = '%' + searchKey + '%';
        Integer safePageSize = 8;
        Integer offset = (pageNumber - 1) * safePageSize;

        String soqlCountQuery = 'SELECT COUNT() FROM Product__c WHERE Name LIKE :searchPattern';
        String soqlQuery = 'SELECT Id, Name, Description__c, Price__c, Image__c, Type__c, Family__c FROM Product__c WHERE Name LIKE :searchPattern';

        if(!String.isEmpty(type) && !String.isEmpty(family)) {
            soqlQuery += ' AND Type__c = :type AND Family__c = :family';
            soqlCountQuery += ' AND Type__c = :type AND Family__c = :family';
        } else if(!String.isEmpty(type)) {
            soqlQuery +=  ' AND Type__c = :type';
            soqlCountQuery += ' AND Type__c = :type';
        } else if(!String.isEmpty(family)) {
            soqlQuery += ' AND Family__c = :family';
            soqlCountQuery += ' AND Family__c = :family';
        }

        soqlQuery += ' LIMIT :safePageSize OFFSET :offset';

        System.debug(soqlQuery);

        OrderManagementPageResult result = new OrderManagementPageResult();

        result.products = Database.query(soqlQuery);
        result.totalItemCount = Database.countQuery(soqlCountQuery);

        return result;
    }

    @AuraEnabled
    public static Id saveProducts(List<ProductToSave> products, Id accountId) {
        List<Order__c> orders = [SELECT Name FROM Order__c WHERE AccountId__c = :accountId];
        Integer orderNumber = 1;
        if(orders.size() != 0) {
            orderNumber = orders.size() + 1;
        }
        
        String orderName = 'Order ' + orderNumber;
        
        Order__c newOrder = new Order__c(
            Name = orderName,
        	AccountId__c = accountId
        );
        
        insert newOrder;
        
        Id newOrderId = [SELECT Id FROM Order__c WHERE Name = :orderName LIMIT 1].Id;
        
        List<OrderItem__c> orderItems = new List<OrderItem__c>();
		        
        for(ProductToSave product : products){
            OrderItem__c newItem = new OrderItem__c(
            	OrderId__c = newOrderId,
                Product__c = product.Id,
                Quantity__c = product.Quantity,
                Price__c = product.Price * product.Quantity
            );
            
            orderItems.add(newItem);
        }
        
        insert orderItems;

        return newOrderId;
    }
}