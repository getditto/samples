package live.ditto.dittotesting

import android.content.Context
import live.ditto.Ditto
import live.ditto.DittoDependencies
import live.ditto.DittoIdentity
import java.io.File


fun clearUpDirectory(directory: File) {
    directory.deleteRecursively()
}
@JvmOverloads
fun clearUpDittoDirectories(context: Context, customDir: String? = null) {
    val dittoDir = if (customDir == null) File(context.filesDir, "ditto") else File(customDir)
    clearUpDirectory(dittoDir)
}

@JvmOverloads
fun getDitto(
    dependencies: DittoDependencies,
    identity: DittoIdentity = DittoIdentity.OnlinePlayground(
        dependencies,
        // Get these values from https://portal.ditto.live
        "YOUR_APP_ID",
        "YOUR_PLAYGROUND_TOKEN",
        false
    ),
): Ditto {
    val ditto = Ditto(dependencies, identity)
    ditto.disableSyncWithV3()
    return ditto
}