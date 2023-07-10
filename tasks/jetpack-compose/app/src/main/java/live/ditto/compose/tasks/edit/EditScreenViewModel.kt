package live.ditto.compose.tasks.edit

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import live.ditto.DittoDocument
import live.ditto.DittoDocumentId
import live.ditto.compose.tasks.DittoHandler.Companion.ditto
import live.ditto.compose.tasks.data.Task

class EditScreenViewModel: ViewModel() {

    private var _id: String? = null

    var body = MutableLiveData<String>("")
    var isCompleted = MutableLiveData<Boolean>(false)
    var canDelete = MutableLiveData<Boolean>(false)

    fun setupWithTask(id: String?) {
        canDelete.postValue(id != null)
        val taskId: String = id ?: return;
        val doc: DittoDocument = ditto.store["tasks"]
            .findById(DittoDocumentId(taskId))
            .exec() ?: return;
        val task = Task(doc)
        _id = task._id
        body.postValue(task.body)
        isCompleted.postValue(task.isCompleted)

    }

    fun save() {
        if (_id == null) {
            // save
            ditto.store.collection("tasks")
                .upsert(mapOf(
                    "body" to body.value,
                    "isCompleted" to isCompleted.value,
                    "isDeleted" to false
                ))
        } else {
            // update
            _id?.let { id ->
                ditto.store.collection("tasks").findById(DittoDocumentId(id))
                    .update { dittoDocument ->
                        val mutableDoc = dittoDocument ?: return@update
                        mutableDoc["body"].set(body.value ?: "")
                        mutableDoc["isCompleted"].set(isCompleted.value ?: "")
                    }
            }

        }
    }

    // 4.
    fun delete() {
        _id?.let { ditto.store.collection("tasks").findById(it).remove() }
    }
}