# Rust SDK Example

To run use the following command:
`cargo run -- --app-id [App ID] --shared-token [Shared Token] --collection [Collection]`

The App ID and shared token can be found in the portal for your application.  The collection is some arbitrary 
collection name.  The utility will connect to the Big Peer, read the initial state and subscribe to all changes.