# Installation Instructions

## Google Cloud Platform

- Request access to reCAPTCHA Enterprise from: https://cloud.google.com/recaptcha-enterprise/docs/migrate-recaptcha

### Create Service Account

### Create OAuth2.0 Client ID

`Google Cloud Platform > APIs & Services > Credentials > New`

- Name: {name of site/app}
- Authorized JavaScript Origins: {enter all applicable domains where reCAPTCHA will be used for this implementation}
  - e.g. https://myorgname.secure.force.com
- Authorized redirect URIs: {callback URL's from Salesforce}
  - e.g. https://myorgname.my.salesforce.com/services/authcallback/Google

### Create reCAPTCHA Enterprise API Key

`Google Cloud Platform > Security > reCAPTCHA Enterprise > Create Key`

- Name: {name of site/app}
- Platform: Website
- Domains: {enter all applicable domains where reCAPTCHA will be used}
- Challenge Security: {select Easy, Medium, Harder}
- Verify Domains: CHECKED
- CREATE KEY

## Salesforce

### Create Authentication Provider

`Setup > Authentication Provider > New`

- Provider Type: Open ID Connect
- Name: Google
- URL Suffix: Google
- Consumer Key: `{consumer key from Google}`
- Consumer Secret: `{consumer secrete from Google}`
- Authorize Endpoint URL: https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&prompt=consent
- Token Endpoint URL: https://www.googleapis.com/oauth2/v4/token
- Default Scopes: openid
- Send access token in header: CHECKED
- Send client credentials in header: CHECKED
- Include Consumer Secret in API Responses: CHECKED

### Create Named Credentials

- Label: reCAPTCHA_Enterprise
- Name: reCAPTCHA_Enterprise
- URL: https://recaptchaenterprise.googleapis.com/v1
- Identity Type: Named Principle
- Authentication Protocol: OAuth 2.0
- Authentication Provider: Google
- Scope: openid https://www.googleapis.com/auth/cloud-platform
- Generate Authorization Header: CHECKED

### Configure Remote Site

- Remote Site Name: Google_reCAPTCHA_Enterprise
- Remote Site URL: https://recaptchaenterprise.googleapis.com
- Description: Endpoint for Google reCAPTCHA Enterprise verification

### Custom Settings
