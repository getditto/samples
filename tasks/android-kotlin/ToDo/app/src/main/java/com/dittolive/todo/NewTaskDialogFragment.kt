package com.dittolive.todo

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import android.widget.TextView
import androidx.fragment.app.DialogFragment
import live.dittolive.todo.R

class NewTaskDialogFragment: DialogFragment() {



    interface NewTaskDialogListener {
        fun onDialogSave(dialog: DialogFragment, task: String)
        fun onDialogCancel(dialog: DialogFragment)
    }

    var newTaskDialogListener: NewTaskDialogListener? = null

    companion object {
        fun newInstance(): NewTaskDialogFragment {
            val newTaskDialogFragment = NewTaskDialogFragment()
            val args = Bundle()
            newTaskDialogFragment.arguments = args
            return newTaskDialogFragment
        }
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog { // 5
        val title = "Add New Task"
        val builder = AlertDialog.Builder(activity)
        builder.setTitle(title)

        val dialogView = activity?.layoutInflater?.inflate(R.layout.dialog_new_task, null)
        val task = dialogView?.findViewById<TextView>(R.id.editText)

        builder.setView(dialogView)
            .setPositiveButton(R.string.save) { _, _ -> newTaskDialogListener?.onDialogSave(this, task?.text.toString()) }
            .setNegativeButton(android.R.string.cancel) { _, _ -> newTaskDialogListener?.onDialogCancel(this) }
        return builder.create()
    }

    @Deprecated("Deprecated in Java")
    @Suppress("DEPRECATION")
    override fun onAttach(activity: Activity) { // 6
        super.onAttach(activity)
        try {
            newTaskDialogListener = activity as NewTaskDialogListener
        } catch (e: ClassCastException) {
            throw ClassCastException("$activity must implement NewTaskDialogListener")
        }
    }
}
