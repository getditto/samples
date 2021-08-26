package live.ditto.compose.tasks.edit

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.tooling.preview.Devices
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.runtime.getValue;
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import live.ditto.compose.tasks.R

@Composable
fun EditScreen(navController: NavController, taskId: String?) {
    val editScreenViewModel: EditScreenViewModel = viewModel();
    editScreenViewModel.setupWithTask(taskId = taskId)

    val scaffoldState = rememberScaffoldState()
    val topBarTitle = if (taskId == null) "New Task" else "Edit Task"

    val body: String by editScreenViewModel.body.observeAsState("")
    val isCompleted: Boolean by editScreenViewModel.isCompleted.observeAsState(initial = false)
    val canDelete: Boolean by editScreenViewModel.canDelete.observeAsState(initial = false)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(topBarTitle) },
                backgroundColor = colorResource(id = R.color.purple_700)
            )
        },
        scaffoldState = scaffoldState,
        content = {
            EditForm(
                canDelete = canDelete,
                body = body,
                onBodyTextChange = { editScreenViewModel.body.value = it },
                isCompleted = isCompleted,
                onIsCompletedChanged = { editScreenViewModel.isCompleted.value = it },
                onSaveButtonClicked = {
                    editScreenViewModel.save()
                    navController.popBackStack()
                },
                onDeleteButtonClicked = {
                    editScreenViewModel.delete()
                    navController.popBackStack()
                }
            )
        }
    )
}

