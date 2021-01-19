public with sharing class Org_ReCAPTCHAHandlerLC {
    
    private static final String CAPTCHA_DIV_FOR_RESPONSE = 'g-recaptcha-response';
    private static final String PARAM_SECRET = 'secret=';
    private static final String PARAM_SEPARATOR = '&';
    private static final String PARAM_RESPONSE = 'response=';
    
    public class wrapperClass{
        @AuraEnabled public String captchaSiteKey{get;set;}
        @AuraEnabled public String integrationSettingsName{get;set;}
        @AuraEnabled public String captchaEndpoint{get;set;}
        @AuraEnabled public String captchaSecret{get;set;}
    }
    @AuraEnabled
    public static wrapperClass initMethod(){
        Map<String, Code_Toggles__c> codeToggleSettings = Code_Toggles__c.getAll();
        Code_Toggles__c captchaToggle = codeToggleSettings.get('reCAPTCHA_Enterprise');
        
        wrapperClass returnwrapperClass = new  wrapperClass ();
        if(captchaToggle == null || captchaToggle.On__c == false ){ // if null/not set we use free recaptcha
            returnwrapperClass.integrationSettingsName = 'reCAPTCHA';
        } else {
            returnwrapperClass.integrationSettingsName = 'reCAPTCHA_Enterprise';
        }
        
        Map<String, Integration_Settings__c> integrationSettings = Integration_Settings__c.getAll();
        Integration_Settings__c recaptchaSettings = integrationSettings.get(returnwrapperClass.integrationSettingsName);
        if(recaptchaSettings == null) return null;
        
        returnwrapperClass.captchaEndpoint = recaptchaSettings.Endpoint__c;
        returnwrapperClass.captchaSecret = recaptchaSettings.Secret_Key__c;
        returnwrapperClass.captchaSitekey = recaptchaSettings.Site_Key__c;        
        return returnwrapperClass;
    }
    
    @AuraEnabled
    public static boolean isVerifiedRecaptcha(String token) {
        String captchaFromUser = getCaptchaSolveFromUser(token);
        if (captchaFromUser == ''){
            return False;
        }
        if (initMethod().integrationSettingsName == 'reCAPTCHA') {
            system.debug('inside recaptcha');
            String resp = getGooglesResponseToUsersCaptcha(captchaFromuser);
            return captchaPassed(resp);            
        }
        else {
            system.debug('inside enterprise recaptcha');
            String resp = getGooglesResponseToUsersCaptchaEnterprise(captchaFromuser);
            return captchaEnterprisePassed(resp);
        }
    }
    
    @AuraEnabled
    public static String getCaptchaSolveFromUser(String token) {
        String captchaResponse = token;
        return captchaResponse == null ? '' : captchaResponse;
    }
    
    private static String getGooglesResponseToUsersCaptcha(String captchaResponse) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(initMethod().captchaEndpoint);
        req.setMethod('GET');
        req.setBody(
            PARAM_SECRET +
            initmethod().captchaSecret +
            PARAM_SEPARATOR +
            PARAM_RESPONSE +
            captchaResponse
        );
        HttpResponse res = h.send(req);
        String resBody = res.getBody();
        return resBody;
    }
    
    private static boolean captchaPassed(String resp) {
        Map<String, Object> respObject = (Map<String, Object>) JSON.deserializeUntyped(resp);
        return(respObject.get('success') == true);
    }
    
    /* Enterprise version */
    
    public static String ReCAPTCHA_Enterprise_Payload(String token, String captchaSiteKey) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('event');
        gen.writeStartObject();
        gen.writeObjectField('token', token);
        gen.writeObjectField('siteKey', captchaSiteKey);
        gen.writeEndObject();
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    private static String getGooglesResponseToUsersCaptchaEnterprise(String captchaResponse) {
        String json = ReCAPTCHA_Enterprise_Payload(captchaResponse, initmethod().captchaSiteKey);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:reCAPTCHA_Enterprise/projects/ic-10292020-ptt-recaptcha/assessments');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setMethod('POST');
        req.setBody(json);
        HttpResponse res = h.send(req);
        String resBody = res.getBody();
        return resBody;
    }
    
    private static boolean captchaEnterprisePassed(String resp) {
        Map<String, Object> respObject = (Map<String, Object>) JSON.deserializeUntyped(resp);
        Map<String, Object> riskAnalysis = (Map<String, Object>)respObject.get('riskAnalysis');
        Double score = (Double)riskAnalysis.get('score');
        if (score >= .5) {
            return true;
        }
        else {
            return false;
        }
    }
    
}