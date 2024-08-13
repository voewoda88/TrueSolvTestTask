@isTest
public class OrderManagementPageControllerTests {
    
    @TestSetup
    static void setup() {
        List<Product__c> testProducts = new List<Product__c>();
        
        for (Integer i = 1; i <= 20; i++) {
            Product__c product = new Product__c();
            product.Name = 'Test Product ' + 1;
            product.Description__c = 'Description for product ' + i;
            product.Price__c = 100 + 1;
            product.Image__c = 'https://example.com/product' + i + '.jpg';
            product.Type__c = Math.Mod(i, 2) == 0 ? 'Gasoline' : 'Diesel';
            product.Family__c = Math.Mod(i, 3) == 0 ? 'Coupe' : 'Sedan';
            testProducts.add(product);
        }
        
        insert testProducts;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }
    
	@isTest
    static void testGetProductTypePicklistValues() {
        List<String> picklistValues = orderManagementPageController.getProductTypePicklistValues();

        System.assertNotEquals(0, picklistValues.size(), 'Picklist values should not be empty.');
    }
    
    @isTest
    static void testGetProductFamilyPicklistValues() {
        List<String> picklistValues = orderManagementPageController.getProductFamilyPicklistValues();

        System.assertNotEquals(0, picklistValues.size(), 'Picklist values should not be empty.');
    }
    
    @IsTest
    static void testGetProductsWithSearchKey() {
        String searchKey = 'Test';
        String type = '';
        String family = '';
        Integer pageNumber = 1;

        OrderManagementPageResult result = OrderManagementPageController.getProducts(searchKey, type, family, pageNumber);

        System.assertEquals(8, result.products.size(), 'Expected 8 products on the first page.');
        System.assert(result.totalItemCount > 8, 'Expected total item count to be more than 8.');
    }

    @IsTest
    static void testGetProductsWithTypeAndFamily() {
        String searchKey = '';
        String type = 'TypeA';
        String family = 'FamilyY';
        Integer pageNumber = 1;

        OrderManagementPageResult result = OrderManagementPageController.getProducts(searchKey, type, family, pageNumber);

        for (Object tmp : result.products) {
            Product__c product = (Product__c)tmp;
            System.assertEquals('TypeA', product.Type__c, 'Expected Type__c to be TypeA');
            System.assertEquals('FamilyY', product.Family__c, 'Expected Family__c to be FamilyY');
        }
    }

    @IsTest
    static void testGetProductsPagination() {
        String searchKey = '';
        String type = '';
        String family = '';
        Integer pageNumber = 2;

        OrderManagementPageResult result = OrderManagementPageController.getProducts(searchKey, type, family, pageNumber);

        System.assertEquals(8, result.products.size(), 'Expected 8 products on the second page.');
    }

    @IsTest
    static void testGetProductsEmptySearch() {
        String searchKey = 'NonExistentProduct';
        String type = '';
        String family = '';
        Integer pageNumber = 1;

        OrderManagementPageResult result = OrderManagementPageController.getProducts(searchKey, type, family, pageNumber);

        System.assertEquals(0, result.products.size(), 'Expected 0 products for non-existent search key.');
        System.assertEquals(0, result.totalItemCount, 'Expected total item count to be 0 for non-existent search key.');
    }
    
    @IsTest
    static void testSaveProducts() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        List<Product__c> productIds = [SELECT Id FROM Product__c];

        List<ProductToSave> productToSaveList = new List<ProductToSave>();
        for (Integer i = 0; i < 3; i++) {
            ProductToSave pts = new ProductToSave();
            pts.Id = productIds[i].Id;
            pts.Quantity = i + 1;
            pts.Price = 100 * (i + 1);
            productToSaveList.add(pts);
        }

        Id newOrderId = orderManagementPageController.saveProducts(productToSaveList, testAccount.Id);

        Order__c newOrder = [SELECT Id, Name FROM Order__c WHERE Id = :newOrderId];
        System.assertNotEquals(null, newOrder, 'Order was not created');
        System.assertEquals('Order 1', newOrder.Name, 'Order name is incorrect');

        List<OrderItem__c> orderItems = [SELECT Product__c, Quantity__c, Price__c FROM OrderItem__c WHERE OrderId__c = :newOrderId];
        System.assertEquals(3, orderItems.size(), 'Order items count is incorrect');

        for (Integer i = 0; i < orderItems.size(); i++) {
            OrderItem__c item = orderItems[i];
            System.assertEquals(productIds[i].Id, item.Product__c, 'Order item product ID is incorrect');
            System.assertEquals(i + 1, item.Quantity__c, 'Order item quantity is incorrect');
            System.assertEquals((100 * (i + 1)) * (i + 1), item.Price__c, 'Order item price is incorrect');
        }
    }
}