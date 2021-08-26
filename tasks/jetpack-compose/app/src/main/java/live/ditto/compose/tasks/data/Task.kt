package live.ditto.compose.tasks.data

import live.ditto.DittoDocument
import java.util.*

data class Task(
    val _id: String = UUID.randomUUID().toString(),
    val body: String,
    val isCompleted: Boolean
) {
    constructor(document: DittoDocument) : this(
        document["_id"].stringValue,
        document["body"].stringValue,
        document["isCompleted"].booleanValue
    ) {

    }

    fun toMap(): Map<String, Any> {
        return mapOf(
            "_id" to _id,
            "body" to body,
            "isCompleted" to isCompleted
        )
    }
}
