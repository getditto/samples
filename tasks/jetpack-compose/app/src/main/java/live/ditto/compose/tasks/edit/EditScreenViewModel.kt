package live.ditto.compose.tasks.edit

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import live.ditto.DittoDocument
import live.ditto.DittoDocumentId
import live.ditto.compose.tasks.TasksApplication
import live.ditto.compose.tasks.data.Task

class EditScreenViewModel: ViewModel() {

    var _id: String? = null;

    var body = MutableLiveData<String>("")
    var isCompleted = MutableLiveData<Boolean>(false)
    var canDelete = MutableLiveData<Boolean>(false)

    fun setupWithTask(taskId: String?) {
        canDelete.postValue(taskId != null)
        val taskId: String = taskId?.let { it } ?: return;
        val doc: DittoDocument = TasksApplication.ditto?.store?.get("tasks")
            ?.findById(DittoDocumentId(taskId))
            ?.exec()?.let { it } ?: return;
        val task = Task(doc)
        _id = task._id
        body.postValue(task.body)
        isCompleted.postValue(task.isCompleted)

    }

    fun save() {
        if (_id == null) {
            // save
            TasksApplication.ditto?.store?.get("tasks")
                ?.upsert(mapOf(
                    "body" to body.value,
                    "isCompleted" to isCompleted.value
                ))
        } else {
            // update
            _id?.let { _id ->
                TasksApplication.ditto?.store?.get("tasks")?.findById(DittoDocumentId(_id))
                    ?.update { dittoDocument ->
                        val mutableDoc = dittoDocument ?: return@update
                        mutableDoc["body"].set(body.value ?: "")
                        mutableDoc["isCompleted"].set(isCompleted.value ?: "")
                    }
            }

        }
    }

    // 4.
    fun delete() {
        TasksApplication.ditto?.store?.get("tasks")?.upsert(mapOf(
            "_id" to _id,
            "isDeleted" to true
        ))
    }
}