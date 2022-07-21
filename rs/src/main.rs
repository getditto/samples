use dittolive_ditto::{identity::*, prelude::*};
use std::{self, sync::Arc};

fn main() -> Result<(), DittoError> {
    let ditto = Ditto::builder()
        // creates a `ditto_data` folder in the directory containing the executing process
        .with_root(Arc::new(PersistentRoot::from_current_exe()?))
        .with_identity(|ditto_root| {
                // Provided as an env var, may also be provided as hardcoded string
                let app_id = AppId::from_env("REPLACE_ME_WITH_YOUR_APP_ID")?;
                let shared_token = std::env::var("REPLACE_ME_WITH_A_SHARED_TOKEN").unwrap();
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


    ditto.start_sync();
    let store = ditto.store();
    let collection = store.collection("people").unwrap();

    Ok(())
}
