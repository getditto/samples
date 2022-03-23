import { Ditto } from '@dittolive/ditto'

let ditto
export default function get(token) {
  if (!ditto) {
    const authHandler = {
      authenticationRequired: async function (authenticator) {
        authenticator.loginWithToken(token, 'my-auth')
      },
      authenticationExpiringSoon: function (authenticator, secondsRemaining) {
        authenticator.loginWithToken(token, 'my-auth')
      },
    }
    const identity = {
      type: 'onlineWithAuthentication',
      appID: "YOUR_APP_ID",
      authHandler: authHandler
    }
    ditto = new Ditto(identity, '/ditto')
    ditto.tryStartSync()
  }
  return ditto
}
