public with sharing class AccountExtension {
    private final Account acc;
    public Org_ReCAPTCHAHandler recaptchaHandler {get; set;}
    public String errorMessage  {get; set;}
    public String successMessage  {get; set;}
    
    public AccountExtension(ApexPages.StandardController ctrl) {
        Acc = (Account)ctrl.getRecord();
        recaptchaHandler = new Org_ReCAPTCHAHandler();
    }
    
    public PageReference save(){
        if (isVerifiedRecaptcha()){
            upsert acc;
            errorMessage='';
            successMessage = 'Account Saved Successfully!';
        }else{
            errorMessage = 'Please solve the captcha';
            successMessage = '';
        } return null;
    }
    
    public boolean isVerifiedRecaptcha() {
        return recaptchaHandler.isVerifiedRecaptcha();
    }
    
    @AuraEnabled
    public static void saveAccount(Account acc)        
    {   
        insert acc;
    }
    
    @AuraEnabled
    public static Org_ReCAPTCHAHandlerLC.wrapperClass recap(){
        //Org_ReCAPTCHAHandlerLC relc = New Org_ReCAPTCHAHandlerLC();
        //return relc;
        system.debug('inside recap');
        //system.debug(Org_ReCAPTCHAHandlerLC.initMethod());
        Org_ReCAPTCHAHandlerLC.wrapperClass getSettings = Org_ReCAPTCHAHandlerLC.initMethod();
        return getSettings;
    }
    
    @AuraEnabled
    public static Boolean verifyResponse(String response){
        system.debug('token inside verifyRespone - '+response);
        return Org_ReCAPTCHAHandlerLC.isVerifiedRecaptcha(response);
    }
    
}