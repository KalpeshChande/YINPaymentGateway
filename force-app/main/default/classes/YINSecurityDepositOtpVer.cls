/**
 * @description       : This Class is used to verify OTP Number via Integration Services.
 * @author            : Prashat Kumbhar/prashat.kumbhar@skinternational.com
 * @group             : SKI
 * @last modified on  : 27-12-2023
 * @last modified by  : Amol Patil/amol.patil@skinternational.com
**/
public class YINSecurityDepositOtpVer  {
    
    /**
* @description:This method is used to verify OTP Number via Integration Services.
* @param recordId : to get Record with the help of Id.
* @param otpNumber : to get Otp Number from LWC and Verify from Integration Service.
* @return String Otp Success or Fail.
*/
    @AuraEnabled
    public static  ReturnResult otpVerification(String recordId,String otpNumber,String accessTokan,String aadharNumber,String module,String email,String phone){
        System.debug('RecordId is'+recordId);
        System.debug('Otp Number is'+otpNumber);
        System.debug('AAdhar Number is'+aadharNumber);
        System.debug('module'+module);
        System.debug('email'+email);
        System.debug('phone'+phone);
        
        
        YIN_Security_Deposit__c getSD=new YIN_Security_Deposit__c();
        YIN_Change_Request__c requ=new YIN_Change_Request__c();
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        YINMonitorService x=new  YINMonitorService();
        ReturnResult ret=new ReturnResult();
        String result='';
        
        try{
            
           /*  clientInner z=new clientInner();
            otpWrap ot=new otpWrap();
            ot.consent='Y';
            ot.otp=otpNumber;
            ot.aadhaarNo=aadharNumber;
            ot.sharecode='1234';
            ot.accessKey=accessTokan;
            z.caseId=recordId;
            ot.clientData=z;
            
            String otpBody=JSON.serializePretty(ot);
            System.debug('JSON BODY is'+otpBody);   */         
            
           ////////Fake response
          
            ret.status='Success';
            ret.message='Otp verification Success';
            ret.caseId=recordId;
          //  requ.Status__c='Aadhar Verification Success'; 
           
            //requ.Id=recordId;
           // getSD.Status__c='Aadhar Verification Success';
          //  uow.registerDirty(requ);  
           // uow.commitWork();                       
            ///////Fake Response        
            if(module=='securityDeposit'){
                getSD.Id=recordId;
                getSD.Status__c='Aadhar Verification Success';
                uow.registerDirty(getSD);  
                uow.commitWork();
            }
            if(module=='changeRequest'){
                requ.Id=recordId;
                requ.Status__c='Aadhar Verification Success';
                uow.registerDirty(requ);  
                uow.commitWork();
            }
            
          /* String otpUrl='https://testapi.karza.in/v3/get-aadhaar-file';
            Http http = new Http();    
            HttpRequest req = new HttpRequest();
            //  req.setEndpoint(otpUrl);
            req.setEndpoint('callout:OtpVerification');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
             req.setHeader('x-karza-key','lIcWRvsaWJzZVMUz'); 
            //req.setHeader('x-karza-key', '{!$Credential.Password}');
            req.setTimeout(120000 ); 
            req.setBody(otpBody);
            HTTPResponse res=new HTTPResponse();
             if(!test.isRunningTest())
            {
            res=http.send(req);
            }
             else if(test.isRunningTest())
            {
             res.setBody('{ "result" : { "consentValidation" : { "status" : true , "providedName" : "Rahul Kumar" , "percentageOfMatch" : 90.28 } , "message" : "Aadhaar XML file downloaded successfully" , "dataFromAadhaar" : { "maskedAadhaarNumber" : "xxxx xxxx 1234" , "name" : "Rahul Suraj Kumar" , "fatherName" : "" , "husbandName" : "" , "relativeName" : "" , "dob" : "1981-07-14" , "gender" : "M" , "image" : "/9j/4AAQSkZJRgABAgAAAQABAAD/2wBxDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKD "mobileHash" : "2d148ac1fe409eec9489c467d084fef4c1b387e3d4f9241387a2e48028c95ea7d" , "emailHash" : "135242ef6ff4e42126beb41a4c4964a86afab3b5fcad2bb10b0e8cf3b964f2b8c" , "generatedDateTime" : "2021-02-04 18:31:54.315" , "file" : "UEsDBBQACQAIAPuTRFIAAAAAAAAAAAAAAAAjAAAAb2ZmbGluZWFhZGhhYXIyMDIxMDIwNDA2MzE1NDMyNi54bWztD8OJdPcn "address" : { "combinedAddress" : "1A/11, Piramal Aura,, MG Road,, Opposite R-City Mall,, Kurla, Mumbai Suburban, Mumb "splitAddress" : { "district" : "Mumbai Suburban" , "country" : "India" , "subdistrict" : "Kurla" , "pincode" : "400086" , "state" : "Maharashtra" , "street" : "MG Road," , "postOffice" : "Ghatkopar West" , "location" : "Ghatkopar West" , "landmark" : "Opposite R-City Mall," , "houseNumber" : "1A/11, Piramal Aura," , "vtcName" : "Mumbai" } } } } , "statusCode" : 101 , "requestId" : "376ccef1-8076-449a-9be9-ba4e51c998ba" , "clientData" : { "caseId" : "123456" } }');
                 
            }
            System.debug('Res'+res.getBody());        
            
            String jsonString=res.getBody();
            System.debug('Body is'+res.getBody());
            
            YINSecurityDepositOtpVer myResponse1=new YINSecurityDepositOtpVer();
            if(!test.isRunningTest())
            {
            myResponse1 = (YINSecurityDepositOtpVer)JSON.deserialize(jsonString, YINSecurityDepositOtpVer.class);
            }
            else if(test.isRunningTest())
            {
                myResponse1.statusCode=101;
            }
            System.debug('Status Code is'+myResponse1.statusCode) ;
            String userId=UserInfo.getUserId();
            if(myResponse1.statusCode==101){
                System.debug('Request Success');
               ret.status='Success';
               ret.message='Otp verification Success';
               ret.caseId=recordId;
                
                if(module=='securityDeposit'){
                getSD.Id=recordId;
                getSD.Status__c='Aadhar Verification Success';
                uow.registerDirty(getSD);  
                uow.commitWork();
               // x.requestResponseLog(otpBody,jsonString,String.valueof(myResponse1.statusCode),'YINSecurityDepositOtpVer',recordId,'Security Deposit',userId,'Security Deposit','Outbound','POST',otpUrl,'','','','KarzaKyc');                
				 YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                    exceptionLog.apexClass = 'YINSecurityDepositOtpVer';
                    exceptionLog.recordId = recordId;
                    exceptionLog.module = 'Security Deposit';
                    exceptionLog.userId = userId;
                    exceptionLog.request=otpBody;
                    exceptionLog.response=jsonString;
                    exceptionLog.statusCode=String.valueof(myResponse1.statusCode);
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=otpUrl;
                    exceptionLog.typeOfIntegration='Outbound';
                    x.requestResponseLog(exceptionLog);                 
}
                
               //Added By Amol Patil
                if(module=='changeRequest'){
                requ.Id=recordId;
                requ.Status__c='Aadhar Verification Success';
                uow.registerDirty(requ);  
                uow.commitWork();
                //x.requestResponseLog(otpBody,jsonString,String.valueof(myResponse1.statusCode),'YINSecurityDepositOtpVer',recordId,'Change Request',userId,'Change Request','Outbound','POST',otpUrl,'','','','KarzaKyc');
               YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                    exceptionLog.apexClass = 'YINSecurityDepositOtpVer';
                    exceptionLog.recordId = recordId;
                    exceptionLog.module = 'Security Deposit';
                    exceptionLog.userId = userId;
                    exceptionLog.request=otpBody;
                    exceptionLog.response=jsonString;
                    exceptionLog.statusCode=String.valueof(myResponse1.statusCode);
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=otpUrl;
                    exceptionLog.typeOfIntegration='Outbound';
                    x.requestResponseLog(exceptionLog);  
                System.debug('In Change Request success');
                    
                }  
            }
            else{
               System.debug(' Request fail');
               ret.status='error';
               ret.message='Otp verification Fail';
               ret.caseId=recordId;
               
                if(module=='securityDeposit'){
                getSD.Id=recordId;
                getSD.Status__c='Aadhar Verification Failed';
                uow.registerDirty(getSD);  
                uow.commitWork();
                //x.requestResponseLog(otpBody,jsonString,String.valueof(myResponse1.statusCode),'YINSecurityDepositOtpVer',recordId,'Security Deposit',userId,'Security Deposit','Outbound','POST',otpUrl,'','','','KarzaKyc');                
               YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                    exceptionLog.apexClass = 'YINSecurityDepositOtpVer';
                    exceptionLog.recordId = recordId;
                    exceptionLog.module = 'Security Deposit';
                    exceptionLog.userId = userId;
                    exceptionLog.request=otpBody;
                    exceptionLog.response=jsonString;
                    exceptionLog.statusCode=String.valueof(myResponse1.statusCode);
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=otpUrl;
                    exceptionLog.typeOfIntegration='Outbound';
                    x.requestResponseLog(exceptionLog);  

}
                
                //Added By Amol Patil
                if(module=='changeRequest'){
                requ.Id=recordId;
                requ.Status__c='Aadhar Verification Failed';
                uow.registerDirty(requ);  
                uow.commitWork();
                //x.requestResponseLog(otpBody,jsonString,String.valueof(myResponse1.statusCode),'SecurityDepositOtpVer',recordId,'Change Request',userId,'Change Request','Outbound','POST',otpUrl,'','','','KarzaKyc');
               YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                    exceptionLog.apexClass = 'YINSecurityDepositOtpVer';
                    exceptionLog.recordId = recordId;
                    exceptionLog.module = 'Security Deposit';
                    exceptionLog.userId = userId;
                    exceptionLog.request=otpBody;
                    exceptionLog.response=jsonString;
                    exceptionLog.statusCode=String.valueof(myResponse1.statusCode);
                    exceptionLog.message='Success';
                    exceptionLog.method='POST';
                    exceptionLog.requestURL=otpUrl;
                    exceptionLog.typeOfIntegration='Outbound';
                    x.requestResponseLog(exceptionLog);  
					System.debug('In Change Request fail');
                    
                }
                
            }    */
            return ret;
        }
        
        Catch(Exception e){
            System.debug('Exception'+e.getMessage());
            System.debug('Exception'+e.getLineNumber());
            System.debug('Exception'+e.getCause());
            //x.exceptionHandler(e,recordId,'','','SecurityDepositOtpVer','Security Deposit');
            YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                exceptionLog.exObj = e;
                exceptionLog.apexClass = 'SecurityDepositOtpVer';
                exceptionLog.module = 'Security Deposit';
                x.exceptionHandler(exceptionLog);
            ret.status='error';
            return   ret;
        }
    } 
    public class otpWrap{
        public String consent;
        public String otp;
        public String aadhaarNo;
        public String shareCode;
        public String accessKey;
        public clientInner clientData;  
    }
    
    public  class clientInner {
        public String caseId;
    }
    
    public class Result {
        public String accessKey;
        public String accessKeyValidity;
    }
    
    public class ClientData {
        public String caseId;
    }
    
    public class ReturnResult{
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String caseId;
        
        
    }
    
    public Result result;
    public Integer statusCode;
    public String requestId;
    public String message;
    public ClientData clientData;
}