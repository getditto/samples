use dittolive_ditto::store::ditto_attachment_fetch_event::DittoAttachmentFetchEvent;
use dittolive_ditto::store::ditto_attachment_token::DittoAttachmentToken;
use dittolive_ditto::{identity, prelude::*};
use std::collections::HashMap;
use std::sync::Mutex;
use std::sync::mpsc::channel;
use std::time::{SystemTime, Duration};
use std::{sync::Arc};
use std::{io, fs};
use std::io::{prelude::*};
use std::str::FromStr;
use std::env;
use std::{thread, time};
use std::process::exit;

use serde::{Deserialize, Serialize};
use serde_json::json;
use uuid::Uuid;

#[derive(Serialize, Deserialize)]
struct MyDoc {
    _id: String,
}
#[warn(unused_assignments)]

fn show_args_reminder(){
    println!("Args reminder <host/client/bt> <test_num> <sender/receiver> Optional<v>");
}

fn main() {

    // My ID
    let id = Uuid::new_v4();
    println!("My device id: {}", id.to_string());

    // Applicaiton ID (can be anything)
    let app_id_str:String = "pi-transport-document-test-app".to_string();

    // Transports - TCP Host, TCP client, BluetoothLE
    let mut host_config = TransportConfig::new();
    host_config.listen.tcp.enabled = true;
    host_config.listen.tcp.port = 8080;
    host_config.listen.tcp.interface_ip = "0.0.0.0".to_owned();

    let mut client_config = TransportConfig::new();

    // Bluetooth config  - BluetoothLE enabled
    let mut bt_config = TransportConfig::new();
    bt_config.peer_to_peer.bluetooth_le.enabled = true;

    // Default transport config
    let mut transport_config = TransportConfig::new();

    // Test mode string - to be read in command line args
    let mut test_mode = "sender";

    // Verbose mode - set by command line args
    let mut verbose_debug = false;    

    // Arguments
    // <host / client / bt>
    let mut args = env::args();

    // Argument 1: <host/client/bt>
    let _app_name = args.next(); // necessary to get to first arg
    let host_client_opt = args.next();
    let mut host_client = "".to_string();
    if host_client_opt.is_none() {
        println!("Expected <host/client/bt> in 1st argument");
        show_args_reminder();
        print!("{}", host_client);
        exit(0);
    }

    host_client = host_client_opt.unwrap();

    if host_client == "host"{
        transport_config = host_config;
        println!("This is a host");
    } else if host_client == "client" {
        // Get IP address
        // Argument 2: IP address
        let mut lan_client_address_str = "".to_string();
        let lan_client_address_opt = args.next();
        if lan_client_address_opt.is_none() {
            print!("{}", lan_client_address_str);
            println!("Expected IP address as second argument.");
            show_args_reminder();
            exit(0);
        } 
        lan_client_address_str = lan_client_address_opt.unwrap();
        // Set IP address for client to connect to
        let other_peer = format!("{}:8080", &lan_client_address_str);
        client_config.connect.tcp_servers.insert(other_peer);
        transport_config = client_config;
        println!("This is a client");
    } else if host_client == "bt"{
        transport_config = bt_config;
        println!("This is a bleutooth client/server");
    } else {
        println!("Not sure what this is {}", host_client);
    }
    println!("Transport: {} ", host_client);
    
    // Argument 2 (host/bt) / 3 (client): Test number
    // 1 - Documents per second - documents per second
    // 2 - Document with large amount of data - download speed
    // 3 - Document with attachment - download speed
    let test_number_opt  = args.next();
    let mut test_number = "".to_string();
    if test_number_opt.is_some() {
        test_number = test_number_opt.unwrap();
        println!("Test number: {}", test_number);
    } else {
        print!("{}", test_number);
        println!("Expected test number in 2nd argument");
        show_args_reminder();
        exit(1);
    }
    
    // Sender or receiver
    // Sender - looks for a receiver and sends docs
    // Receiver - sits and waits for documents to be received then reports speed
    let sender_receiver = args.next();
    if sender_receiver.is_none(){
        if host_client == "client" {
            if test_number == "sender" || test_number == "receiver" {
                println!("Reminder: for client you need to specify an IP address as the second argument:\n<client> <ip address> <test_num> <sender/receiver> Optional<i>");
            }
        } else {
            println!("Expected <sender/receiver> in 3rd argument");
        }
        
        show_args_reminder();
        exit(0);
    }
    let sender_receiver_str = sender_receiver.unwrap();
    if sender_receiver_str == "receiver" {
        test_mode = "receiver";
    } else if sender_receiver_str != "sender"{
        println!("Unexpected mode: {}. Setting mode to sender.", sender_receiver_str);
    } 
    
    // OPTIONAL ARGS 
    // 'v' for verbose debug logging
    let arg_4 = args.next();
    if arg_4.is_some() {
        if arg_4.clone().unwrap() == "v" {
            verbose_debug = true;
        }
    }
    let arg_5 = args.next();
    if arg_5.is_some(){
        if arg_5.clone().unwrap() == "v" {
            verbose_debug = true;
        }
    }

    // Set up Ditto Offline Playground mode 
    let ditto = Ditto::builder()    // creates a `ditto_data` folder in the directory containing the executing process    
    .with_root(Arc::new(PersistentRoot::from_current_exe().unwrap()))    
    .with_minimum_log_level(LogLevel::Warning)
    .with_identity(|ditto_root| {        // Provided as an env var, may also be provided as hardcoded string        
        let app_id = AppId::from_str(&app_id_str)?;        
        identity::OfflinePlayground::new(ditto_root, app_id)
    }).unwrap()
    .with_transport_config(|_identity| -> TransportConfig{
        transport_config
    })   
    .unwrap().build().unwrap();

    if verbose_debug {
        println!("Verbose debug mode enabled.");
        Ditto::set_minimum_log_level(LogLevel::Debug);
    }

    
    // Get license from environment variable - rememeber to set with "export DITTO_LICENSE=<license_key>" in terminal or bashrc config
    ditto.set_license_from_env("DITTO_LICENSE").unwrap();

    // Start ditoo
    _ = ditto.start_sync();
    let store = ditto.store();
    let collection = store.collection("docs").unwrap();         // Default store "docs"

    // Scope variables
    let docs_count = Arc::new(Mutex::new(0));                   // Count number of documents
    let some_tn =Some(test_number.clone());                     // The test number
    let mut test_vec = Vec::<u64>::new();                       // The vector that gets elements popped from to count number of documents
    let start_time = Arc::new(Mutex::new(0));                   // Save start time to count time taken for test
    let send_pong = Arc::new(Mutex::new(false));                // "Send Pong" which is set to true when it receives a "ping" document - used in "pause" loop
    let send_pong_b = Arc::clone(&send_pong);                   // A copy of "send_pong" that keeps the same value but can be passed into document event handler loop
    
    // sender received pong back check
    let pong_ack = Arc::new(Mutex::new(false));                 // Pong acknowledge - signals the start of a test - sued in "pause" loop
    let pong_ack_b = Arc::clone(&pong_ack);                     // Copy of "pong_ack" for use in document event handler
    let att_optional: Option<DittoAttachmentToken> = None;                              // Place to store the attachment token as an "Option" so that it can be checked if it is not null
    let att_token_mutex = Arc::new(Mutex::new(att_optional));   // Reference to the attachment token for use in event handler
    let att_token_mutex_live_loop = att_token_mutex.clone();        // Copy of above reference for use in "pause" loop - which downloads the attachment

    let coll_mutex = Arc::new(Mutex::new(collection.clone()));  // Reference of the collection to eb passed into "pause" loop. Continuing to make good use of Arc Mutexes.
    
    // Start of document handler
    let test_handler = move |docs:Vec<BoxedDocument>, event:LiveQueryEvent| {
        match event {
            LiveQueryEvent::Update { old_documents: _, insertions, .. } => {
                let indices = &*insertions;
                for index in indices {
                    let doc_i = &docs[*index];
                    let mut sender:String = "none".to_string();

                    // Try to get sender id if it exists in the document
                    if doc_i.get::<String>("sender").is_ok() {
                        sender = doc_i.get::<String>("sender").unwrap();
                    }
                    // Check sender ID - if it is not our own, then do stuff
                    if sender != id.to_string() {
                        println!("--------\nGot New 'test' document(s) from other device.");
                        println!("Sender: {}", sender);                            
                        println!("New document inserted at position {}", index);

                        // Get "test_type" value from document (assuming it exists)
                        let test_type:String = doc_i.get::<String>("test_type").unwrap();
                    
                        // A testing document for docs per second speed (each document in the test)
                        if test_type == "speedtest_1_doc" {
                            _ = test_vec.pop();
                            println!("Test vector length: {}", test_vec.len().to_string());
                            if let Some(tn) = &some_tn{
                                if *tn == "1" {
                                    let mut dc = docs_count.lock().unwrap();
                                    *dc += 1;
                                }
                            }
                            // Once reached end of test
                            if test_vec.len() == 0 {
                                println!("Received all docs for test.. now to do the speed calculation..");
                                let now = SystemTime::now()
                                    .duration_since(SystemTime::UNIX_EPOCH)
                                    .unwrap()
                                    .as_millis(); // See struct std::time::Duration methods
                                let duration = now - *start_time.lock().unwrap();
                                let dps = 100.0 / (duration as f32 / 1000.0);
                                let spd = (duration as f32) / 100.0;
                                println!("Duration ms: {}, docs per second: {}, ms per doc {}", duration, dps, spd);

                                let coll2 = coll_mutex.lock().unwrap().clone();
                                
                                // Now quit!
                                print!("Quitting in 2 seconds");
                                send_quit_doc(coll2, id.to_string());
                                delay_ms(2000);
                                exit(0);

                            }
                        // A doc that signifies the start of test 1
                        } else if test_type == "start_test"{
                            // Reset test vec
                            test_vec = Vec::<u64>::new();
                            for i in 0..100 {
                                test_vec.push(i);
                            }
                            let mut dc = docs_count.lock().unwrap();
                            *dc = 0;
                            let now = SystemTime::now()
                                .duration_since(SystemTime::UNIX_EPOCH)
                                .unwrap()
                                .as_millis(); // See struct std::time::Duration methods

                            let mut start_ms = start_time.lock().unwrap();
                            *start_ms = now;
                        // A doc that signifies the end of test 1
                        } else if test_type == "end_test" {
                           println!("End of test document received but this may not be the end..?");
                        }
                        
                        // 2.
                        // Second step - receive ping
                        // A ping document
                        else if test_type == "ping_doc" {
                            if sender != id.to_string() {
                                println!("Ping from another device!");
                                *send_pong_b.lock().unwrap() = true; 
                            }                    
                        }
                        // Start of large doc sending  (Test 2)
                        else if test_type == "large_doc_start"{
                            let now = SystemTime::now()
                                .duration_since(SystemTime::UNIX_EPOCH)
                                .unwrap()
                                .as_millis(); // See struct std::time::Duration methods

                            let mut start_ms = start_time.lock().unwrap();
                            *start_ms = now;
                        } 
                        // Got the large document. After a 250ms delay
                        else if test_type == "large_doc" {
                            let now = SystemTime::now()
                                .duration_since(SystemTime::UNIX_EPOCH)
                                .unwrap()
                                .as_millis(); // See struct std::time::Duration methods

                            let start_ms = start_time.lock().unwrap();
                            let duration = now - *start_ms - 250;
                            let doc_size_kb = get_file_size_kb("doc_contents.txt".to_string()).unwrap();
                            let kb_s = doc_size_kb / (duration as f32 / 1000.0) as f32;
                            println!("Large Document Duration ms: {}, kb/s: {}", duration, kb_s);

                            let coll2 = coll_mutex.lock().unwrap().clone();

                            // Now quit!
                            print!("Quitting in 2 seconds");
                            send_quit_doc(coll2, id.to_string());
                            delay_ms(2000);
                            exit(0);
                        }
                        // Attachment document (Test 3)
                        else if test_type == "attachment" {
                            println!("Attachment received?");
                            let att_token_option = doc_i.get::<DittoAttachmentToken>("my_attachment");
                            
                            let mut att_token_option_mutex = att_token_mutex.lock().unwrap();
                            if att_token_option.is_ok() {
                                std::thread::sleep(Duration::from_millis(500));
                                *att_token_option_mutex = Some(att_token_option.unwrap());
                                println!("Attachment exists");
                            } else {
                                println!("Attachment does not exist??");
                            }                  
                        }
                        // 4.
                        // Fourth step - received an acknowlegement, now time to start test
                        // A pong/ack document
                        else if test_type == "pong_ack_doc" {
                            println!("Received a PONG acknwoledgement. Now to run a test!");
                            if sender != id.to_string() {
                                println!("Pong ack from another device!");
                                *pong_ack_b.lock().unwrap() = true;
                            }
                        } 
                        // Signal to quit
                        else if test_type == "quit"{
                            print!("Quitting in 10 seconds.");
                            delay_ms(10000);
                            exit(0);
                        }
                        // Some other document? 
                        else {
                            println!("Other doc recieved: {}", test_type);
                        }
                        println!("--------");
                    }
                }
            },
            _ => { }
        }
    };

    // Remove all old test docs
    let args = json!({"doc_type": "test"});
    collection.find_with_args("doc_type == $args.doc_type", args.clone()).remove().unwrap();

    let _startq = collection
        .find_with_args("doc_type == $args.doc_type", args.clone())
        .observe_local(test_handler);
    let _sub = collection.find_with_args("doc_type == $args.doc_type", args.clone()).subscribe();    

    pause(collection, test_number.clone(), send_pong, pong_ack, att_token_mutex_live_loop, id.clone(), test_mode.to_string().clone());
}

