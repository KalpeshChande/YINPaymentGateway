@RestResource(urlMapping='/OtpVerificationService/*')
global class YINSecurityDepositOtpVerService implements YINISecurityDeposit {
    
   ///services/apexrest/OtpVerificationService
    //{ "recordId": "a2Q1e000001ACxYEAW","otpNumber": "853255","accessTokan": "securityDeposit","aadharNumber":"15454","module":"securityDeposit","email":"pkumbhar128@gmail.com","phone":"9619338514"} 
    @HttpPost
    global static String otpVerification(String recordId,String otpNumber,String accessTokan,String aadharNumber,String module,String email,String phone){ 
        YINSecurityDepositOtpVer.ReturnResult otp=new YINSecurityDepositOtpVer.ReturnResult(); 
        otp= YINSecurityDepositOtpVer.otpVerification(recordId,otpNumber,accessTokan,aadharNumber,module,email,phone);
        String otpValue=otp.toString();
        return otpValue;   
        
    }
    
//-------------------------------------------------------------------------------------------------------------------------------------

    global static String getSecurityDeposit(){
        return 'value1';   
    }
    
    global static String saveSecurityDeposit(){
        String requestBody='';
        return requestBody;   
    }
    
    global static String aadharVerification(String recordId,String aadharNumber,String module,String consent,String consentMessage){
        return 'OtpValue';    
    }
    
    global static String callPaymentGateway(String recordId){
        return 'values';    
    }
    
    public static String saveTransaction(String accessTokan){
        return 'String';    
    }
    
    public static String transactionSendToErp(){
        return 'String';    
    } 
    

}