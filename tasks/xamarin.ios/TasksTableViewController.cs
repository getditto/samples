using System;

using Foundation;
using UIKit;
using DittoSDK;
using System.Collections.Generic;

namespace Tasks
{
	public partial class TasksTableViewController : UITableViewController
	{
		private const string collectionName = "tasks";
		private DittoLiveQuery liveQuery;
		List<Task> tasks = new List<Task>();
		private TasksTableSource tasksTableSource = new TasksTableSource();

		private Ditto ditto
		{
			get
			{
				var appDelegate = (AppDelegate)UIApplication.SharedApplication.Delegate;
				return appDelegate.ditto;
			}
		}

		private DittoCollection collection
		{
			get
			{
				return this.ditto.Store.Collection(collectionName);
			}
		}

		public TasksTableViewController(IntPtr handle) : base(handle)
		{
		}

		public override void ViewDidLoad()
		{
			base.ViewDidLoad();

			setupTaskList();

		}

		public override void ViewWillAppear(bool animated)
		{
			base.ViewWillAppear(animated);

			TableView.Source = tasksTableSource;
		}

		public void setupTaskList()
		{
			liveQuery = ditto.Store["tasks"].FindAll().Observe((docs, _event) =>
			{
				updateMessages(docs.ToArray());
			});
		}

		public void updateMessages(DittoDocument[] docs)
		{
			if (tasks != null)
			{
				tasks.Clear();
			}

            foreach (var doc in docs)
            {
                doc.Value.TryGetValue("_id", out var id);
                doc.Value.TryGetValue("body", out var body);
                doc.Value.TryGetValue("isCompleted", out var isCompleted);


                var newTask = new Task { _id = id.ToString(), body = body.ToString(), isCompleted = (bool)isCompleted };

                tasks.Add(newTask);
            }

            tasksTableSource.updateTasks(tasks);

            InvokeOnMainThread(() =>
            {
                TableView.ReloadData();
            });
        }

		partial void didClickAddTask(UIBarButtonItem sender)
		{
			// Create an alert
			var alertControl = UIAlertController.Create(
				title: "Add New Task",
				message: null,
				preferredStyle: UIAlertControllerStyle.Alert);

			// Add a text field to the alert for the new task text
			alertControl.AddTextField(configurationHandler: (UITextField obj) => obj.Placeholder = "Enter Task");

			alertControl.AddAction(UIAlertAction.Create(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: null));

			// Add a "OK" button to the alert.
			alertControl.AddAction(UIAlertAction.Create(title: "OK", style: UIAlertActionStyle.Default, alarm => addTask(alertControl.TextFields[0].Text)));

			// Present the alert to the user
			PresentViewController(alertControl, animated: true, null);
		}

		public void addTask(string text)
        {

			var dict = new Dictionary<string, object>
			{
				{"body", text},
				{"isCompleted", false}
			};

			var docId = this.collection.Insert(dict);

            var docs = this.collection.FindAll().Exec();
			List<string> myArray = new List<string>();
            foreach (var doc in docs)
            {
				var id = doc["_id"].StringValue;
				myArray.Add(id);
				
            }
			myArray.Sort();

        }


	}
}
