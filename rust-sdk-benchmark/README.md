# Ditto Pi Test
A single rust program to test bluetooth and LAN download speed between two Linux / Raspberry Pi devices using the ditto Rust library.

## Usage
Run with:
`cargo run <transport> <test_num> <sender/receiver> <optional args>`
Parameters:  
* Transport: `bt` / `client` (wifi client) / `server` (wifi listen server)
* Test num: `1`, `2`, `3`
* Sender/receiver: `sender` (sends documents), `receiver` (receives documents)  

## Behaviour:
### Sender
The sender will attempt to look for another device to send the test document to by sending periodic "ping" documents.  
Once a client receives a ping, it sends back a "pong" (acknowledge) document. The sender gets that document, then starts the specified test.  
The data will be sent from sender to receiver, then the speed results displayed on the receiver device.  
After the test has finished sending the document(s) successfully, the program self-terminates.

### Receiver
The receiver listens for "ping" documents. Once it receives a ping document, it sends back an "pong" (acknolwedge) document. The sender will then start the test by sending test documents.  
The receiver receives the documents, and stores the start and end time to calculate the end speed.
Once the test document(s) have been received, the receiver then self-terminates with results displayed.


## Tests
### 1 - Documents per second
This will send 100 small documents to the other device, the other device will time it and report the speed values (documents per second and millisseconds per document).
It uses a vector to keep count of documents, and pops an item from the vector array to ensure the count is exact.
### 2 - Large document test
This test sends one large document, which contains the text in `doc_contents.txt` (64KB), read in from filesystem. 
### 3 - Attachment test
This test sends a document with an attachment, the file `image2.jpeg` (20KB). The receiver runs an attachment handler which can calculate the time taken for the whole attachment to download.  

## Code Description
The code has two main parts, the initial setup in `main()`, and the continuous running loop, `pause()`.  
In the initial setup:
* Sets up ditto with transports passed in by command line
* Sets the test type from command line arg
* Sets up Arc Mutex variables that send signals to the live loop when certain documents come in
* Creates a handler for new/updated/deleted documents. This is a closure that captures the docs and the event details.
* Sets up the handler in `observe_local` and also creates a subscription to listen to new items from other devices (important to add this as well for device to device communciation).

The document event handler:
* Listens for `speedtest_1_doc` for speed 1 documents and counts the documents. Once documents == 100, display results and quit.
* Listens for `start_test` - signals the start of a documents/sec test
* Listens for `end_test` - signals the end of the test (not used?)
* Listens for `ping_doc` - the "ping" document which another device sends out to alert other devices of it's presence
* Listens for `large_doc_start` - The document before a large document. With a small delay, it then starts timing the large document download speed.
* Listens for `large_doc` - The large document. Test 2. Once it's downloaded, the speed can be calculated, then the program quits.
* Listens for `attachment` - A document with attachment. It will get the attachment token, then in the live `puase()` loop it will download the attachment and time it, then quit.
* Listens for `pong_ack_doc` - Acknowledgement from another device, to signal the start of a test. In the live `pause()` loop, it will then send out the test documents.
* Listens for `quit` - It will then quit the program

In the live `pause()` loop:  
* Sends a ping document out to other devices
* Responds to documents, as notified by the Arc Mutex variables set up in the initial setup in main.
* Starts the tests when signalled to (from event handler above)