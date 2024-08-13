public class OrderManagementPageResult {
    @AuraEnabled
    public Object[] products { get; set; }

    @AuraEnabled
    public Integer totalItemCount { get; set; }
}