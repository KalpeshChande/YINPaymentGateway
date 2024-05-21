/**
 * @description       : 
 * @author            : Kalpesh.Chande@skinternational.com
 * @group             : SKI
 * @last modified on  : 07-02-2024
 * @last modified by  : Kalpesh.Chande@skinternational.com
**/
public Interface YINIExternalApiService {
    List<YIN_Invoice__c> getInvoiceIds();
    List<ResponseWrapperForInvoice> upsertInvoiceAndInvoiceItem(List<YIN_Invoice__c> upsertList,List<YIN_Invoice_Item__c> updateList, List<Order> OrderList);
    List<ResponseWrapperForInvoice> upsertSobjectList(List<Sobject> upsertList,Schema.SObjectField combinationkey);
    String updateSobjectList(List<Sobject> ledgerList);
    List<YIN_Ledger__c> getLedgerForUpdate(List<String> combinationKeyList);
    List<Order> getOrderData(); 
}