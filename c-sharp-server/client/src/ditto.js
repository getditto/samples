import {init, Ditto, TransportConfig} from '@dittolive/ditto'

async function getditto () {
    await init()
    const authHandler = {
        authenticationRequired: async function (authenticator) {
            console.log("Login request.");
            await authenticator.loginWithToken("jellybeans", "provider");
        },
        authenticationExpiringSoon: function (authenticator, secondsRemaining) {
            console.log(`Auth token expiring in ${secondsRemaining} seconds`)
        }
    }

    const identity = {
        type: 'onlineWithAuthentication',
        appID: "f87f6d8c-1b51-46e2-83d6-d97825ebab71",
        authHandler: authHandler,
        enableDittoCloudSync: false,
        customAuthURL: "https://127.0.0.1:45002"
    }

    const ditto = new Ditto(identity, 'ditto')

    const config = new TransportConfig()
    config.connect.websocketURLs.push('wss://127.0.0.1:45002')
    ditto.setTransportConfig(config)
    ditto.tryStartSync()
}

export default getditto
