// 1.
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

        public Task()
        {
        }

        // 3
        public Task(string _id, string body, bool isCompleted)
        {
            this._id = _id;
            this.body = body;
            this.isCompleted = isCompleted;
        }

        //public Task(string body, bool isCompleted)
        //{
        //    this._id = Guid.NewGuid().ToString();
        //    this.body = body;
        //    this.isCompleted = isCompleted;
        //}

        //public Task(DittoDocument document)
        //{
        //    this._id = document["_id"].StringValue;
        //    this.body = document["body"].StringValue;
        //    this.isCompleted = document["isCompleted"].BooleanValue;
        //}

        //// 4.
        //public override string ToString()
        //{
        //    return $"Task _id: {_id}, body: {body}, isCompleted: {isCompleted}";
        //}

        //// 5.
        ///
        public Dictionary<string, object> ToDictionary()
        {
            return new Dictionary<string, object>
            {
                { "_id", _id },
                { "body", body },
                { "isCompleted", isCompleted },
            };
        }

    }
}