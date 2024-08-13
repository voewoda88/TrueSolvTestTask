public class ProductToSave {
    @AuraEnabled
    public Id Id { get; set; }

    @AuraEnabled
    public String Name { get; set; }

    @AuraEnabled
    public Integer Quantity { get; set; }

    @AuraEnabled
    public Double Price { get; set; }
}