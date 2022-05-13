package live.ditto.dittotesting

import live.ditto.android.*
import android.content.Context
import java.io.File

/**
 * Implementation of `AndroidDittoDependencies` which uses a custom `persistenceDirectory`.
 */
data class CustomDirectoryAndroidDittoDependencies constructor(
    private val androidDittoDependencies: DefaultAndroidDittoDependencies,
    private val customDir: File
): AndroidDittoDependencies {

    override fun persistenceDirectory(): String {
        return customDir.path
    }

    override fun ensureDirectoryExists(path: String) {
        androidDittoDependencies.ensureDirectoryExists(path)
    }

    override fun context(): Context {
        return androidDittoDependencies.context()
    }

}
