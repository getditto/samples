package live.ditto.compose.tasks.list

import androidx.compose.foundation.layout.Column
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rxjava3.subscribeAsState
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.tooling.preview.Devices
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import live.ditto.DittoDocumentID
import live.ditto.compose.tasks.R
import live.ditto.compose.tasks.data.Task
import live.ditto.compose.tasks.TaskRow
import live.ditto.compose.tasks.TasksApplication
import live.ditto.compose.tasks.asObservable
import live.ditto.compose.tasks.ui.theme.TasksJetpackComposeTheme
import java.util.*

class TaskListViewModel : ViewModel() {
    val tasks = TasksApplication.ditto!!.store["tasks"]
        .findAll().asObservable().map { docs -> docs.map { Task(it) } }

    fun toggle(taskId: String) {
        TasksApplication.ditto!!.store["tasks"]
            .findByID(DittoDocumentID(taskId))
            .update { mutableDoc ->
                val mutableDoc = mutableDoc?.let { it } ?: return@update
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].booleanValue)
            }
    }

}

@Composable
fun TasksListScreen(navController: NavController) {

    val scaffoldState = rememberScaffoldState()

    val tasksListViewModel: TaskListViewModel = viewModel();
    val tasks: List<Task> by tasksListViewModel.tasks.subscribeAsState(initial = emptyList())

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Tasks Jetpack Compose") },
                backgroundColor = colorResource(id = R.color.purple_700)
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                icon = { Icon(Icons.Filled.Add, "") },
                text = { Text(text = "New Task") },
                onClick = { navController.navigate("tasks/edit") },
                elevation = FloatingActionButtonDefaults.elevation(8.dp)
            )
        },
        floatingActionButtonPosition = FabPosition.End,
        scaffoldState = scaffoldState,
        content = {
            TasksList(
                tasks = tasks,
                onToggle = { tasksListViewModel.toggle(it) },
                onSelectedTask = {
                    navController.navigate("tasks/edit/${it}")
                }
            )
        }
    )
}

@Composable
fun TasksList(
    tasks: List<Task>,
    onToggle: ((taskId: String) -> Unit)? = null,
    onSelectedTask: ((taskId: String) -> Unit)? = null
) {
    Column() {
        tasks.forEach { task ->
            TaskRow(
                task = task,
                onClickBody = { onSelectedTask?.invoke(it._id) },
                onToggleButton = { onToggle?.invoke(it._id) }
            )
        }
    }
}

@Preview(
    showBackground = true,
    showSystemUi = true,
    device = Devices.PIXEL_3
)
@Composable
fun DefaultPreview() {
    TasksJetpackComposeTheme {
        TasksList(
            tasks = listOf(
                Task(UUID.randomUUID().toString(), "Get Milk", true),
                Task(UUID.randomUUID().toString(), "Get Oats", false),
                Task(UUID.randomUUID().toString(), "Get Berries", true),
            )
        )
    }
}