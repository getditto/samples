using System;
using System.Collections.Generic;
using System.Text.Json;

namespace Program
{
    public struct Task
    {
        public string _id { get; set; }
        public string body { get; set; }
        public bool isCompleted { get; set; }
        public bool isDeleted { get; set; }

        public static Task JsonToTask(string jsonString)
        {
            return JsonSerializer.Deserialize<Task>(jsonString);
        }

        public Task(string body, bool isCompleted)
        {
            this._id = Guid.NewGuid().ToString();
            this.body = body;
            this.isCompleted = isCompleted;
            this.isDeleted = false;
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
