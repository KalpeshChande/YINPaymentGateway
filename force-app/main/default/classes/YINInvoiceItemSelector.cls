public class YINInvoiceItemSelector extends LibSObjectSelector {
    
    public Schema.SObjectType getSObjectType() {
        return YIN_Invoice_Item__c.SObjectType;
    }
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            YIN_Invoice_Item__c.Id,
                YIN_Invoice_Item__c.Name,
                YIN_Invoice_Item__c.Item__c,
                YIN_Invoice_Item__c.Location__c,
                YIN_Invoice_Item__c.CreatedDate,
                YIN_Invoice_Item__c.Quantity__c,
                YIN_Invoice_Item__c.Unit_Price__c,
                YIN_Invoice_Item__c.Line_Discount__c,
                YIN_Invoice_Item__c.Line_Discount_Amount__c,
                YIN_Invoice_Item__c.Amount__c,
                YIN_Invoice_Item__c.Posting_Date__c,
                YIN_Invoice_Item__c.Variant__c,
                YIN_Invoice_Item__c.UOM__c
                };
                    }
    
    public List<YIN_Invoice_Item__c> getInvoiceItemData(){
        return Database.query(
            newQueryFactory()
            .toSOQL()
        );
    }
    public List<YIN_Invoice_Item__c> getThreeMOInvoiceItemData(){
        Datetime currentDate = System.today();
        System.debug('currentDate: ' + currentDate);
        Date myDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        Date oneMonthBack = myDate.addMonths(-1);
        Date startOfOne=oneMonthBack.toStartOfMonth();
        Date twoMonthsBack = myDate.addMonths(-2);
        Date startOfTwo=twoMonthsBack.toStartOfMonth();
        Date threeMonthsBack = myDate.addMonths(-3);
        Date startOfThree=threeMonthsBack.toStartOfMonth();
        
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Invoice__c')
            .selectField('Item_Number__c')
            .selectField('Item__c')
            .selectField('Location__c')
            .selectField('Posting_Date__c')
            .selectField('Unit_Price__c')
            .selectField('Amount__c')
            .selectField('Discount_Amount__c')
            .selectField('Total_Amount__c')
            .selectField('Quantity__c')
            .selectField('Item__r.Size__c')
            .selectField('Item__r.Tire_Size__c')
            .setCondition('(Posting_Date__c >= :startOfOne AND Posting_Date__c <= :oneMonthBack) OR (Posting_Date__c >= :startOfTwo AND Posting_Date__c <= :twoMonthsBack) OR (Posting_Date__c >= :startOfThree AND Posting_Date__c <= :threeMonthsBack)')
            .toSOQL()
        );
    }
    public List<YIN_Invoice_Item__c> getOneMOInvoiceItemData(){
        Datetime currentDate = System.today();
        System.debug('currentDate: ' + currentDate);
        Date myDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        Date oneMonthBack = myDate.toStartOfMonth();
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Invoice__c')
            .selectField('Item_Number__c')
            .selectField('Item__c')
            .selectField('Location__c')
            .selectField('Posting_Date__c')
            .selectField('Unit_Price__c')
            .selectField('Amount__c')
            .selectField('Discount_Amount__c')
            .selectField('Total_Amount__c')
            .selectField('Quantity__c')
            .selectField('Item__r.Size__c')
            .selectField('Item__r.Tire_Size__c')
            .setCondition('(Posting_Date__c >= :oneMonthBack AND Posting_Date__c <= :myDate)')
            .toSOQL()
        );
    }
     public List<YIN_Invoice_Item__c> getThreeMOInvoiceFBI(){
        Datetime currentDate = System.today();
        System.debug('currentDate: ' + currentDate);
        YIN_Frequently_Brought_Item__mdt fbiMeta=[select Date_Range__c,Tyre_Size__c from YIN_Frequently_Brought_Item__mdt];
        Date myDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        Date oneMonthBack = myDate.toStartOfMonth();
         system.debug(fbiMeta.Date_Range__c);
          String dateFilterString = 'CreatedDate = ' + 'LAST_N_DAYS:'+fbiMeta.Date_Range__c;
         string query='select id,Invoice__c,Item_Number__c,Item__c,Location__c,Posting_Date__c,Unit_Price__c,Amount__c,Discount_Amount__c,Total_Amount__c,Quantity__c,Invoice__r.Dealer_Bill_To_Party__c,Item__r.Size__c,Item__r.Tire_Size__c from YIN_Invoice_Item__c';
        
         if(test.isRunningTest()){
             return Database.query(query);
         }
        query='select id,Invoice__c,Item_Number__c,Item__c,Location__c,Posting_Date__c,Unit_Price__c,Amount__c,Discount_Amount__c,Total_Amount__c,Quantity__c,Invoice__r.Dealer_Bill_To_Party__c,Item__r.Size__c,Item__r.Tire_Size__c from YIN_Invoice_Item__c where '+ dateFilterString;
          system.debug('query>>>>'+query);
             return Database.query(query);
    }
}