package live.ditto.compose.tasks.list

import androidx.compose.foundation.layout.Column
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.tooling.preview.Devices
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import live.ditto.compose.tasks.R
import live.ditto.compose.tasks.data.Task
import live.ditto.compose.tasks.TaskRow
import java.util.*


@Composable
fun TasksListScreen(navController: NavController) {
    val tasksListViewModel: TasksListScreenViewModel = viewModel();
    val tasks: List<Task> by tasksListViewModel.tasks.observeAsState(emptyList())

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
        content = {
            TasksList(
                tasks = tasks,
                onToggle = { tasksListViewModel.toggle(it) },
                onClickBody = {
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
    onClickBody: ((taskId: String) -> Unit)? = null
) {
    Column() {
        tasks.forEach { task ->
            TaskRow(
                task = task,
                onClickBody = { onClickBody?.invoke(it._id) },
                onToggle = { onToggle?.invoke(it._id) }
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
fun TasksListPreview() {
    TasksList(
        tasks = listOf(
            Task(UUID.randomUUID().toString(), "Get Milk", true),
            Task(UUID.randomUUID().toString(), "Get Oats", false),
            Task(UUID.randomUUID().toString(), "Get Berries", true),
        )
    )
}