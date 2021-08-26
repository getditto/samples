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
import androidx.compose.runtime.setValue;
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import live.ditto.DittoDocument
import live.ditto.DittoDocumentID
import live.ditto.compose.tasks.R
import live.ditto.compose.tasks.TasksApplication
import live.ditto.compose.tasks.data.Task
import live.ditto.compose.tasks.list.TasksList

class EditScreenViewModel: ViewModel() {

    var _id: String? = null;

    var body = MutableLiveData<String>("")
    var isCompleted = MutableLiveData<Boolean>(false)
    var canDelete = MutableLiveData<Boolean>(false)

    fun setupWithTask(taskId: String?) {
        canDelete.value = taskId != null
        val taskId: String = taskId?.let { it } ?: return;
        val doc: DittoDocument = TasksApplication.ditto!!.store["tasks"]
            .findByID(DittoDocumentID(taskId))
            .exec()?.let { it } ?: return;
        val task = Task(doc)
        _id = task._id
        body.value = task.body
        isCompleted.value = task.isCompleted

    }

    fun save() {
        if (_id == null) {
            // save
            TasksApplication.ditto!!.store["tasks"]
                .insert(mapOf(
                    "body" to body.value,
                    "isCompleted" to isCompleted.value
                ))
        } else {
            // update
            TasksApplication.ditto!!.store["tasks"].findByID(DittoDocumentID(_id!!))
                .update { mutableDoc ->
                    val mutableDoc = mutableDoc?.let { it } ?: return@update
                    mutableDoc["body"].set(body.value ?: "")
                    mutableDoc["isCompleted"].set(isCompleted.value ?: "")
                }
        }
    }

    fun delete() {
        TasksApplication.ditto!!.store["tasks"].findByID(DittoDocumentID(_id!!))
            .remove()
    }
}

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
                isComplete = isCompleted,
                onIsComplete = { editScreenViewModel.isCompleted.value = it },
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

@Composable
fun EditForm(
    canDelete: Boolean,
    body: String,
    onBodyTextChange: ((body: String) -> Unit)? = null,
    isComplete: Boolean = false,
    onIsComplete: ((isCompleted: Boolean) -> Unit)? = null,
    onSaveButtonClicked: (() -> Unit)? = null,
    onDeleteButtonClicked: (() -> Unit)? = null,
) {
    Column(modifier = Modifier.padding(16.dp)) {
        Text(text = "Body:")
        TextField(
            value = body,
            onValueChange = { onBodyTextChange?.invoke(it) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp)
        )
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            Arrangement.SpaceBetween
        ) {
            Text(text = "Is Complete:")
            Switch(checked = isComplete, onCheckedChange = { onIsComplete?.invoke(it) })
        }
        Button(
            onClick = {
                onSaveButtonClicked?.invoke()
            },
            modifier = Modifier
                .padding(bottom = 12.dp)
                .fillMaxWidth(),
        ) {
            Text(
                text = "Save",
                modifier = Modifier.padding(8.dp)
            )
        }
        if (canDelete) {
            Button(
                onClick = {
                    onDeleteButtonClicked?.invoke()
                },
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = Color.Red,
                    contentColor = Color.White),
                modifier = Modifier
                    .fillMaxWidth(),
            ) {
                Text(
                    text = "Delete",
                    modifier = Modifier.padding(8.dp)
                )
            }
        }
    }
}

@Preview(
    showBackground = true,
    showSystemUi = true,
    device = Devices.PIXEL_3
)
@Composable
fun EditFormPreview() {
    EditForm(canDelete = true, "Hello")
}