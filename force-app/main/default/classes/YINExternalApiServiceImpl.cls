/**
* @description       : Implementation class for interacting with external APIs related to Invoice and Invoice Item operations.
* @author            : Kalpesh.Chande@skinternational.com
* @group             : SKI
* @last modified on  : 07-02-2024
* @last modified by  : Kalpesh.Chande@skinternational.com
**/
public virtual with sharing class YINExternalApiServiceImpl implements YINIExternalApiService{
    /**
* @description       : Retrieve a list of Invoice records.
* @return            : List<YIN_Invoice__c> - A list of YIN_Invoice__c records.
*/
    public virtual List<YIN_Invoice__c> getInvoiceIds(){
        LibISObjectSelector selector =  YINApplication.selector.newInstance(YIN_Invoice__c.SObjectType);
        YINInvoiceSelector invObj = (YINInvoiceSelector)selector;
        return invObj.getInvoiceIds();
    } 
    /**
* @description       : Upsert Invoice and Invoice Item records.
* @param upsertList  : List of YIN_Invoice__c records to upsert.
* @param insertList  : List of YIN_Invoice_Item__c records to insert.
* @param orderList  :List of Order records to insert.
* @return            : String - A message indicating the success or failure of the upsert operation.
*/
    public virtual List<ResponseWrapperForInvoice> upsertInvoiceAndInvoiceItem(List<YIN_Invoice__c> upsertList,List<YIN_Invoice_Item__c> insertList, List<Order> orderList){
        String resultList = '';
        List<ResponseWrapperForInvoice> responseList=new List<ResponseWrapperForInvoice>();
        try{
            LibISObjectUnitOfWork unitOfWork = YINApplication.unitOfWork.newInstance();
            if(upsertList.size()>0){
                unitOfWork.registerUpsert(upsertList);
            }
            if(insertList.size()>0){
                unitOfWork.registerNew(insertList);
            }
            if(OrderList.size()>0){
                unitOfWork.registerDirty(OrderList);
            }
            unitOfWork.commitWork();
           for (Integer i = 0; i < upsertList.size(); i++) {
               ResponseWrapperForInvoice resWrap=new ResponseWrapperForInvoice();
                    resWrap.status='Success';
                    resWrap.id= upsertList[i].Id;
                    resWrap.success= true;
                    resWrap.created= false;
                    resWrap.responseCode='200';
                    resWrap.message='success';
                    responseList.add(resWrap);
            }
            return responseList;
        }catch (Exception e) {
            //return resultList;
            ResponseWrapperForInvoice resWrap=new ResponseWrapperForInvoice();
            resWrap.status='Failed';
            resWrap.id= null;
            resWrap.success= false;
            resWrap.created= false;
            resWrap.responseCode='400';
            resWrap.message=e.getMessage();
            resWrap.cause=e.getCause();
            responseList.add(resWrap);
            return responseList;
        }
    }
    /**
     * @description Upsert a list of SObjects using an external ID field.
     * @param upsertList List of SObjects to upsert.
     * @param combinationkey Schema.SObjectField representing the external ID field.
     * @return List<ResponseWrapperForInvoice> A list of response wrappers indicating the success or failure of the upsert operation.
     */
    public virtual List<ResponseWrapperForInvoice> upsertSobjectList(List<Sobject> upsertList,Schema.SObjectField combinationkey){
        String resultList='';
        List<ResponseWrapperForInvoice> responseList=new List<ResponseWrapperForInvoice>();
        List<Map<String, Object>> responseData = new List<Map<String, Object>>();
        try{
            LibISObjectUnitOfWork unitOfWork = YINApplication.unitOfWork.newInstance();
            if(upsertList.size()>0){
                unitOfWork.upsertWithExternalId(upsertList,combinationkey);
            }
            unitOfWork.commitWork();
            for (Integer i = 0; i < upsertList.size(); i++) {
                ResponseWrapperForInvoice resWrap=new ResponseWrapperForInvoice();
                    resWrap.status='Success';
                    resWrap.id= upsertList[i].Id;
                    resWrap.success= true;
                    resWrap.created= false;
                    resWrap.responseCode='200';
                    resWrap.message='success';
                    responseList.add(resWrap);
            }
            return responseList;
        }catch (Exception e) {
            ResponseWrapperForInvoice resWrap=new ResponseWrapperForInvoice();
            resWrap.status='Failed';
            resWrap.id= null;
            resWrap.success= false;
            resWrap.created= false;
            resWrap.responseCode='400';
            resWrap.message=e.getMessage();
            resWrap.cause=e.getCause();
            responseList.add(resWrap);
            return responseList;
        }
    }
    /**
     * @description Update a list of SObjects.
     * @param sObjectList List of SObjects to update.
     * @return String Indicates the success or failure of the update operation.
     */
    public virtual String updateSobjectList(List<sObject> sObjectList){
       String str='';
        try{
            LibISObjectUnitOfWork unitOfWork = YINApplication.unitOfWork.newInstance();
            if(sObjectList.size()>0){
                unitOfWork.registerDirty(sObjectList);
            }
            unitOfWork.commitWork();
            str='success';
        }catch (Exception e) {
            return str='error';
            // System.debug(' Exception is - '+ e.getMessage());
            // System.debug(' Exception at - '+ e.getLineNumber());
        }
        return str;
    }
    /**
     * @description Retrieve a list of Ledger records for update.
     * @return List<YIN_Ledger__c> A list of YIN_Ledger__c records.
     */
    public virtual List<YIN_Ledger__c> getLedgerForUpdate(List<String> combinationKeyList){
        LibISObjectSelector selector =  YINApplication.selector.newInstance(YIN_Ledger__c.SObjectType);
        YINLedgerSelector ledgerObj = (YINLedgerSelector)selector;
        return ledgerObj.getLedgerIds(combinationKeyList);
    }
     /**
     * @description Retrieve a list of Order records for update.
     * @return List<Order> A list of Order records.
     */
    public virtual List<Order> getOrderData(){
        LibISObjectSelector selector =  YINApplication.selector.newInstance(Order.SObjectType);
        YINOrderSelector orderObj = (YINOrderSelector)selector;
        return orderObj.getOrderDataForUpdate();
    }
}