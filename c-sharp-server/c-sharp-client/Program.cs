using System;
using System.Collections.Generic;
using DittoSDK;

class AuthDelegate : IDittoAuthenticationDelegate
{
    public async void AuthenticationRequired(DittoAuthenticator authenticator)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"\nAuth required!! → try \"--login jellybeans\"");
        Console.ResetColor();
    }

    public async void AuthenticationExpiringSoon(DittoAuthenticator authenticator, long secondsRemaining)
    {
        Console.WriteLine($"Auth token expiring in {secondsRemaining} seconds");
    }
}

namespace Program {

    class App {
        static Ditto ditto;

        static IDisposable dittoAuthObserver;
        static DittoSubscription subscription;
        static DittoLiveQuery liveQuery;
        static List<Task> tasks;
        static Boolean isAskedToExit = false;

        public static async System.Threading.Tasks.Task Main(params string[] args) {
            var appId = "f87f6d8c-1b51-46e2-83d6-d97825ebab71";
            var identity = DittoIdentity.OnlineWithAuthentication(
                appId,
                new AuthDelegate(),
                false,
                "http://127.0.0.1:45002");

            ditto = new Ditto(identity);
            ditto.Auth.Logout();
            DittoTransportConfig transportConfig = new DittoTransportConfig();
            transportConfig.Connect.WebsocketUrls.Add("ws://127.0.0.1:45002");
            ditto.TransportConfig = transportConfig;
            ditto.StartSync();

            dittoAuthObserver = ditto.Auth.ObserveStatus((status) => {
                if (status.IsAuthenticated) {
                    Console.WriteLine($"\nAuth success!");
                } else {
                    Console.WriteLine($"\nAuth required!! → try \"--login jellybeans\"");
                }
            });

            subscription = ditto.Store["tasks"].FindAll().Subscribe();
            Console.WriteLine("\nWelcome to Ditto's Task App");

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
                        await ditto.Auth.LoginWithToken(password, "provider");
                        break;

                    case String s when command.StartsWith("--logout"):
                        ditto.Auth.Logout();
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
                        ditto.Auth.Logout();
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
            Console.WriteLine("   Example: \"--login jellybeans\"");
            Console.WriteLine("--logout");
            Console.WriteLine("   Logout from Ditto auth");
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