package live.ditto.compose.tasks

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import live.ditto.compose.tasks.data.Task
import java.util.*

/**
 * Represents a row of tasks
 */
@Composable
fun TaskRow(
    task: Task,
    onToggle: ((task: Task) -> Unit)? = null,
    onClickBody: ((task: Task) -> Unit)? = null) {

    val iconId =
        if (task.isCompleted) R.drawable.ic_baseline_circle_24 else R.drawable.ic_outline_circle_24
    val color = if (task.isCompleted) R.color.blue_200 else R.color.gray
    val textDecoration = if (task.isCompleted) TextDecoration.LineThrough else
        TextDecoration.None
    Row(
        Modifier
            .fillMaxWidth()
            .padding(12.dp)

    ) {
        Image(
            ImageVector.vectorResource(
                id = iconId
            ),
            "Localized description",
            colorFilter = ColorFilter.tint(colorResource(id = color)),
            modifier = Modifier
                .padding(end = 16.dp)
                .size(24.dp, 24.dp)
                .clickable { onToggle?.invoke(task) },
            alignment = Alignment.CenterEnd
        )
        Text(
            text = task.body,
            textDecoration = textDecoration,
            fontSize = 16.sp,
            modifier = Modifier
                .alignByBaseline()
                .fillMaxWidth()
                .clickable { onClickBody?.invoke(task) })
    }
}

@Preview(showBackground = true)
@Composable
fun TaskRowPreview() {
    Column() {
        TaskRow(task = Task(UUID.randomUUID().toString(), "Get Milk", true))
        TaskRow(task = Task(UUID.randomUUID().toString(), "Do Homework", false))
        TaskRow(task = Task(UUID.randomUUID().toString(), "Take out trash", true))
    }
}