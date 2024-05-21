@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.NcssMethodCount,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount,PMD.TooManyFields')
/**
* @description       : This global Apex class provides RESTful API endpoints for handling operations related to invoices and invoice items.                                          
* @author            : kalpesh.chande@skinternational.com
* @last modified on  : 6-02-2024
* @last modified by  : kalpesh.chande@skinternational.com
**/
@RestResource(urlMapping='/InvoiceAndInvoiceItemApi/*')
global with sharing class YINInvoiceAndInvoiceItemService {
    /**
* @description    :Processes a POST request to create or update invoice records along with their associated invoice items.
* @param requestBody An array of InvoiceAndInvoiceItemWrapper objects representing the request body.
* @return A JSON response containing the status of the request.
*/
    @HttpPost 
    global static List<ResponseWrapperForInvoice> sendPostRequest(InvoiceAndInvoiceItemWrapper[] requestBody) {
        // System.debug('requestBody: ' + requestBody);
        YINMonitorService monitor=new  YINMonitorService();
        List<ResponseWrapperForInvoice> responseList=new List<ResponseWrapperForInvoice>();
        String  userId=userInfo.getUserId();   
        String response='';
        List<Order> orderList=new List<Order>();
        List<YIN_Invoice__c> plListToUpsert=new List<YIN_Invoice__c>();
        List<YIN_Invoice__c> invoiceListToUpdate=new List<YIN_Invoice__c>();
        List<Map<String, Object>> responseData = new List<Map<String, Object>>(); 
        Map<String,YIN_Invoice__c> invoiceMap=new Map<String,YIN_Invoice__c>();
        List<YIN_Invoice_Item__c> iItemList=new List<YIN_Invoice_Item__c>();
        YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
        try{
            LibISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
            YINExternalApiServiceImpl impl = (YINExternalApiServiceImpl)YINApplication.service.newInstance(YINIExternalApiService.class);
            String serilizeJson=JSON.serialize(requestBody);
            //System.debug('SerilizeJson: ' + serilizeJson);
            List<InvoiceAndInvoiceItemWrapper> invoiceAndILineWrapList = (List<InvoiceAndInvoiceItemWrapper>)JSON.deserialize(serilizeJson, List<InvoiceAndInvoiceItemWrapper>.class);
            // System.debug('Parsed JSON: ' + requestBody.size());
            Map<String,Order> orderMap=new Map<String,Order>();
            List<Order> orderListForUpdate=impl.getOrderData();
            for(Order ordObj:orderListForUpdate){
                orderMap.put(ordObj.ERP_Order_Number__c,ordObj);
            }
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            // system.debug('req'+req);
            String requestUrl; 
            if(test.isRunningTest()==true){
                requestUrl = 'test.com';
            }else{
                requestUrl = req.requestURI;
            }
            boolean isInsert=false;
            String invoiceId='';
            String result='';
            boolean isInvoice=false;
            List<YIN_Invoice__c> invoiceIdToUpdate=impl.getInvoiceIds();
            for(YIN_Invoice__c invId:invoiceIdToUpdate){
                invoiceMap.put(invId.Invoice_Number__c,invId);
            }
            List<InvoiceItemWrapper> iItemListForInsert=new List<InvoiceItemWrapper>();
            for (InvoiceAndInvoiceItemWrapper invoiceWrapper : invoiceAndILineWrapList) {
                YIN_Invoice__c invoiceRecord = new YIN_Invoice__c();
                if(invoiceWrapper.documentType.toLowerCase()=='invoice'){
                    isInvoice=true;
                }
                
                invoiceRecord.Document_Type__c=invoiceWrapper.documentType;
                invoiceRecord.Name = invoiceWrapper.invoiceName;
                invoiceRecord.Invoice_Number__c = invoiceWrapper.invoiceName;
                invoiceRecord.Invoice_Status__c=invoiceWrapper.invoiceStatus;
                invoiceRecord.RecordTypeId =getRecordTypeIdbyName('YIN_Invoice__c',invoiceWrapper.documentType);
                if(invoiceWrapper.status!='true'){ 
                    if(isInvoice){
                        invoiceRecord.Order_Date__c = Date.valueOf(invoiceWrapper.orderDate);
                    }else if(!isInvoice && invoiceWrapper.orderDate !='' && invoiceWrapper.orderDate !=null){
                        invoiceRecord.Order_Date__c = invoiceWrapper.orderDate==null?null:Date.valueOf(invoiceWrapper.orderDate); 
                    }
                    invoiceRecord.Posting_Date__c = invoiceWrapper.postingDate==null?null:Date.valueOf(invoiceWrapper.postingDate);
                    if(invoiceWrapper.shipmentDate!='' && invoiceWrapper.shipmentDate != null){
                    invoiceRecord.Shipment_Date__c = Date.valueOf(invoiceWrapper.shipmentDate);
                    }else if(isInvoice){
                    invoiceRecord.Shipment_Date__c = invoiceWrapper.shipmentDate==null?null:Date.valueOf(invoiceWrapper.shipmentDate);
                    }
                    if(invoiceWrapper.soldToParty!='' && invoiceWrapper.soldToParty!=null){
                        Account accObj=new Account(ERP_Customer_Code__c=invoiceWrapper.soldToParty);
                        invoiceRecord.Dealer_Sold_To_Party__r=accObj;
                    }
                    if(invoiceWrapper.soldToParty!='' && invoiceWrapper.soldToParty!=null){
                        Account accObj=new Account(ERP_Customer_Code__c=invoiceWrapper.billToParty);
                        invoiceRecord.Dealer_Bill_To_Party__r=accObj;
                    }
                    if(invoiceWrapper.shipToParty!='' && invoiceWrapper.shipToParty!=null){
                        Account accObj=new Account(ERP_Customer_Code__c=invoiceWrapper.shipToParty);
                        invoiceRecord.Dealer_Ship_To_Party__r=accObj;
                    }
                    invoiceRecord.Payment_Term_Code__c = invoiceWrapper.paymentTermCode;
                    invoiceRecord.Due_Date__c = invoiceWrapper.dueDate==null?null:Date.valueOf(invoiceWrapper.dueDate);
                    invoiceRecord.Shipment_Method_Code__c = invoiceWrapper.shipmentMethodCode;
                    if (invoiceWrapper.location != null && invoiceWrapper.location != '') {
                        YIN_Location__c locObj=new YIN_Location__c(Location_Code__c=invoiceWrapper.location);
                        invoiceRecord.Locations__r = locObj;
                    }
                    if (invoiceWrapper.customerPriceGroup != null && invoiceWrapper.customerPriceGroup!=''){
                        YIN_Customer_Group__c cusrGrpObj=new YIN_Customer_Group__c(Group_Code__c=invoiceWrapper.customerPriceGroup);
                        invoiceRecord.Customer_Price_Group__r =cusrGrpObj;
                    } 
                    if (invoiceWrapper.customerDiscountPriceGroup != null && invoiceWrapper.customerDiscountPriceGroup!=''){
                        YIN_Customer_Group__c cusrGrpObj=new YIN_Customer_Group__c(Group_Code__c=invoiceWrapper.customerDiscountPriceGroup);
                        invoiceRecord.Customer_Discount_Price_Group__r =cusrGrpObj;
                    }
                    if(invoiceWrapper.sfdcOrderNumber!=null && invoiceWrapper.sfdcOrderNumber!=''){
                        if(invoiceWrapper.orderNumber!=null && invoiceWrapper.orderNumber!=''){
                            Order orderObj=new Order(ERP_Order_Number__c=invoiceWrapper.orderNumber);
                            invoiceRecord.Order_Number__r = orderObj;
                            if(orderMap.containsKey(invoiceWrapper.orderNumber)){
                                Order odObj=orderMap.get(invoiceWrapper.orderNumber);
                                odObj.ERP_Order_Number__c=invoiceWrapper.orderNumber;
                                odObj.Status='Invoiced';
                                OrderList.add(odObj);
                            }
                        }
                    }
                    if(isInvoice){
                        invoiceRecord.Amount__c = invoiceWrapper.amount;
                    }else if(!isInvoice && invoiceWrapper.amount !=null){
                        invoiceRecord.Amount__c = invoiceWrapper.amount;
                    }
                    invoiceRecord.Transport_Method__c = invoiceWrapper.transportMethod;
                    if(invoiceWrapper.documentDate !=null && invoiceWrapper.documentDate !=''){
                        invoiceRecord.Document_Date__c = Date.valueOf(invoiceWrapper.documentDate);
                    }
                    invoiceRecord.External_Document_Number__c = invoiceWrapper.externalDocumentNumber;
                    invoiceRecord.Payment_Method_Code__c = invoiceWrapper.paymentMethodCode;
                    invoiceRecord.Pre_Assigned_Number__c = invoiceWrapper.preAssignedNumber;
                    invoiceRecord.USER_ID__c = invoiceWrapper.userId;
                    invoiceRecord.Canceled_By__c = invoiceWrapper.canceledBy;
                    invoiceRecord.Customer_Ledger_Entry_Number__c = invoiceWrapper.customerLedgerEntryNumber;
                    invoiceRecord.Discount_Amount__c = invoiceWrapper.discountAmount;
                    if(isInvoice){
                        invoiceRecord.Total_Amount__c = invoiceWrapper.totalAmount;
                    }else if(!isInvoice && invoiceWrapper.totalAmount !=null){
                        invoiceRecord.Total_Amount__c = invoiceWrapper.totalAmount;
                    }
                    invoiceRecord.LRRR_Number__c = invoiceWrapper.lrrrNumber;
                    if(invoiceWrapper.lrrrDate != null && invoiceWrapper.lrrrDate !=''){
                        invoiceRecord.LRRR_Date__c = Date.valueOf(invoiceWrapper.lrrrDate);
                    }
                    invoiceRecord.Vehicle_Number__c = invoiceWrapper.vehicleNumber;
                    invoiceRecord.Mode_Of_Transport__c = invoiceWrapper.modeOfTransport;
                    invoiceRecord.GST_Bill_To_State_Code__c = invoiceWrapper.gstBillToStateCode;
                    invoiceRecord.GST_Ship_To_State_Code__c = invoiceWrapper.gstShipToStateCode;
                    invoiceRecord.Location_State_Code__c = invoiceWrapper.locationStateCode;
                    invoiceRecord.Location_GST_Reg_No__c = invoiceWrapper.locationGstRegNo;
                    invoiceRecord.Customer_GST_Reg_No__c = invoiceWrapper.customerGstRegNo;
                    invoiceRecord.Ship_To_GST_Reg_No__c = invoiceWrapper.shipToGstRegNo;
                    invoiceRecord.Distance_KM__c = invoiceWrapper.distanceKm;
                    invoiceRecord.Reference_Invoice_Number__c = invoiceWrapper.referenceInvoiceNumber;
                    invoiceRecord.Eway_Bill_No__c = invoiceWrapper.ewayBillNo;
                    invoiceRecord.IRN_Hash__c = invoiceWrapper.irnHash;
                    invoiceRecord.Discount_Remarks__c = invoiceWrapper.discountRemarks;
                    invoiceRecord.Remarks__c = invoiceWrapper.remarks;
                    invoiceRecord.Transporter_Code__c = invoiceWrapper.transporterCode;
                    invoiceRecord.Picking_Number__c = invoiceWrapper.pickingNumber;
                    invoiceRecord.E_Invoice_Created__c = invoiceWrapper.eInvoiceCreated==null?false:invoiceWrapper.eInvoiceCreated;
                    invoiceRecord.Cancel_Reference_Id__c = invoiceWrapper.canceledReferenceId;
                    if(invoiceWrapper.cancellingIrnDate !=null && invoiceWrapper.cancellingIrnDate !=''){

                        invoiceRecord.Cancelling_IRN_Date__c = getDateTimeByString(invoiceWrapper.cancellingIrnDate);
                    }
                    invoiceRecord.Cancelling_IRN__c = invoiceWrapper.cancellingIrn==null?false:invoiceWrapper.cancellingIrn;
                    invoiceRecord.Cancel_Remarks__c = invoiceWrapper.cancelRemarks;
                    invoiceRecord.Cancelled_E_Way_Bill_No__c = invoiceWrapper.cancelledEWayBillNo;
                    invoiceRecord.Route_No__c = invoiceWrapper.routeNo;
                    invoiceRecord.Update_Remarks__c = invoiceWrapper.updateRemarks;
                    if(invoiceWrapper.cancelInvoice!=null){
                    invoiceRecord.Cancel_invoice__c = invoiceWrapper.cancelInvoice;
                    }
                    invoiceRecord.Route_Code__c = invoiceWrapper.routeCode;
                    invoiceRecord.Type__c = invoiceWrapper.invoiceType;
                    if(invoiceWrapper.supplyFinishedDate!=null && invoiceWrapper.supplyFinishedDate !=''){
                        invoiceRecord.Supply_Finished_Date__c = Date.valueOf(invoiceWrapper.supplyFinishedDate);
                    }
                    invoiceRecord.Order_Type__c = invoiceWrapper.orderType;
                    if(isInvoice && invoiceWrapper.ledgerType!='' && invoiceWrapper.ledgerType !=null){
                        invoiceRecord.Ledger_Type__c = invoiceWrapper.ledgerType;
                    }
                    if(!isInvoice){
                        invoiceRecord.Ledger_Type__c = invoiceWrapper.ledgerType;
                    }
                    invoiceRecord.Sales_Return_Type__c=invoiceWrapper.salesReturnType;
                    iItemListForInsert = invoiceWrapper.invoiceItemList;
                    // uow.registerNew(invoiceRecord);
                }
                if(invoiceWrapper.operation.toLowerCase()=='insert'){
                    plListToUpsert.add(invoiceRecord);
                    isInsert=true;
                }else if(invoiceWrapper.operation.toLowerCase()=='update'){
                    if(invoiceMap.containsKey(invoiceWrapper.invoiceName)){
                        YIN_Invoice__c invId=invoiceMap.get(invoiceWrapper.invoiceName);
                        invoiceRecord.Id=invId.Id;
                    }
                    plListToUpsert.add(invoiceRecord);
                    isInsert=false;
                }
                // uow.registerNew(plListToUpsert);
                
                if(isInsert==true){
                    for(InvoiceItemWrapper invoiceItemWrapper : iItemListForInsert){      
                        YIN_Invoice_Item__c invoiceItemRecord = new YIN_Invoice_Item__c();
                        if(isInvoice){
                            invoiceItemRecord.Name = invoiceItemWrapper.name;
                        }else if(!isInvoice && invoiceItemWrapper.name !='' && invoiceItemWrapper.name != null){
                            invoiceItemRecord.Name = invoiceItemWrapper.name;
                        }
                        if(invoiceWrapper.invoiceName !='' && invoiceWrapper.invoiceName!=null){
                            YIN_Invoice__c invObj=new YIN_Invoice__c(Invoice_Number__c=invoiceWrapper.invoiceName);
                            invoiceItemRecord.Invoice__r = invObj;
                        }
                        
                        invoiceItemRecord.Item_Number__c = invoiceItemWrapper.itemNumber;
                        system.debug('invoiceItemWrapper.type>>>>'+invoiceItemWrapper.type);
                        system.debug('invoiceItemWrapper.item>>>>'+invoiceItemWrapper.item);
                        if(invoiceItemWrapper.type.toLowerCase()=='item'){
                            Product2 prObj=new Product2(Product_Code__c=invoiceItemWrapper.item);
                            invoiceItemRecord.Item__r =prObj;
                        }
                        
                        if(isInvoice){
                            YIN_Location__c locObj=new YIN_Location__c(Location_Code__c=invoiceItemWrapper.location);
                            invoiceItemRecord.Location__r = locObj; 
                        }
                        else if(!isInvoice && invoiceItemWrapper.location != null && invoiceItemWrapper.location != '') {
                            YIN_Location__c locObj=new YIN_Location__c(Location_Code__c=invoiceItemWrapper.location);
                            invoiceItemRecord.Location__r = locObj;
                        }
                        invoiceItemRecord.Quantity__c = invoiceItemWrapper.quantity;
                        invoiceItemRecord.Unit_Price__c = invoiceItemWrapper.unitPrice;
                        invoiceItemRecord.Line_Discount__c = invoiceItemWrapper.lineDiscount;
                        invoiceItemRecord.Line_Discount_Amount__c = invoiceItemWrapper.lineDiscountAmount;
                        invoiceItemRecord.Line_Amount__c = invoiceItemWrapper.lineAmount;
                        if(isInvoice){
                            invoiceItemRecord.Posting_Date__c = Date.valueOf(invoiceItemWrapper.postingDate);
                        }else if(!isInvoice && invoiceItemWrapper.postingDate!='' && invoiceItemWrapper.postingDate !=null){
                            invoiceItemRecord.Posting_Date__c = Date.valueOf(invoiceItemWrapper.postingDate); 
                        }
                        if(invoiceItemWrapper.variant !='' && invoiceItemWrapper.variant !=null){
                            YIN_variant__c varObj=new YIN_variant__c(Variant_Code__c=invoiceItemWrapper.variant);
                            invoiceItemRecord.variant__r = varObj;
                        }
                        invoiceItemRecord.UOM__c = invoiceItemWrapper.uom;
                        invoiceItemRecord.Return_Reason_Code__c = invoiceItemWrapper.returnReasonCode;
                        invoiceItemRecord.Surcharge__c = invoiceItemWrapper.surcharge;
                        invoiceItemRecord.Surcharge_Amount__c = invoiceItemWrapper.surchargeAmount;
                        invoiceItemRecord.Concessional_Code__c = invoiceItemWrapper.concessionalCode;
                        invoiceItemRecord.Assessee_Code__c = invoiceItemWrapper.assesseeCode;
                        invoiceItemRecord.TDS_TCS__c = invoiceItemWrapper.tdsTcs;
                        //  invoiceItemRecord.TDS_TCS_Amount__c = invoiceItemWrapper.tdsTcsAmount;
                        invoiceItemRecord.Total_Amount__c = invoiceItemWrapper.totalAmount;
                        invoiceItemRecord.Charges__c = invoiceItemWrapper.charges;
                        //invoiceItemRecord.TDS_TCS_Base_Amount__c = invoiceItemWrapper.tdsTcsBaseAmount;
                        invoiceItemRecord.Surcharge_Base_Amount__c = invoiceItemWrapper.surchargeBaseAmount;
                        invoiceItemRecord.TCS_Nature_of_Collection__c = invoiceItemWrapper.tcsNatureOfCollection;
                        invoiceItemRecord.GST_Group_Code__c = invoiceItemWrapper.gstGroupCode;
                        invoiceItemRecord.GST_Base_Amount__c = invoiceItemWrapper.gstBaseAmount;
                        invoiceItemRecord.GST__c = invoiceItemWrapper.gst;
                        invoiceItemRecord.Total_GST_Amount__c = invoiceItemWrapper.totalGstAmount;
                        invoiceItemRecord.HSN_SAC_Code__c = invoiceItemWrapper.hsnSacCode;
                        invoiceItemRecord.Discount_Remarks__c = invoiceItemWrapper.discountRemarks;
                        invoiceItemRecord.Docket_Number__c = invoiceItemWrapper.docketNumber;
                        invoiceItemRecord.Document_Type__c = invoiceItemWrapper.documentType;
                        invoiceItemRecord.Ledger_Type__c = invoiceItemWrapper.ledgerType;
                        invoiceItemRecord.Type__c = invoiceItemWrapper.type;
                        invoiceItemRecord.Amount__c = invoiceItemWrapper.amount;
                        invoiceItemRecord.invoice_Discount_Amount__c = invoiceItemWrapper.invoiceDiscountAmount;
                        if(invoiceItemWrapper.gSTGroupType!='' && invoiceItemWrapper.gSTGroupType!=null){
                            invoiceItemRecord.GST_Group_Type__c = invoiceItemWrapper.gSTGroupType;
                        }
                        iItemList.add(invoiceItemRecord);
                    }
                }
            }
            responseList=impl.upsertInvoiceAndInvoiceItem(plListToUpsert, iItemList,OrderList);
            // uow.registerNew(iItemList);
            // uow.upsertWithExternalId(plListToUpsert,YIN_Price_List__c.Combination_Key__c);
            // uow.commitWork();
            if(responseList.size()>0 && responseList[0].status=='Success'){
                if(responseList[0].id !=null){
                    exceptionLog.apexClass = 'YINInvoiceAndInvoiceItemService';
                    exceptionLog.recordId = responseList[0].id;
                    exceptionLog.module = 'YINInvoiceAndInvoiceItemService';
                    exceptionLog.userId = userId;
                    exceptionLog.request=serilizeJson;
                    exceptionLog.response=JSON.serialize(responseList);
                    exceptionLog.statusCode='200';
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=requestUrl;
                    exceptionLog.typeOfIntegration='Inbound';
                    monitor.requestResponseLog(exceptionLog);
                }
            }else{
                String errorMessage= responseList[0].message;
                String errorCause= String.valueOf(responseList[0].cause);
                Exception exception1 = new System.MathException();
                exception1.setMessage(errorMessage + '-' + errorCause);
                // YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                exceptionLog.exObj = exception1;
                exceptionLog.apexClass = 'YINInvoiceAndInvoiceItemService';
                exceptionLog.module = 'YINInvoiceAndInvoiceItemService';
                exceptionLog.statusCode='400';
                exceptionLog.request=serilizeJson;
                exceptionLog.response=JSON.serialize(responseList);
                monitor.exceptionHandler(exceptionLog);
            }
            return responseList;
        }catch(exception e){
            System.debug('Msg>>>'+e.getMessage());
            System.debug('Line No>>>'+e.getLineNumber());
            System.debug('Cause>>>'+e.getCause());
            //exceptionHandler(Exception exObj,String recordId, String request,String response,String apexClass,String module)
            // monitor.exceptionHandler(e, null, null, null,'YINLedgerUpdateService','DynamicApiCalling');
            ResponseWrapperForInvoice resWrap=new ResponseWrapperForInvoice();
            resWrap.status='Failed';
            resWrap.id= null;
            resWrap.success= false;
            resWrap.created= false;
            resWrap.responseCode='400';
            resWrap.message=e.getMessage();
            resWrap.cause=e.getCause();
            responseList.add(resWrap);
            exceptionLog.exObj = e;
            exceptionLog.apexClass = 'YINInvoiceAndInvoiceItemService';
            exceptionLog.module = 'YINInvoiceAndInvoiceItemService';
            exceptionLog.statusCode='400';
            exceptionLog.request=JSON.serialize(requestBody);
            exceptionLog.response=JSON.serialize(responseList);
            monitor.exceptionHandler(exceptionLog);
            return responseList;
        }
    }
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName)
    {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }

    private static DateTime getDateTimeByString(String dateTimeString){
        //  03-11-23 13:23
        List<String> dateTimeParts = dateTimeString.split(' ');
        List<String> dateParts = dateTimeParts[0].split('-');
        List<String> timeParts = dateTimeParts[1].split(':');

        Integer year = Integer.valueOf('20' + dateParts[2]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[0]);
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);

        DateTime dt = DateTime.newInstance(year, month, day, hour, minute, 0);
        System.debug(dt);
        return dt;
    }
    /**
* @description       : Wrapper class for representing invoice item details in the request body.
*/
    global class InvoiceAndInvoiceItemWrapper {
        public String operation;
        public String invoiceName;
        public String invoiceNumber;
        public String orderDate;
        public String postingDate;
        public String shipmentDate;
        public String soldToParty;
        public String billToParty;
        public String shipToParty;
        public String invoiceAcc;
        public String paymentTermCode;
        public String dueDate;
        public String shipmentMethodCode;
        public String location;
        public String customerPriceGroup;
        public String customerDiscountPriceGroup;
        public String orderNumber;
        public Decimal amount;
        public String transportMethod;
        public String documentDate;
        public String externalDocumentNumber;
        public String paymentMethodCode;
        public String preAssignedNumber;
        public String userId;
        public String canceledBy;
        public String customerLedgerEntryNumber;
        public Decimal discountAmount;
        public Decimal totalAmount;
        public String lrrrNumber;
        public String lrrrDate;
        public String vehicleNumber;
        public String modeOfTransport;
        public String gstBillToStateCode;
        public String gstShipToStateCode;
        public String locationStateCode;
        public String locationGstRegNo;
        public String customerGstRegNo;
        public String shipToGstRegNo;
        public String distanceKm;
        public String referenceInvoiceNumber;
        public String ewayBillNo;
        public String irnHash;
        public String discountRemarks;
        public String remarks;
        public String transporterCode;
        public String pickingNumber;
        public Boolean eInvoiceCreated;
        public String canceledReferenceId;
        public String cancellingIrnDate;
        public boolean cancellingIrn;
        public String cancelRemarks;
        public String cancelledEWayBillNo;
        public String routeNo;
        public String updateRemarks;
        public Boolean cancelInvoice;
        public String routeCode;
        public String invoiceType;
        public String supplyFinishedDate;
        public String orderType;
        public String ledgerType;
        public String sfdcOrderNumber;
        public String documentType;
        public string salesReturnType;
        public string invoiceStatus;
        public List<InvoiceItemWrapper> invoiceItemList=new List<InvoiceItemWrapper>();
        public String status;
    }
    /**
* @description       : Wrapper class for representing invoice and invoice item details in the request body.
*/
    public class InvoiceItemWrapper {
        // Item fields
        public String name;
        public String itemNumber;
        public String item;
        public String location;
        public Decimal quantity;
        public Decimal unitPrice;
        public Decimal lineDiscount;
        public Decimal lineDiscountAmount;
        public Decimal lineAmount;
        public String postingDate;
        public String variant;
        public String uom;
        public String returnReasonCode;
        public Decimal surcharge;
        public Decimal surchargeAmount;
        public String concessionalCode;
        public String assesseeCode;
        public Decimal tdsTcs;
        // public Decimal tdsTcsAmount;
        public Decimal totalAmount;
        public Decimal charges;
        //  public Decimal tdsTcsBaseAmount;
        public Decimal surchargeBaseAmount;
        public String tcsNatureOfCollection;
        public String gstGroupCode;
        public Decimal gstBaseAmount;
        public Decimal gst;
        public Decimal totalGstAmount;
        public String hsnSacCode;
        public String discountRemarks; 
        public String docketNumber;
        public String documentType;
        public String ledgerType;
        public String iLineType;
        public String type;
        public string invoiceDiscountAmount;
        public Decimal amount;
        public String gSTGroupType;
    }
}