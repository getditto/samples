package live.ditto.compose.tasks.list

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import live.ditto.DittoDocumentID
import live.ditto.compose.tasks.TasksApplication
import live.ditto.compose.tasks.data.Task

class TasksListScreenViewModel: ViewModel() {
    val tasks: MutableLiveData<List<Task>> = MutableLiveData(emptyList())

    val liveQuery = TasksApplication.ditto!!.store["tasks"]
        .findAll().observe { docs, _ ->
            tasks.postValue(docs.map { Task(it) })
        }

    fun toggle(taskId: String) {
        TasksApplication.ditto!!.store["tasks"]
            .findByID(DittoDocumentID(taskId))
            .update { mutableDoc ->
                val mutableDoc = mutableDoc?.let { it } ?: return@update
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].booleanValue)
            }
    }

    override fun onCleared() {
        super.onCleared()
        liveQuery.stop()
    }
}