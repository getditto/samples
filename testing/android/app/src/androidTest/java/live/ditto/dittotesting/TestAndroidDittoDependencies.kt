package live.ditto.android

import android.content.Context
import java.io.File
import java.util.UUID

/**
 * Provides a default set of dependencies that you can pass to the [live.ditto.Ditto] initializer
 * when running unit tests.
 *
 * `TestAndroidDittoDependencies` differs from `DefaultAndroidDittoDependencies` in that
 * this test class will use a random and unique directory for each instantiation.
 */
class TestAndroidDittoDependencies(
    context: Context,
) : AndroidDittoDependencies {
    private val randomDir: String = UUID.randomUUID().toString()
    private val androidDittoDependencies: DefaultAndroidDittoDependencies = DefaultAndroidDittoDependencies(context)

    override fun persistenceDirectory(): String {
        // We use "ditto" as a stable root dir so that `clearUpDittoDirectories`
        // has a well-known path to recursively test.
        val dittoDir = File(androidDittoDependencies.context().filesDir, "ditto")

        // Each ditto instance which uses this context will use a random dir
        // inside "ditto" as a persistence directory. This allows multiple
        // ditto instances to run simultaneously without clobbering each other's
        // storage.
        val filesDir = File(dittoDir, randomDir)
        filesDir.mkdirs()

        return filesDir.path
    }

    override fun ensureDirectoryExists(path: String) {
        androidDittoDependencies.ensureDirectoryExists(path)
    }

    override fun context(): Context {
        return androidDittoDependencies.context()
    }
}
