({
  /* When component is initialized apex controller call is made
   * which returns necessary sitekey, and integration setting(free vs enterprise recaptcha) values and
   * these values are sent to iframe via post message which then renders reCaptcha widget.
   * */
  init: function(component, event, helper) {
    var action = component.get("c.recap");
    action.setParams({});
    action.setCallback(this, function(response) {
      const state = response.getState();
      if (state === "SUCCESS") { //also handle Incomplete and Error state, not added below.
        var sitekey = response.getReturnValue().captchaSiteKey;
        var integrationSettingsName = response.getReturnValue().integrationSettingsName;
        component.set("v.sitekey", sitekey);
        component.set("v.integrationSettingsName", integrationSettingsName);
        const hostURL = "https://" + window.location.hostname.split(".")[0] + "--c.visualforce.com";
        component.set("v.approvedHost", hostURL);

        //Post message to iframe with Sitekey and integrationsettingsname
        const iframe = component.find("vfFrame").getElement();
        const vfWindow = iframe.contentWindow;
        iframe.onload = function() {
          vfWindow.postMessage(
            {
              type: "captcha-vars",
              key: sitekey,
              hostURL,
              integrationSettingsName
            },
            hostURL
          );
        };
        const vfOrigin = hostURL;
        //Event listener for messages from iframe visualforce page
        window.addEventListener(
          "message",
          function(event) {
            /*
             *  Checking the captcha state so we can toggle the error message off if it's been completed.
             */
            if (event.data.action == "checkCAPTCHAState") {
              if (event.data.isValid) {
                component.set("v.formMessage", "");
              }
            }
            
            //if captcha image puzzle is visible, set iframe height,
            //TODO - handle height after image puzzle submission
            if(event.data.captchaVisible === 'visible'){
                var captchEl = document.getElementById('vfFrame');
                captchEl.height=500;
            } else {
                let captchEl = document.getElementById('vfFrame');
                captchEl.height = 70;
            }

            //if event message was not received from iframe Origin exit the listerner
            if (event.origin !== vfOrigin) {
              return;
            }
                
			//form submission without captcha
            if (event.data.action == "tokenAvailability" &&
                event.data.tokenAvailable == "Not Available") {     
                //show error
                component.set("v.formMessage", "Please Verify reCaptcha!");}
            //form submission with captcha
            else if (event.data.action == "tokenAvailability" &&
                event.data.tokenAvailable == "Available") {
                //continue with Server side validation
                const token = event.data.response;
                helper.doRecaptchaVerification(component, event, helper, token);
            }
          },
          false
        );
      }
    });

    $A.enqueueAction(action);
  },

  submitForm: function(component, event, helper) {
    event.preventDefault();
      //do client side validation before moving forward with server submission, example: account name
    const isValid = true;
    if (isValid) {
      //if client side validation passes, send message to visualforce page for token
      const vfOrigin = component.get("v.approvedHost");
      const vfWindow = component.find("vfFrame").getElement().contentWindow;
      vfWindow.postMessage({ action: "tokenAvailability" }, vfOrigin);
    } else {
      component.set("v.formMessage", "Sorry, the form is not valid.");
    }
  }
});