package live.ditto.compose.tasks

import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import live.ditto.compose.tasks.edit.EditScreen
import live.ditto.compose.tasks.list.TasksListScreen
import live.ditto.compose.tasks.ui.theme.TasksJetpackComposeTheme

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