
import { init, Ditto, Document } from '@dittolive/ditto'
import * as readline from 'readline/promises'
import { stdin as input, stdout as output } from 'node:process';

let ditto
let subscription
let liveQuery
let tasks: Document[] = []

async function main () {
  await init()

  ditto = new Ditto({ type: 'onlinePlayground', appID: 'YOUR_APP_ID', token: 'YOUR_TOKEN' })
  ditto.startSync()

  subscription = ditto.store.collection("tasks").find("isDeleted == false").subscribe()
  liveQuery = ditto.store.collection("tasks").find("isDeleted == false").observeLocal((docs, event) => {
    tasks = docs
  })
  let isAskedToExit = false
  
  console.log("************* Commands *************");
  console.log("--insert my new task");
  console.log("   Inserts a task");
  console.log("   Example: \"--insert Get Milk\"");
  console.log("--toggle myTaskTd");
  console.log("   Toggles the isComplete property to the opposite value");
  console.log("   Example: \"--toggle 1234abc\"");
  console.log("--delete myTaskTd");
  console.log("   Deletes a task");
  console.log("   Example: \"--delete 1234abc\"");
  console.log("--list");
  console.log("   List the current tasks");
  console.log("--exit");
  console.log("   Exits the program");
  console.log("************* Commands *************");

  const rl = readline.createInterface({ input, output });
  while (!isAskedToExit) {

      let answer = await rl.question('Your command:')
      if (answer.startsWith("--insert")) {
        let body = answer.replace("--insert ", "")
        ditto.store.collection("tasks").upsert({
          body,
          isDeleted: false,
          isCompleted: false
        })
      }
      if (answer.startsWith("--toggle")) {
        let id = answer.replace("--toggle ", "")
        ditto.store.collection("tasks")
        .findByID(id).update((doc) => {
          let isCompleted = doc.value.isCompleted
          doc.at("isCompleted").set(!isCompleted)
        })
      }
      if (answer.startsWith("--list")) {
        console.log(tasks.map((task) => task.value))
      }
      if (answer.startsWith("--delete")) {
        let id = answer.replace("--delete ", "")
        ditto.store.collection("tasks")
        .findByID(id).update((doc) => {
          doc.at("isDeleted").set(true)
        })
      }
      if (answer.startsWith("--exit")) {
        ditto.stopSync()
        process.exit()
        
      }
  }

}

main()
