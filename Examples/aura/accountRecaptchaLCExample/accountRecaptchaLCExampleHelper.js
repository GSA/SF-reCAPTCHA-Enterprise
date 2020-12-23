({
    //verify captcha before saving a record
    doRecaptchaVerification: function(component, event, helper, token) {
        var action = component.get("c.verifyResponse");
        action.setParams({
            response: token
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const valid = response.getReturnValue();
                if (!valid) {
                    component.set('v.formMessage', 'Sorry, we could not verify you.');
                } else if (valid) {
                    component.set('v.formMessage', '');                    
                    // reCaptcha validatated, continue with record save
                    helper.doSave(component, event, helper);
                }
            } else {
                const errors = response.getError();
                component.set('v.formMessage', 'Sorry, an error occured.');
            }
        });
        
        $A.enqueueAction(action);
    },    
    
    doSave : function(component, event, helper) {
        var action = component.get('c.saveAccount');                            
        action.setParams({
            acc : component.get('v.createAcc')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.formMessage', 'Account created successfully!');
                var d = new Date();
                var n = d.getTime();   
                component.set("v.ifmsrc", '/apex/Org_ReCAPTCHA?t='+ n ); //for communities, add <communityName>/apex/Org_ReCAPTCHA?t=
            }
        });
        $A.enqueueAction(action);
    },
})