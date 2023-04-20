package live.ditto.compose.tasks

import android.app.Application
import android.util.Log
import live.ditto.Ditto
import live.ditto.DittoError
import live.ditto.DittoIdentity
import live.ditto.android.AndroidDittoDependencies
import live.ditto.android.DefaultAndroidDittoDependencies


class TasksApplication : Application() {

    companion object {
        var ditto: Ditto? = null
    }

    override fun onCreate() {
        super.onCreate()
        val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
        val identity = DittoIdentity.OnlinePlayground(
            androidDependencies,
            "4e3a7eec-123a-4059-813c-d79dca75844b",
            token = "3ea21de0-1304-4810-a2b6-ba4a568f0c7a"
        )
        val ditto = Ditto(androidDependencies, identity)
        ditto.startSync()
    }

}