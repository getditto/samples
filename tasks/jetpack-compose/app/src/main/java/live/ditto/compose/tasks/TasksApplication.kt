package live.ditto.compose.tasks

import android.app.Application
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.DittoLogLevel
import live.ditto.DittoLogger
import live.ditto.android.DefaultAndroidDittoDependencies
import live.ditto.compose.tasks.DittoHandler.Companion.ditto


class TasksApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        setupDitto()
    }

    private fun setupDitto() {
        val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
        // Create an instance of Ditto
       ditto = Ditto(androidDependencies, DittoIdentity.OnlinePlayground(
            androidDependencies,
            BuildConfig.DITTO_APP_ID,
            BuildConfig.DITTO_LICENSE_TOKEN,
            enableDittoCloudSync = true)
        )

        DittoLogger.minimumLogLevel = DittoLogLevel.DEBUG

        // Disable sync with V3
        ditto.disableSyncWithV3()
    }

}