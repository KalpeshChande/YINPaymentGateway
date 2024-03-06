public class YINSecurityDepositPaymentGateway {
    
    /**
   * @description:This method is used to verify Payment Gateway from Integration Serivce.
   * @param recordId : to get Record with the help of Id.
   * @return String Otp Success or Fail.
   */
       @AuraEnabled
       public static ResultPaymentLink callPaymentGateway(String recordId){
         //  recordId= 'a1n0T000000XOs4QAG';
           YIN_Security_Deposit__c getSD=new YIN_Security_Deposit__c();
           LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
           ResultPaymentLink link=new ResultPaymentLink();
            
           String recordtype=Schema.SObjectType.YIN_Security_Deposit__c.getRecordTypeInfosByName().get('Increase').getRecordTypeId();
           LIBISObjectSelector selector= YINApplication.selector.newInstance(YIN_Security_Deposit__c.sObjectType);
           YINSecurityDepositSelector selectorObj=(YINSecurityDepositSelector)selector;
           	getSD=selectorObj.getSD(recordId,recordtype);
           System.debug('Get SD'+getSD);
           YINMonitorService x=new  YINMonitorService();   
           
           try{
           
           String js1='{"currency": "INR"}';
           notesInner notes=new notesInner();
           notes.key1='value3';
           notes.key2='value2';
           
           orderWrap wrap=new orderWrap();
           wrap.amount=getSD.SD_Increase_Amount__c*100;
           wrap.receipt='receipt#1';
           wrap.notes=notes;
           
           String orderData=JSON.serializePretty(wrap);
           Map<String, Object> map1 = (Map<String, Object>)JSON.deserializeUntyped(js1);
           Map<String, Object> map2 = (Map<String, Object>)JSON.deserializeUntyped(orderData);
           
           Map<String, Object> combinedMap = new Map<String, Object>();
           combinedMap.putAll(map1);
           combinedMap.putAll(map2);
           String combinedJsonString = JSON.serialize(combinedMap);
           System.debug('OrderData'+combinedMap);
           
           String username = 'rzp_test_PhvV8OmudTXbs0';
           String password = '98op7LToZDOGKzmcEYvjA5Uu';
           
           Blob headerValue = Blob.valueOf(username + ':' + password);
           String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
           
           Http http = new Http();    
           HttpRequest req = new HttpRequest();
           //req.setEndpoint('https://api.razorpay.com/v1/orders');
           req.setEndpoint('callout:RazorpayOrderCreate');    
           req.setMethod('POST');
           //req.setHeader('Authorization', authorizationHeader);
           req.setHeader('Content-Type', 'application/json;charset=UTF-8');
           req.setTimeout(120000 ); 
           req.setBody(combinedJsonString);
           HTTPResponse res=new HTTPResponse(); 
               if(!test.isRunningTest())
               {
                   res=http.send(req);
               }
               else if(test.isRunningTest())
               {
                   res.setHeader('Content-Type', 'application/json');
                   res.setBody('{"id":"order_NEEsVAG67MzvV9","entity":"order","amount":400,"amount_paid":0,"amount_due":400,"currency":"INR","receipt":"receipt#1","offer_id":null,"status":"created","attempts":0,"notes":{"key1":"value3","key2":"value2"},"created_at":1702996550}');
               }
           System.debug('Res'+res.getBody());        
           String jsonString=res.getBody();
           System.debug('jsonString'+jsonString);  
           YINSecurityDepositPaymentGateway myResponse1 = (YINSecurityDepositPaymentGateway)JSON.deserialize(jsonString, YINSecurityDepositPaymentGateway.class);
           System.debug('myResponse1.id'+myResponse1.id);
           System.debug('myResponse1.Status'+myResponse1.status);
           System.debug('myResponse1.Amount'+myResponse1.amount);
           //Data Prepration for Payment Link Creation
           Datetime dt = Datetime.now();
           Datetime dt1=dt.adddays(5);
           Long l = dt1.getTime()/1000;
           Long epoch=l;
           if(myResponse1.status=='created'){
               InnerCustomer inCust=new InnerCustomer();
               inCust.name='Prashant Kumbhar';
               inCust.contact='+919619338514';
               inCust.email='prashant.kumbhar@skinternational.com';
               Innernotify innerNot=new Innernotify();
               innerNot.sms=true;
               innerNot.email=true;
               InnerNotes notes1=new InnerNotes();
               notes1.policy_name='';
               CreatePaymentLinkWrap wrap1=new CreatePaymentLinkWrap();
               wrap1.amount=myResponse1.amount;
               wrap1.accept_partial=false;
              // wrap1.first_min_partial_amount=100;
               wrap1.expire_by=epoch;
               wrap1.reference_id=myResponse1.id;            
               wrap1.customer=inCust;
               wrap1.notify=innerNot;
               wrap1.reminder_enable=true;
               wrap1.notes=notes1;
               wrap1.callback_url='https://yokohama-india--dev.sandbox.lightning.force.com/';
               wrap1.callback_method='get';
               String PaymentLinkData=JSON.serializePretty(wrap1);
               Map<String, Object> map3 = (Map<String, Object>)JSON.deserializeUntyped(js1);
               Map<String, Object> map4 = (Map<String, Object>)JSON.deserializeUntyped(PaymentLinkData);
               Map<String, Object> combinedMap1 = new Map<String, Object>();
               combinedMap1.putAll(map3);
               combinedMap1.putAll(map4);
               String combinedJsonString1 = JSON.serialize(combinedMap1);
               System.debug('PaymentLink'+combinedJsonString1);
               ///Now Creating Payment Link
               String createLinkApi='https://api.razorpay.com/v1/payment_links';
               Http http1 = new Http();    
               HttpRequest req1 = new HttpRequest();
              // req1.setEndpoint(createLinkApi);
               req1.setEndpoint('callout:PaymentLink');    
               req1.setMethod('POST');
               //req1.setHeader('Authorization', authorizationHeader);
               req1.setHeader('Content-Type', 'application/json;charset=UTF-8');
               req1.setTimeout(120000 ); 
               req1.setBody(combinedJsonString1);
               HTTPResponse res1=new HTTPResponse(); 
               if(!test.isRunningTest())
               {
               res1=http.send(req1);
               }
               else if(test.isRunningTest())
               {
                    res1.setHeader('Content-Type', 'application/json');
                    res1.setBody('{"accept_partial":true,"amount":40000,"amount_paid":0,"callback_method":"get","callback_url":"https:example-callback-url.com","cancelled_at":0,"created_at":1702996826,"currency":"INR","customer":{"contact":"+919619338514","email":"pkumbhar128@gmail.com","name":"Prashant Kumbhar"},"description":"","expire_by":1703083137,"expired_at":0,"first_min_partial_amount":100,"id":"plink_NEExMvncmSq1WD","notes":{"policy_name":""},"notify":{"email":true,"sms":true,"whatsapp":false},"payments":null,"reference_id":"order_NEEsVAG67MzvV9","reminder_enable":true,"reminders":[],"short_url":"https:rzp.ioiv7q2tkh","status":"created","updated_at":1702996826,"upi_link":false,"user_id":"","whatsapp_link":false}');
               }
                   
               System.debug('Res'+res1.getBody());        
               String jsonString1=res1.getBody();
               System.debug('jsonString'+jsonString1);  
               YINSecurityDepositPaymentGateway myResponse2 = (YINSecurityDepositPaymentGateway)JSON.deserialize(jsonString1, YINSecurityDepositPaymentGateway.class);
               System.debug('Short URL'+myResponse2.short_url);
               System.debug('Status'+myResponse2.status);
               System.debug('Status id'+myResponse2.id);
               System.debug('resfeenece'+myResponse2.reference_id);
               String userId=UserInfo.getUserId();
               if(myResponse2.status=='created'){
                   link.url=myResponse2.short_url;
                   link.result='success';
                   link.id=myResponse2.id;
                   link.refernceId=myResponse2.reference_id;
                   System.debug('Url is'+link.url);
                   getSD.Status__c='Payment Inprogress';
                   uow.registerDirty(getSD);
                   uow.commitWork();
                   YIN_Payment__c pay=new YIN_Payment__c();
                   pay.Amount__c=myResponse1.amount;
                   pay.Order_Id__c=myResponse1.id;
                   pay.Remitters_Name__c='0010T00000fYTVBQA4';
                   pay.Customer_Number__c='0010T00000fYTVBQA4';    
                   insert pay;
               x.requestResponseLog(combinedJsonString1,jsonString1,String.valueof(myResponse2.status),'SecurityDepositPaymentGateway',recordId,'Security Deposit',userId,'Security Deposit','Outbound','POST',createLinkApi,'','','','Razorpay');                
               }
           }
           return link;
           }
           Catch(Exception e){
                x.exceptionHandler(e,recordId,'','','SecurityDepositPaymentGateway','Security Deposit');
                link.result='Fail';
                return link;
           }
       }
       public class orderWrap{
           public decimal amount;
           public String receipt;
           public notesInner notes;   
       }
       
       public class notesInner{
           public String key1;
           public String key2;
       }
       
       public class CreatePaymentLinkWrap{
           public decimal amount;
           public boolean accept_partial;
           public decimal first_min_partial_amount;
           public long expire_by;
           public String reference_id;
           public String description;
           public InnerCustomer customer;
           public Innernotify notify;
           public boolean reminder_enable;
           public InnerNotes notes;
           public String callback_url;
           public String callback_method;
           
       }
       public class InnerCustomer{
           public String name;
           public String contact;
           public String email;   
       }
       public class Innernotify{
           public boolean sms;
           public boolean email;
       }
       
       public class InnerNotes{
           public String policy_name;   
       }
       
       public class ResultPaymentLink{
           @AuraEnabled
           public String url;
           @AuraEnabled
           public String result;
           @AuraEnabled
           public String id;
           @AuraEnabled
           public String refernceId;    
       }
       
       public String id;
       public decimal amount;
       public String status;
       public String short_url;
       public String reference_id;
   }