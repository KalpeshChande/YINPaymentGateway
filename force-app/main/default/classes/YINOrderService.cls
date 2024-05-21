@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount')
/**
* @RestResource(urlMapping='/OrderApi/*')
* @description This class provides RESTful web services for managing orders.
* @author            : Kalpesh.Chande@skinternational.com
* @group             : SKI
* @last modified on  : 10-01-2024
* @last modified by  : Kalpesh.Chande@skinternational.com
*/
@RestResource(urlMapping='/OrderApi/*')
global with sharing class YINOrderService {
    /**
     * @HttpPost
     * @description Handles HTTP POST requests to update order records.
     * @param requestBody The list of OrderWrapper objects containing order details.
     * @return List<ResponseWrapper> The response list containing the status of the operation.
     */
    @HttpPost
    global static List<ResponseWrapper> sendPostRequest(OrderWrapper[] requestBody) {
        // System.debug('requestBody: ' + requestBody);
        YINMonitorService monitor=new  YINMonitorService();
        String  userId=userInfo.getUserId();   
        String response=''; 
        List<Order> orderToUpdate=new List<Order>();
        List<String> failedRecord=new List<String>();
        List<ResponseWrapper> responseData = new List<ResponseWrapper>();
        YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
        Boolean isSuccess=false;
        try {
            YINExternalApiServiceImpl impl = (YINExternalApiServiceImpl)YINApplication.service.newInstance(YINIExternalApiService.class);
            String serilizeJson=JSON.serialize(requestBody);
            //System.debug('SerilizeJson: ' + serilizeJson);
            List<OrderWrapper> orderWrapList = (List<OrderWrapper>)JSON.deserialize(serilizeJson, List<OrderWrapper>.class);
            // System.debug('Parsed JSON: ' + requestBody.size());
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Map<String,Order> orderMap=new Map<String,Order>();
            List<Order> orderList=impl.getOrderData();
            for(Order ordObj:orderList){
                orderMap.put(ordObj.ERP_Order_Number__c,ordObj);
            }
            // system.debug('req'+req);
            String requestUrl;
            if(test.isRunningTest()==true){
                requestUrl = 'test.com';
            }else{
                requestUrl = req.requestURI;
            }
            for (OrderWrapper orderWrapObj : orderWrapList) {
                if(orderMap.containsKey(orderWrapObj.eRPOrderNumber)){
                    Order orderObj=orderMap.get(orderWrapObj.eRPOrderNumber);
                    orderObj.ERP_Order_Number__c=orderWrapObj.eRPOrderNumber;
                    orderObj.Status=orderWrapObj.orderStatus;
                    if(orderWrapObj.scheduleDateOfDelivery !=null && orderWrapObj.scheduleDateOfDelivery !=''){
                    orderObj.Schedule_Date_Of_Delivery__c=Date.valueOf(orderWrapObj.scheduleDateOfDelivery);
                    }
                    if(orderWrapObj.remarks !=null && orderWrapObj.remarks !=''){
                    orderObj.Remarks__c=orderWrapObj.remarks;
                    }
                    if(orderWrapObj.promisedDate !=null && orderWrapObj.promisedDate !=''){
                        orderObj.Promised_Date__c=Date.valueOf(orderWrapObj.promisedDate);
                    }
                    if(orderWrapObj.postingDate !=null && orderWrapObj.postingDate !=''){
                        orderObj.Posting_Date__c=Date.valueOf(orderWrapObj.postingDate);
                    }
                    orderToUpdate.add(orderObj);
                }else{
                    failedRecord.add(orderWrapObj.eRPOrderNumber);
                }
            }
            System.debug('orderToUpsert>>>'+orderToUpdate);
            if(orderToUpdate.size()==orderWrapList.size()){
                impl.updateSobjectList(orderToUpdate);
                // uow.registerDirty(orderToUpdate);
                //uow.commitWork();
                for (Integer i = 0; i < orderToUpdate.size(); i++) {
                    isSuccess=true;
                    Map<String, Object> responseObj = new Map<String, Object>();
                    ResponseWrapper resWrap=new ResponseWrapper();
                    resWrap.status='success';
                    resWrap.id= orderToUpdate[i].Id;
                    resWrap.eRPOrderNumber= orderToUpdate[i].ERP_Order_Number__c;
                    resWrap.success= true;
                    resWrap.created= false;
                    resWrap.responseCode='200';
                    resWrap.message='success';
                    responseData.add(resWrap);
                    exceptionLog.apexClass = 'YINOrderService';
                    exceptionLog.recordId = orderToUpdate[i].Id;
                    exceptionLog.module = 'YINOrderService';
                    exceptionLog.userId = userId;
                    exceptionLog.request=serilizeJson;
                    exceptionLog.response=JSON.serialize(responseData);
                    exceptionLog.statusCode='200';
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=requestUrl;
                    exceptionLog.typeOfIntegration='Inbound';
                }
            }else{
                for (Integer i = 0; i < failedRecord.size(); i++) {
                    Map<String, Object> responseObj = new Map<String, Object>();
                    ResponseWrapper resWrap=new ResponseWrapper();
                    resWrap.status='Failed';
                    resWrap.id= null;
                    resWrap.eRPOrderNumber= failedRecord[i];
                    resWrap.success= false;
                    resWrap.created= false;
                    resWrap.responseCode='400';
                    resWrap.message=failedRecord[i]+ ' ERP_Order_Number__c is invalid';
                    responseData.add(resWrap);
                    Exception exception1 = new System.MathException();
                    exception1.setMessage(failedRecord[i]+ ' ERP_Order_Number__c is invalid');
                    exceptionLog.exObj = exception1;
                    exceptionLog.apexClass = 'YINOrderService';
                    exceptionLog.module = 'YINOrderService';
                    exceptionLog.request=JSON.serialize(requestBody);
            		exceptionLog.response=JSON.serialize(responseData);
                    // responseData.add(responseObj);
                }
            }
            if( isSuccess==true){
            monitor.requestResponseLog(exceptionLog);
            }else{
            monitor.exceptionHandler(exceptionLog);
            }
            return responseData;
        }catch(Exception e){
            System.debug('Msg>>>'+e.getMessage());
            System.debug('Line No>>>'+e.getLineNumber());
            System.debug('Cause>>>'+e.getCause());
            //exceptionHandler(Exception exObj,String recordId, String request,String response,String apexClass,String module)
            //  monitor.exceptionHandler(e, null, null, null,'YINOrderService','DynamicApiCalling');
             
            ResponseWrapper resWrap=new ResponseWrapper();
            resWrap.status='Failed';
            resWrap.id= null;
            resWrap.eRPOrderNumber= null;
            resWrap.success= false;
            resWrap.created= false;
            resWrap.responseCode='400';
            resWrap.message=e.getMessage();
            resWrap.cause=e.getCause();
            responseData.add(resWrap);
            exceptionLog.exObj = e;
            exceptionLog.apexClass = 'YINOrderService';
            exceptionLog.module = 'YINOrderService';
            exceptionLog.request=JSON.serialize(requestBody);
            exceptionLog.response=JSON.serialize(responseData);
            monitor.exceptionHandler(exceptionLog);
            return responseData;
        }
    }
    /**
     * @description Inner class representing the structure of the request body for order operations.
     */
    global class OrderWrapper {
        public String eRPOrderNumber;	
        public String orderStatus;
        public String scheduleDateOfDelivery;
        public String remarks;
        public String promisedDate;
        public String postingDate;
    }
     /**
     * @description Inner class representing the response structure for order operations.
     */
    global class ResponseWrapper {
        public String status;	
        public String responseCode;
        public String message;
        public Exception cause;
        public String eRPOrderNumber;
        public String id;
        public Boolean created;
        public Boolean success;
    }
    
}