// After test done, tell sender device to quit program
fn send_quit_doc(coll: Collection, sender:String){
    let large_doc = json!({
        "test_type": "quit",
        "doc_type": "test",
        "sender": sender,
    });
    _ = coll.upsert(large_doc);
}

// Simple time delay function
fn delay_ms(ms:u64) {
    // Delay 250ms to give other device time to prepare for start
    let millis_time = time::Duration::from_millis(ms);
    thread::sleep(millis_time);
}

fn get_file_size_kb(filename:String) -> Result<f32, String>{
    match fs::metadata(filename) {
        Ok(metadata) => {
            let file_size = metadata.len();
            println!("File size: {} bytes", file_size);
            return Ok(file_size as f32 / 1000.0);
        }
        Err(error) => {
            eprintln!("Error getting file metadata: {}", error);
            return Err("Error getting file metadata".to_string());
        }
    }
}

// Test 1 - sending many documents to time docs/sec
fn test_1_docs_sec(coll:Collection, sender:String) {
    println!("Running test 1..");
    let start_doc = json!({
        "test_type": "start_test",
        "doc_type": "test",
        "sender": sender,
        "number_sent": 100
    });
    let end_doc =  json!({
        "doc_type": "test",
        "test_type": "end_test",
        "sender": sender,
        "number_sent": 100
    });

    // Add the start document
    coll.upsert(start_doc).unwrap();

    // Delay to make sure this doc is sent first..
    delay_ms(250);

    // Add test docs (100)
    for i in 0..100 {
        let st_1_doc = json!({
            "test_type": "speedtest_1_doc", 
            "doc_type": "test",
            "number_sent": 100,
            "sender": sender,
            "test_id" : i
        });
        coll.upsert(st_1_doc.clone()).unwrap();
    }
    delay_ms(250);

    // Add end doc
    coll.upsert(end_doc).unwrap();
}

