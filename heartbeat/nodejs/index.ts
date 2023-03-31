import { init, Ditto, IdentityOnlinePlayground, Document } from '@dittolive/ditto'

let ditto:Ditto
let subscription
let liveQuery

async function main () {
  await init()

  const identity: IdentityOnlinePlayground = { 
    type: 'onlinePlayground', 
    appID: 'APP_ID',
    token: 'TOKEN',
  }
  ditto = new Ditto(identity)

  subscription = ditto.store.collection("heartbeat").findByID("heartbeat").subscribe()
  liveQuery = ditto.store.collection("heartbeat").findByID("heartbeat").observeLocal((doc, event) => {
    console.log('heartbeat', doc)
    ditto.store.collection('pong').upsert({
      _id: "pong",
      timestamp: doc?.value['time']
    })
  })

  ditto.startSync()
} 

main()
