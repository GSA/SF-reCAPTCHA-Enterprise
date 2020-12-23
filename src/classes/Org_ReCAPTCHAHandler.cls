public with sharing class Org_ReCAPTCHAHandler {
    
    private final String CAPTCHA_DIV_FOR_RESPONSE = 'g-recaptcha-response';
	private final String PARAM_SECRET = 'secret=';
	private final String PARAM_SEPARATOR = '&';
	private final String PARAM_RESPONSE = 'response=';

	@AuraEnabled public String captchaSitekey {get; set;}
    @AuraEnabled public String integrationSettingsName {get; set;}
    private Map<String, Integration_Settings__c> integrationSettings = Integration_Settings__c.getAll();
    private Map<String, Code_Toggles__c> codeToggleSettings = Code_Toggles__c.getAll();
	private String captchaEndpoint;
	private String captchaSecret;
    
	public Org_ReCAPTCHAHandler() {
        Code_Toggles__c captchaToggle = codeToggleSettings.get('reCAPTCHA_Enterprise');
        if(captchaToggle == null || captchaToggle.On__c == false ){ // if null/not set we use free recaptcha
            integrationSettingsName = 'reCAPTCHA';
        } else {
            integrationSettingsName = 'reCAPTCHA_Enterprise';
        }
		setCaptchaSettings();
	}

	public boolean isVerifiedRecaptcha() {
        system.debug('inside isverifiedRecaptcha');
		String captchaFromUser = getCaptchaSolveFromUser();
        if (captchaFromUser == ''){
            return False;
        }
        if (integrationSettingsName == 'reCAPTCHA') {
            String resp = getGooglesResponseToUsersCaptcha(captchaFromuser);
            return captchaPassed(resp);            
        }
        else {
            String resp = getGooglesResponseToUsersCaptchaEnterprise(captchaFromuser);
            return captchaEnterprisePassed(resp);
        }
	}

	private void setCaptchaSettings(){
		Integration_Settings__c recaptchaSettings = integrationSettings.get(integrationSettingsName);
		if(recaptchaSettings == null) return;
		captchaEndpoint = recaptchaSettings.Endpoint__c;
		captchaSecret = recaptchaSettings.Secret_Key__c;
		captchaSitekey = recaptchaSettings.Site_Key__c;
	}

	private String getCaptchaSolveFromUser() {
		String captchaResponse = ApexPages.currentPage().getParameters().get(CAPTCHA_DIV_FOR_RESPONSE);
        system.debug('captchaResponse - '+captchaResponse);
		return captchaResponse == null ? '' : captchaResponse;
	}

	private String getGooglesResponseToUsersCaptcha(String captchaResponse) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(captchaEndpoint);
		req.setMethod('GET');
		req.setBody(
					PARAM_SECRET +
					captchaSecret +
					PARAM_SEPARATOR +
					PARAM_RESPONSE +
					captchaResponse
		);
		HttpResponse res = h.send(req);
		String resBody = res.getBody();
		return resBody;
	}

	private boolean captchaPassed(String resp) {
		Map<String, Object> respObject = (Map<String, Object>) JSON.deserializeUntyped(resp);
		return(respObject.get('success') == true);
	}
    
    /* Enterprise version */
    
    public String ReCAPTCHA_Enterprise_Payload(String token, String captchaSiteKey) {
        system.debug('captchaSiteKey - '+captchaSiteKey);
        system.debug(token);
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
    
    private String getGooglesResponseToUsersCaptchaEnterprise(String captchaResponse) {
        system.debug('getGooglesResponseToUsersCaptchaEnterprise captchaSiteKey - '+captchaSiteKey);
        String json = ReCAPTCHA_Enterprise_Payload(captchaResponse, captchaSiteKey);
        system.debug(json);
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

	private boolean captchaEnterprisePassed(String resp) {
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