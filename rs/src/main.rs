use dittolive_ditto::{identity::*, prelude::*};
use std::sync::mpsc::channel;
use std::{self, str::FromStr, sync::Arc};
use structopt::StructOpt;
use serde_json::json;

#[derive(StructOpt)]
struct Args {
    #[structopt(long, env = "APP_ID")]
    app_id: String,
    #[structopt(long, env = "SHARED_TOKEN")]
    shared_token: String,
    #[structopt(long, env = "COLLECTION")]
    collection: String,
}

fn main() -> Result<(), DittoError> {
    let args = Args::from_args();
    let (sender, receiver) = channel::<(Vec<BoxedDocument>, LiveQueryEvent)>();
    let event_handler = move |documents: Vec<BoxedDocument>, event: LiveQueryEvent| {
        sender.send((documents, event)).unwrap();
    };

    let ditto = Ditto::builder()
        .with_root(Arc::new(PersistentRoot::from_current_exe()?))
        .with_minimum_log_level(LogLevel::Debug)
        .with_identity(|ditto_root| {
            let app_id = AppId::from_str(&args.app_id).unwrap();
            let shared_token = args.shared_token;
            let enable_cloud_sync = true;
            let custom_auth_url = None;
            OnlinePlayground::new(
                ditto_root,
                app_id,
                shared_token,
                enable_cloud_sync,
                custom_auth_url,
            )
        })?
        .build()?;

    ditto.start_sync().unwrap();
    let store = ditto.store();
    let collection = store.collection(&args.collection)?;

    let sub = collection.find_all().subscribe();
    let _lq = collection.find_all().observe_local(event_handler)?;
    let res = collection.upsert(json!({
        "hello": "world"
    }));

    println!("Inserted document with id={}", res.unwrap());

    loop {
        let (documents, event) = receiver.recv().unwrap();

        println!("We have event {:?}", event);
        for doc in documents {
            println!("\tDocument {:?}", doc.to_cbor());
        }
    }
}
