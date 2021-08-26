package live.ditto.compose.tasks.edit

import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Devices
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun EditForm(
    canDelete: Boolean,
    body: String,
    onBodyTextChange: ((body: String) -> Unit)? = null,
    isCompleted: Boolean = false,
    onIsCompletedChanged: ((isCompleted: Boolean) -> Unit)? = null,
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
            Switch(checked = isCompleted, onCheckedChange = { onIsCompletedChanged?.invoke(it) })
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
    device = Devices.PIXEL_3
)
@Composable
fun EditFormPreview() {
    EditForm(canDelete = true, "Hello")
}