// Test 2 - Sending a large document with lots of data (not attachment)
fn test_2_large_doc(coll:Collection, sender:String){
    // Read text to pu into the document
    let contents = fs::read_to_string("doc_contents.txt")
        .expect("Should have been able to read the file");
    // Pre-emptive first document that signifies the start of a test. need to send this first because there needs to be a way to know when the document starts downloading.
    // If you just send the large document, there is no (accurate) starting time that can be determined from the other device.
    let mini_doc = json!({
        "test_type": "large_doc_start",
        "doc_type": "test",
        "sender": sender,
    });
    _ = coll.upsert(mini_doc);
    
    // Delay to make sure this doc is sent first
    delay_ms(250);

    let large_doc = json!({
        "test_type": "large_doc",
        "doc_type": "test",
        "doc_contents": contents,
        "number_sent": 100,
        "sender": sender,
    });
    _ = coll.upsert(large_doc);
}

// Test 3 - Sending an attachment and timing download speed
fn test_3_attachment(coll:Collection, sender:String) -> Result<DittoAttachmentToken, &'static str>{

    // Add attachment from disk (stored in root directory of this application)
    let attachment_file_path = "image2.jpeg".to_string();    
    let mut metadata = HashMap::new();
    metadata.insert("some".to_owned(), "string".to_owned());
    let attachment = coll.new_attachment(attachment_file_path, metadata).unwrap();
    // The attachment document
    let doc = json!({
        "test_type": "attachment",
        "doc_type": "test",
        "my_attachment": attachment,
        "sender": sender,
    });

    _  = coll.upsert(doc);

    // Make sure attachment was added to the local collection - this was an issue in the past
    let docs_found = coll.find("test_type == attachment").exec();
    
    // Return the attachment token
    return docs_found.map(|docs| {
        docs.first()
            .and_then(|d| d.get::<DittoAttachmentToken>("my_attachment").ok())
            .ok_or_else(|| "abcd")
    }).expect("No matching doc found");

}

