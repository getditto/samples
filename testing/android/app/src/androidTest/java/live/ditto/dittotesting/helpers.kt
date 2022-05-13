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

const val testLicense = "YOUR_LICENSE_HERE"

@JvmOverloads
fun getDitto(
    dependencies: DittoDependencies,
    identity: DittoIdentity = DittoIdentity.OfflinePlayground(dependencies),
    offlineLicense: String? = testLicense,
): Ditto {
    val ditto = Ditto(dependencies, identity)
    offlineLicense?.let {
        ditto.setOfflineOnlyLicenseToken(it)
    }
    return ditto
}