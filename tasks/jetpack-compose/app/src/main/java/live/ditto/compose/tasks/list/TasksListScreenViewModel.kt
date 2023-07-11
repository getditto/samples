package live.ditto.compose.tasks.list

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import live.ditto.DittoDocumentId
import live.ditto.compose.tasks.DittoHandler.Companion.ditto
import live.ditto.compose.tasks.data.Task

class TasksListScreenViewModel: ViewModel() {
    val tasks: MutableLiveData<List<Task>> = MutableLiveData(emptyList())

    private val subscription = ditto.store.collection("tasks")
        .find("!isDeleted").subscribe()
    private val liveQuery = ditto.store["tasks"]
        .find("!isDeleted").observeLocal { docs, _ ->
            tasks.postValue(docs.map { Task(it) })
        }

    fun toggle(taskId: String) {
        ditto.store.collection("tasks")
            .findById(DittoDocumentId(taskId))
            .update { dittoDocument ->
                val mutableDoc = dittoDocument ?: return@update
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].booleanValue)
            }
    }

    override fun onCleared() {
        super.onCleared()
        liveQuery.close()
        subscription.close()
    }
}