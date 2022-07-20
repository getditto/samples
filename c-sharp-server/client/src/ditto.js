import {Ditto, TransportConfig} from '@dittolive/ditto'

let ditto 

function getditto () {
    if (ditto) return ditto
    const authHandler = {
        authenticationRequired: async function (authenticator) {
            console.log(`Auth required`)
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
        customAuthURL: "http://127.0.0.1:45002"
    }

    ditto = new Ditto(identity, 'ditto')

    const config = new TransportConfig()
    config.connect.websocketURLs.push('ws://127.0.0.1:45002')
    ditto.setTransportConfig(config)
    ditto.tryStartSync()
    return ditto
}

export default getditto
