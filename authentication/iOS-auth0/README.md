# iOS Auth0 Example

1. Open iOS-auth0.xcodeproj
2. Install the Ditto Swift Package (see the [ditto documentation](https://docs.ditto.live/installation/ios))
3. In your Auth0 account, create`Native` application as `iOS` with your choice of name.
4. In your Auth0 account, configure both callback and logout URLs (the same) as:
    `ditto.iOS-auth0://dev-yde4hme57nj5emiw.us.auth0.com/ios/ditto.iOS-auth0/callback`.
5. Enter your Auth0 `ClientId` and `Domain` credentials in `Auth0.plist`
6. Set up your webhook, for example on Glitch (see [ditto   documentation](https://docs.ditto.live/ios/common/security/authentication))
7. In your Ditto account portal, in the section `Authentication Mode & Webhook Settings`, select
    `with authentication`. In the provided fields add a webhook `Name` identifier and webhook `URL`.
8. In `ContentView.swift`, in `AuthDelegate` method `authenticationRequired(authenticator: DittoAuthenticator)` 
    ensure the webhook name identifier is the value for parameter `provider`, e.g. `"glitch"`.
9. In Ditto.Config extension replace`"YOUR_APP_ID_HERE"` with your Ditto portal `App ID` value.
5. Run the app on a device and run another instance on the simulator.

## Access Token

Contact us at [support@ditto.live](support@ditto.live) to request a free license token!
