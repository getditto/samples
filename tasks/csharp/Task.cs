using System;
using System.Collections.Generic;
using DittoSDK;

namespace Tasks
{
    public struct Task
    {
        string _id;
        string body;
        bool isCompleted;
        bool isDeleted;

        public Task(string _id, string body, bool isCompleted, bool isDeleted)
        {
            this._id = _id;
            this.body = body;
            this.isCompleted = isCompleted;
            this.isDeleted = isDeleted;
        }

        public Task(string body, bool isCompleted)
        {
            this._id = Guid.NewGuid().ToString();
            this.body = body;
            this.isCompleted = isCompleted;
            this.isDeleted = false;
        }

        public Task(DittoDocument document)
        {
            this._id = document["_id"].StringValue;
            this.body = document["body"].StringValue;
            this.isCompleted = document["isCompleted"].BooleanValue;
            this.isDeleted = document["isDeleted"].BooleanValue;
        }

        public override string ToString()
        {
            return $"Task _id: {_id}, body: {body}, isCompleted: {isCompleted}, isDeleted: {isDeleted}";
        }

        public Dictionary<string, object> ToDictionary()
        {
            return new Dictionary<string, object>
            {
                { "_id", _id },
                { "body", body },
                { "isCompleted", isCompleted },
                { "isDeleted", isDeleted },
            };
        }
    }
}
