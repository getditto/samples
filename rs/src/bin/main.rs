use anyhow::Result;
use clap::Parser;
use dittolive_ditto::{identity::*, prelude::*};
use serde_json::json;
use std::{
    self,
    str::FromStr,
    sync::{mpsc, Arc},
};

/// A template app to demo Ditto's Rust SDK
///
/// This will log into your Ditto app via the AppID and Token
/// you provide. These can be found at <https://portal.ditto.live>
///
/// This will sync changes from the Collection you specify,
/// and print details of all events and documents received.
#[derive(Parser)]
struct Args {
    /// The Ditto App ID to sync with (found at portal.ditto.live)
    #[clap(long, env = "APP_ID")]
    app_id: String,

    /// The Playground token used to authenticate (found at portal.ditto.live)
    #[clap(long, env = "SHARED_TOKEN")]
    shared_token: String,

    /// The Collection which we would like to sync with to observe changes
    #[clap(long, env = "COLLECTION")]
    collection: String,
}

fn main() -> Result<()> {
    dotenv::dotenv().ok();
    let args = Args::parse();

    // Initialize Ditto SDK client
    let app_id = AppId::from_str(&args.app_id)?;
    let ditto = Ditto::builder()
        .with_root(Arc::new(PersistentRoot::from_current_exe()?))
        .with_minimum_log_level(LogLevel::Debug)
        .with_identity(move |ditto_root| {
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

    // Begin sync, then open the store and get a handle to our collection
    ditto.start_sync()?;
    let store = ditto.store();
    let collection = store.collection(&args.collection)?;

    // Create a subscription to our collection to sync all changes in it
    //
    // Note: Subscription handle cancels when dropped, bind it to keep it alive
    let _subscription = collection.find_all().subscribe();

    // Create a LiveQuery to receive events when changes are made in our collection
    //
    // Note: LiveQuery handle cancels when dropped, bind it to keep it alive
    let (_live_query, receiver) = {
        let (sender, receiver) = mpsc::channel::<(Vec<BoxedDocument>, LiveQueryEvent)>();
        let live_query_handler = move |documents: Vec<BoxedDocument>, event: LiveQueryEvent| {
            sender.send((documents, event)).unwrap();
        };
        let live_query = collection.find_all().observe_local(live_query_handler)?;
        (live_query, receiver)
    };

    // Insert a document into the collection
    let document = collection.upsert(json!({
        "hello": "world"
    }))?;
    println!("Inserted document with id={}", document);

    // Watch live-query events in our collection and print them
    loop {
        let (documents, event) = receiver.recv()?;

        println!("We have event {:?}", event);
        for doc in documents {
            println!("\tDocument {:?}", doc.to_cbor());
        }
    }
}