// Attachment download handler
fn attachment_handler(att_token:DittoAttachmentToken, coll: Collection) -> Result<String, String>{
    println!("Running attachment fetcher");

    // Needed to download attachment
    let (tx, rx) = channel();
    let m_tx = std::sync::Mutex::new(tx);

    // Get start time
    let now = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_millis(); // See struct std::time::Duration methods
    let start_ms = now;

    // Fetch the attacment
    let _ = coll.fetch_attachment(att_token, move |fetch_event| 

        // Attachment download complete  
        if let DittoAttachmentFetchEvent::Completed { attachment } = fetch_event {        
            println!("Attachment downloaded");
            // Get end time
            let now = SystemTime::now()
                .duration_since(SystemTime::UNIX_EPOCH)
                .unwrap()
                .as_millis();
            // Calculate download time and speed
            let duration = now - start_ms;
            let kbs = get_file_size_kb("image2.jpeg".to_string()).unwrap() / duration as f32 * 1000.0;
            println!("Time taken: {} ms or {} KB/s", duration, kbs);
            let tx = m_tx.lock().unwrap();
            tx.send(attachment).unwrap();    
        } else if let DittoAttachmentFetchEvent::Progress { downloaded_bytes, total_bytes } = fetch_event {
            println!("Fetcher downloaded {} bytes out of {} bytes.", downloaded_bytes, total_bytes);
        } else if let DittoAttachmentFetchEvent::Deleted {} = fetch_event {
            println!("Attachment download deleted??");
        }
    ).unwrap();
    
    // Once all done, get the attachment to verify it exists and return an Ok or Err to confirm test success
    println!("Attachment fetcher done??");
    let fetched_attachment = rx.recv();
    if fetched_attachment.is_ok() {
        let fa = fetched_attachment.unwrap(); // may also use an async version or other sync strategy
        let attachment_file_path = fa.path();
        println!("{}", attachment_file_path.to_string_lossy());
        return Ok(attachment_file_path.to_string_lossy().to_string());
    } else {
        return Err("Issue with attachment".to_string());
    }
}

