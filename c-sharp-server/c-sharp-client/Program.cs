using System;
using System.Collections.Generic;
using DittoSDK;

class AuthDelegate : IDittoAuthenticationDelegate
{
    public async void AuthenticationRequired(DittoAuthenticator authenticator)
    {
        System.Console.WriteLine($"Login request");
    }

    public async void AuthenticationExpiringSoon(DittoAuthenticator authenticator, long secondsRemaining)
    {
        System.Console.WriteLine($"Auth token expiring in {secondsRemaining} seconds");
    }
}

namespace Program {

    class App {
        static Ditto ditto;
        static DittoSubscription subscription;
        static DittoLiveQuery liveQuery;
        static List<Task> tasks;
        static Boolean isAskedToExit = false;

        public static void Main(string[] args) {
            System.Console.WriteLine("HELLO");
            var appId = "f87f6d8c-1b51-46e2-83d6-d97825ebab71";
            DittoLogger.SetMinimumLogLevel(DittoLogLevel.Debug);
            var identity = DittoIdentity.OnlineWithAuthentication(
                appId,
                new AuthDelegate(),
                false,
                "http://127.0.0.1:45002");

            ditto = new Ditto(identity);
            DittoTransportConfig transportConfig = new DittoTransportConfig();
            transportConfig.Connect.WebsocketUrls.Add("ws://127.0.0.1:45002");
            ditto.TransportConfig = transportConfig;
            ditto.StartSync();

            subscription = ditto.Store["tasks"].FindAll().Subscribe();
            Console.WriteLine("Welcome to Ditto's Task App");

            liveQuery = ditto.Store["tasks"].FindAll().ObserveLocal((docs, _event) => {
                tasks = docs.ConvertAll(d => new Task(d));
            });

            ListCommands();

            while (!isAskedToExit)
            {

                Console.Write("\nYour command: ");
                string command = Console.ReadLine();

                switch (command)
                {

                    case String s when command.StartsWith("--login"):
                        // the password is jellybeans
                        string password = s.Replace("--login ", "");
                        var res = ditto.Auth.LoginWithToken(password, "provider");
                        break;
                    case string s when command.StartsWith("--insert"):
                        string taskBody = s.Replace("--insert ", "");
                        ditto.Store["tasks"].Upsert(new Task(taskBody, false).ToDictionary());
                        break;
                    case string s when command.StartsWith("--toggle"):
                        string _idToToggle = s.Replace("--toggle ", "");
                        ditto.Store["tasks"]
                            .FindById(new DittoDocumentId(_idToToggle))
                            .Update((mutableDoc) => {
                                if (mutableDoc == null) return;
                                mutableDoc["isCompleted"].Set(!mutableDoc["isCompleted"].BooleanValue);
                            });
                        break;
                    case string s when command.StartsWith("--delete"):
                        string _idToDelete = s.Replace("--delete ", "");
                        ditto.Store["tasks"]
                            .FindById(new DittoDocumentId(_idToDelete))
                            .Remove();
                        break;
                    case { } when command.StartsWith("--list"):
                        tasks.ForEach(task =>
                        {
                            Console.WriteLine(task.ToString());
                        });
                        break;
                    case { } when command.StartsWith("--exit"):
                        Console.WriteLine("Good bye!");
                        isAskedToExit = true;
                        break;
                    default:
                        Console.WriteLine("Unknown command");
                        ListCommands();
                        break;
                }
            }
        }

        public static void ListCommands()
        {
            Console.WriteLine("************* Commands *************");
            Console.WriteLine("--login jellybeans");
            Console.WriteLine("   Logs in with a given password");
            Console.WriteLine("   Example: \"--insert jellybeans\"");
            Console.WriteLine("--insert my new task");
            Console.WriteLine("   Inserts a task");
            Console.WriteLine("   Example: \"--insert Get Milk\"");
            Console.WriteLine("--toggle myTaskTd");
            Console.WriteLine("   Toggles the isComplete property to the opposite value");
            Console.WriteLine("   Example: \"--toggle 1234abc\"");
            Console.WriteLine("--delete myTaskTd");
            Console.WriteLine("   Deletes a task");
            Console.WriteLine("   Example: \"--delete 1234abc\"");
            Console.WriteLine("--list");
            Console.WriteLine("   List the current tasks");
            Console.WriteLine("--exit");
            Console.WriteLine("   Exits the program");
            Console.WriteLine("************* Commands *************");
        }
    }
}