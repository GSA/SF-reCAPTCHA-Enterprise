A code package to implement Google reCAPTCHA Enterprise on Salesforce sites and communities.

## Project Name:

Google reCAPTCHA – Org wide implementation on Salesforce

## Description:

reCAPTCHA is a tool provided by Google and used on many registration and signup forms to prevent spam prevention. Code included under &#39;src&#39; folder will handle either Free or Enterprise version of Google reCAPTCHA on both client-side and server-side. Examples are included for implementing in Visualforce (sites) or Lightning Component(Lightning communities).

## Installation:

For Enterprise version of reCAPTCHA, some manual steps are required prior to deploying code in this repository. Please refer to Installation.md for Enterprise reCAPTCHA setup. Below are some steps which can be followed after downloading code and prior to deploying for Enterprise version.

***For Enterprise Version,***

1. Prior to deploying edit two Apex class files (Org\_reCaptchaHandler – for Visualforce, Org\_reCaptchaHandlerLC – for Lightning), both will need changes under getGooglesResponseToUsersCaptchaEnterprise method for endpoint URL. Edit with Enterprise Named Credentials setup done using installation.md

### Deployment

Everything under &#39;src&#39; folder can be deployed, but below are some additional details if reCAPTCHA is only being used with Visualforce or Lightning.

Org\_ReCAPTCHAHandler.cls – Used for Visualforce pages

Org\_ReCAPTCHAHandlerTest.cls – Test class for Org\_ReCAPTCHAHandler.cls

Org\_ReCAPTCHAHandlerLC.cls – used for Lightning components

Org\_ReCAPTCHAHandlerLCTest.cls – Test class for Org\_ReCAPTCHAHandlerLC.cls

Org\_ReCAPTCHA.vfp – used only with Lightning component for serving recaptcha widget.

Integration\_Settings\_\_c.object – Custom settings used for Free and Enterprise Sitekey, secretkey, and Endpoint URLs.

Code\_Toggles\_\_c.object – Custom settings used for toggling Free or Enterprise version of reCaptcha.

Remote Sites – for Google and GoogleApis endpoint.

### Post-Deployment

1. Add 2 Records with same names given below, under Integration Settings (Custom Settings)
   1. reCAPTCHA
      1. Name - reCAPTCHA
      2. Endpoint - https://www.google.com/recaptcha/api/siteverify
      3. Secret Key - Provided by Google
      4. Site Key - Provided by Google
   2. reCAPTCHA\_Enterprise
      1. Name - reCAPTCHA\_Enterprise
      2. Endpoint - https://recaptchaenterprise.googleapis.com
      3. Secret Key
      4. Site Key - Provided by Google
2. Add 1 record with same name given below, under Code Toggles(Custom Settings). Keeping &#39;On&#39; as checked is only used for Enterprise version, else uncheck it for Free version
   1. Name - reCAPTCHA\_Enterprise
   2. Message - this message does not get displayed
   3. On - Checked

## Usage:

There are two examples included, &#39;/examples&#39; folder, for Account record creation using Visualforce page (AccountRecaptchaExample.vfp) and Account record creation using Aura Lightning component (accountRecaptchaLCExample).  Both examples utilize same Apex class (AccountExtension.cls).

Visualforce Example is straight forward but Lightning component example has good amount of details due to work around required for referencing Google Api js files in Lightning environment. Since the introduction of Lightning Locker services, referencing CDN files directly on Lightning component is not allowed. Only other 2 ways are either having js file as static resource (not advisable since google api files change quite often) or using Visualforce page(this allows referencing CDN files directly) inside of an iFrame. Second option is utilized as a solution here, and communication between iFrame (Visualforce page) and Lightning component is done using Postmessages and EventListeners.

***Additional notes to pay attention for,***

1. In accountRecaptchaLCexample, Visualforce page on lightning component is referenced with path of &#39;apex/Org\_reCAPTCHA&#39;, this will need to change if it&#39;s being used with Lightning communities to &#39;<communityname>/apex/Org\_reCAPTCHA&#39;. There is also a save method in helper js file where this change need to occur.
2. Communication between both, Visualforce page and Lightning component, requires origin URL to be known of the other end and this will need to be handled in both places. A design parameter can be created on Lightning component, but Visualforce page may need hard-coding for the origin URL.
3. Verify Visualforce pages are given proper access for profiles/permission sets.

## Questions?

If you have questions, please feel free to contact us:

- Open an issue