// Main continuous loop
fn pause(coll: Collection, 
    test_number:String, 
    send_pong:Arc<Mutex<bool>>, pong_ack:Arc<Mutex<bool>>, 
    att_token:Arc<Mutex<Option<DittoAttachmentToken>>>,
    id:Uuid, test_mode:String){

    let coll_mutex = Arc::new(Mutex::new(coll));

    let mut run_test_1 = false;
    let mut run_test_2 = false;
    let mut run_test_3 = false;

    let mut last_ping_ms = SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_millis();

    let mut stdout = io::stdout();
    // We want the cursor to stay at the end of the line, so we print without a newline and flush manually.
    write!(stdout, "Ping").unwrap();

    let mut test_started = false;

    // The loop
    loop {
        std::thread::sleep(Duration::from_millis(100));
        
        // For Test 3 attachment handler and send quit
        let coll_mutex2 = coll_mutex.clone();
        // For Start a test (send test docs)
        let coll_mutex3 = coll_mutex.clone();
        // For send ping
        let coll_mutex4 = coll_mutex.clone();

        // Get time
        let now_ms = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap()
            .as_millis(); // See struct std::time::Duration methods
        
        // 3.
        // Third step - send back a "PONG" or acknowledgement
        /* If we received a ping */
        if *send_pong.lock().unwrap() == true {
            let coll1 = coll_mutex.lock().unwrap();
            // Now we need to send an acknowledge back
            _ = coll1.clone().upsert(json!({
                "doc_type": "test",
                "test_type": "pong_ack_doc",
                "sender": id.to_string()
            }));
            *send_pong.lock().unwrap() = false;
        } 

        // Test 3
        if att_token.lock().unwrap().is_some() {
            println!("Attachment token exists, running handler..");
            let att_token = att_token.lock().unwrap().clone().unwrap();
            std::thread::sleep(Duration::from_millis(500));
            let coll2 = coll_mutex2.lock().unwrap().clone();
            let coll3 = coll_mutex2.lock().unwrap().clone();
            
            // Download the attachment, time the speed (KB/s) then get the success (Ok/Err)
            let result = attachment_handler(att_token, coll2);
            match result {
                Ok(_) => {
                    // Now quit!
                    print!("Quitting in 2 seconds..");
                    send_quit_doc(coll3, id.to_string());
                    delay_ms(2000);
                    exit(0);
                }
                Err(_) => { /* continue again.. */ }
            } 
        }
        // 5. - A test
        // Fifth step - Pong ack recevied, now to **start test**
        if *pong_ack.lock().unwrap() {
            let coll3 = coll_mutex3.lock().unwrap();
            println!("Now to run a test..");
            // Time to start the test!
            *pong_ack.lock().unwrap() = false;
            test_started = true;
            // Run test based on defined test number
            if test_number == "1" && !run_test_1{
                // Test 1 - documents per second
                test_1_docs_sec(coll3.clone(), id.to_string());
                run_test_1 = true;
            } else if test_number == "2" && !run_test_2 {
                // Test 2 - Large document
                test_2_large_doc(coll3.clone(), id.to_string());
                run_test_2 = true;
            } else if test_number == "3" &&! run_test_3 {
                // Test 3 - Attachment
                let att_token_result = test_3_attachment(coll3.clone(), id.to_string());
                if att_token_result.is_ok() {
                    println!("Attachment uploaded successfully.");
                }
                run_test_3 = true;
            } else if test_number == "1" && run_test_1 {
                println!("Can't run test 1 twice!");
            }
        }
        
        // 1. First step - 
        // If we're the sender, send out pings to star the test
        if test_mode == "sender" {
            let coll4 = coll_mutex4.lock().unwrap();
            // Every second send a ping document
            if now_ms - last_ping_ms >= 1000 && !test_started{
                write!(stdout, ".").unwrap();
                stdout.flush().unwrap();
                //print!(".");
                last_ping_ms = SystemTime::now()
                .duration_since(SystemTime::UNIX_EPOCH)
                .unwrap()
                .as_millis();
                let ping_doc = json!({
                    "doc_type": "test",
                    "test_type": "ping_doc",
                    "sender": id.to_string()
                });
                coll4.clone().upsert(ping_doc.clone()).unwrap();
            }
        }
    }
}