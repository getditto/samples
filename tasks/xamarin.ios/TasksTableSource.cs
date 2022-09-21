using System;
using System.Collections.Generic;
using Foundation;
using UIKit;
using DittoSDK;

namespace Tasks
{
	public class TasksTableSource : UITableViewSource
	{
        Task[] tasks;
        NSString cellIdentifier = new NSString("taskCell");
        private const string collectionName = "tasks";


        private DittoCollection collection
        {
            get
            {
                return this.ditto.Store.Collection(collectionName);
            }
        }

        private Ditto ditto
        {
            get
            {
                var appDelegate = (AppDelegate)UIApplication.SharedApplication.Delegate;
                return appDelegate.ditto;
            }
        }


        public TasksTableSource(Task[] taskList)
	{
            this.tasks = taskList;
	}

        public TasksTableSource()
        {
        }

        public override UITableViewCell GetCell(UITableView tableView, NSIndexPath indexPath)
        {
            UITableViewCell cell = tableView.DequeueReusableCell(cellIdentifier);
            if (cell == null)
            {
                cell = new UITableViewCell(UITableViewCellStyle.Default, cellIdentifier);
            }

            Task task = tasks[indexPath.Row];

            cell.TextLabel.Text = task.body;
            var taskComplete = task.isCompleted;
            if (taskComplete)
            {
                cell.Accessory = UITableViewCellAccessory.Checkmark;
            }
            else
            {
                cell.Accessory = UITableViewCellAccessory.None;

            }

            var tapGesture = new UITapGestureRecognizer();
            tapGesture.AddTarget(() =>
            {
                if (taskComplete)
                {
                    collection.FindById(task._id).Update(mutableDoc =>
                        mutableDoc["isCompleted"].Set(false)
                    ); 
                }
                else
                {
                    collection.FindById(task._id).Update(mutableDoc =>
                        mutableDoc["isCompleted"].Set(true)
                    );
                }
            });
            cell.AddGestureRecognizer(tapGesture);


            return cell;

        }

        public override nint RowsInSection(UITableView tableview, nint section)
        {
            if (this.tasks == null)
            {
                return 0;
            }
            return tasks.Length;
        }

        public void updateTasks(List<Task> tasks)
        {
            this.tasks = tasks.ToArray();
        }

        public override void CommitEditingStyle(UITableView tableView, UITableViewCellEditingStyle editingStyle, Foundation.NSIndexPath indexPath)
        {
            switch (editingStyle)
            {
                case UITableViewCellEditingStyle.Delete:

                    var task = tasks[indexPath.Row];
                    collection.FindById(task._id).Update((mutableDoc) => {
                        if (mutableDoc == null) return;
                        mutableDoc["isDeleted"].Set(true);
                    });
                    break;
                case UITableViewCellEditingStyle.None:
                    Console.WriteLine("CommitEditingStyle:None called");
                    break;
            }
        }

    }
}

