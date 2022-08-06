using System;
using System.Collections.Generic;
using DittoSDK;

namespace Tasks
{
    public class Task
    {
        public string _id;
        public string body;
        public bool isCompleted;

        public Task(DittoDocument document)
        {
            this._id = document["_id"].StringValue;
            this.body = document["body"].StringValue;
            this.isCompleted = document["isCompleted"].BooleanValue;
        }
    }
}
