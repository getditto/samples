package live.ditto.compose.tasks

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import live.ditto.compose.tasks.ui.theme.TasksJetpackComposeTheme
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import live.ditto.DittoError
import live.ditto.compose.tasks.edit.EditScreen
import live.ditto.compose.tasks.list.TasksListScreen
import java.util.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val ditto = TasksApplication.ditto
        try {
            ditto!!.setLicenseToken("<REPLACE_ME>")
            ditto!!.tryStartSync()
        } catch (e: DittoError) {
            Toast.makeText(
                this@MainActivity,
                """
                    Uh oh! There was an error trying to start Ditto's sync feature.
                    That's okay, it will still work as a local database.
                    This is the error: ${e.localizedMessage}
                """.trimIndent(), Toast.LENGTH_LONG
            ).show()
        }

        setContent {
            Root()
        }
    }
}

@Composable
fun Root() {
    val navController = rememberNavController()

    TasksJetpackComposeTheme {
        // A surface container using the 'background' color from the theme
        Surface(color = MaterialTheme.colors.background) {
            NavHost(navController = navController, startDestination = "tasks") {
                composable("tasks") { TasksListScreen(navController = navController) }
                composable("tasks/edit") {
                    EditScreen(navController = navController, taskId = null)
                }
                composable("tasks/edit/{taskId}") { backStackEntry ->
                    val taskId: String? = backStackEntry.arguments?.getString("taskId")
                    EditScreen(navController = navController, taskId = taskId)
                }
            }
        }
    }
}

