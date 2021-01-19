@isTest
private class Org_ReCAPTCHAHandlerLCTest {
    @testSetup
    static void testSetupMethod() {        
        Integration_Settings__c captchaSettings = new Integration_Settings__c();
        captchaSettings.Name = 'reCAPTCHA';
        captchaSettings.Secret_Key__c = 'randomsecretkey';
        captchaSettings.Endpoint__c = 'https://www.google.com/recaptcha/api/siteverify';
        captchaSettings.Site_Key__c = 'randomsitekey';
        insert captchaSettings;
        
        Integration_Settings__c captchaSettingsEnt = new Integration_Settings__c();
        captchaSettingsEnt.Name = 'reCAPTCHA_Enterprise';
        captchaSettingsEnt.Secret_Key__c = '';
        captchaSettingsEnt.Endpoint__c = 'https://recaptchaenterprise.googleapis.com';
        captchaSettingsEnt.Site_Key__c = 'randomenterprisesitekey';
        insert captchaSettingsEnt;          
    }
    
    @isTest static void isVerifiedRecaptchaRegularLCTest(){
        Code_Toggles__c codeToggles = new Code_Toggles__c();
        codeToggles.Name = 'reCAPTCHA_Enterprise';
        codeToggles.On__c = false;
        codeToggles.Message__c = 'The form is temporarily down right now.';
        insert codeToggles;
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockTest());
        Test.startTest();        
        system.assertEquals(true,Org_ReCAPTCHAHandlerLC.isVerifiedRecaptcha('helloresponse'));
        Test.stopTest();
    }
    
    @isTest static void isVerifiedRecaptchaRegularWithoutTokenLCTest(){
        Code_Toggles__c codeToggles = new Code_Toggles__c();
        codeToggles.Name = 'reCAPTCHA_Enterprise';
        codeToggles.On__c = false;
        codeToggles.Message__c = 'The form is temporarily down right now.';
        insert codeToggles;
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockTest());
        Test.startTest();
        system.assertEquals(false,Org_ReCAPTCHAHandlerLC.isVerifiedRecaptcha(''));
        Test.stopTest();
    }
    
    @isTest static void isVerifiedRecaptchaEnterpriseLowScoreLCTest(){
        Code_Toggles__c codeToggles = new Code_Toggles__c();
        codeToggles.Name = 'reCAPTCHA_Enterprise';
        codeToggles.On__c = true;
        codeToggles.Message__c = 'The form is temporarily down right now.';
        insert codeToggles;
        String body = '{"riskAnalysis": {"score": 0.1,"reasons": ["AUTOMATION"]}}';
        String endpoint = 'callout:reCAPTCHA_Enterprise/projects/ic-10292020-ptt-recaptcha/assessments';
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockTest(body,endpoint, 'POST'));
        Test.startTest();
        system.assertEquals(false,Org_ReCAPTCHAHandlerLC.isVerifiedRecaptcha('helloresponse'));
        Test.stopTest();
    }
    
    @isTest static void isVerifiedRecaptchaEnterpriseHighScoreLCTest(){
        Code_Toggles__c codeToggles = new Code_Toggles__c();
        codeToggles.Name = 'reCAPTCHA_Enterprise';
        codeToggles.On__c = true;
        codeToggles.Message__c = 'The form is temporarily down right now.';
        insert codeToggles;
        String body = '{"riskAnalysis": {"score": 0.6,"reasons": ["AUTOMATION"]}}';
        String endpoint = 'callout:reCAPTCHA_Enterprise/projects/ic-10292020-ptt-recaptcha/assessments';
        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockTest(body,endpoint, 'POST'));
        Test.startTest();
        system.assertEquals(true,Org_ReCAPTCHAHandlerLC.isVerifiedRecaptcha('helloresponse'));
        Test.stopTest();
    }
}