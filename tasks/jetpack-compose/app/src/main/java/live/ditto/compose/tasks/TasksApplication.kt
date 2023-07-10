package live.ditto.compose.tasks

import android.app.Application
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.android.DefaultAndroidDittoDependencies


class TasksApplication: Application() {

    companion object {
        var ditto: Ditto? = null
    }

    override fun onCreate() {
        super.onCreate()
        val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
        val identity = DittoIdentity.OfflinePlayground(androidDependencies, "YOUR_APP_ID")
        ditto = Ditto(androidDependencies, identity)
    }

}