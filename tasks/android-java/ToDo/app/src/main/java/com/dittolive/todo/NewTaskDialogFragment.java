package com.dittolive.todo;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import androidx.fragment.app.DialogFragment;

public class NewTaskDialogFragment extends DialogFragment {

    interface NewTaskDialogListener {
        void onDialogSave(DialogFragment dialogFragment, String task);
        void onDialogCancel(DialogFragment dialogFragment);
    }

    NewTaskDialogListener newTaskDialogListener = null;

    static NewTaskDialogFragment newInstance(int title) {
        NewTaskDialogFragment f = new NewTaskDialogFragment();
        Bundle args = new Bundle();
        args.putInt("dialog_title", title);
        f.setArguments(args);
        return f;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        int title = getArguments().getInt("dialog_title");
        final NewTaskDialogListener dialogListener = this.newTaskDialogListener;

        View dialogView = getActivity().getLayoutInflater().inflate(R.layout.dialog_new_task, null);
        final TextView task = dialogView.findViewById(R.id.editText);
        final DialogFragment dialogFragment = this;

        return new AlertDialog.Builder(getActivity())
            .setView(dialogView)
            .setTitle(title)
            .setPositiveButton(R.string.save,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        dialogListener.onDialogSave(dialogFragment, task.getText().toString());
                    }
                }
            )
            .setNegativeButton(android.R.string.cancel,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        dialogListener.onDialogCancel(dialogFragment);
                    }
                }
            )
            .create();
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            this.newTaskDialogListener = (NewTaskDialogListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement NewTaskDialogListener");
        }
    }

}
