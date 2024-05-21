/**
 * @description       : This class provides methods to query and filter Invoice records.
 * @author            : Kalpesh.chande@skinternational.com
 * @group             : 
 * @last modified on  : 7-02-2024
 * @last modified by  : Kalpesh.chande@skinternational.com
 **/
public without sharing class YINInvoiceSelector extends LIBSObjectSelector{
    /**
     * @description - Get the Schema SObjectType for the YIN_Invoice__c object.
     * @return Schema.SObjectType - The Schema SObjectType for the YIN_Invoice__c object.
     */
    public Schema.SObjectType getSObjectType() {
        return YIN_Invoice__c.SObjectType;
    }
    
    /**
     * @description - Get a list of SObjectFields for the YIN_Invoice__c object.
     * @return  - List<Schema.SObjectField>.
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            YIN_Invoice__c.id,
            YIN_Invoice__c.Invoice_Number__c
        };
    }
    /**
     * @description - Retrieve a list of YIN_Invoice__c records where Invoice_Number__c is not null.
     * @return List<YIN_Invoice__c> - A list of YIN_Invoice__c records.
     */
    public List<YIN_Invoice__c> getInvoiceIds(){
        LIBQueryFactory query = newQueryFactory();
        query.setCondition('Invoice_Number__c!=null');
      //  System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());  
    }

    /*
    * Added By - Nikhil Dhoke ...
    * @Description - This method will return list of invoices based on record type, date range and dealers.
    * @Param Set<Id> - dealerIds,
             String - record type name,
             Date - start and end dates.
    * @return  -    returns list of invoices.
    */
    public List<YIN_Invoice__c> getInvoiceByRecordTypeAndDate(Set<Id> dealerIds, String rcdType, Date yearStart, Date yearEnd){
        return Database.query(
                newQueryFactory()
                        .selectField('Quantity__c')
                        .selectField('Total_Amount__c')
                        .selectField('Document_Date__c')
                        .selectField('RecordType.Name')
                        .selectField('Dealer_Sold_To_Party__c')
                        .selectField('Dealer_Sold_To_Party__r.ERP_Customer_Code__c')
                        .selectField('Dealer_Sold_To_Party__r.Territory__r.Territory_Code__c')
                        .setCondition('Dealer_Sold_To_Party__c IN :dealerIds  AND RecordType.Name =: rcdType AND Document_Date__c >=: yearStart AND Document_Date__c <=: yearEnd ')
                        .toSOQL()
        );
    }
}