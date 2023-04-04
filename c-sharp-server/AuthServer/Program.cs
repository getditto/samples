using System;
using System.Collections.Generic;
using DittoSDK;

namespace AuthServer {

    class App {
        static Ditto ditto;
        static bool isAskedToExit = false;
        static List<Task> tasks = new List<Task>();
        static DittoLiveQuery liveQuery;

        public static void Main(string[] args) {
            string appId = "f87f6d8c-1b51-46e2-83d6-d97825ebab71";
            string verifyingKey = @"-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEZwBd0bKcMhXud4WmLdbtjtxQ+8sp
H3SxusTpRz0UdsYg2I+jquAld4An7IiSXNaP2OfLupT7FSI+It7xyQBDXQ==
-----END PUBLIC KEY-----";

            string signingKey = @"-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg2tQ5+0saaChUaraW
ufsn3SiJc+wIIfvKDgarINP9yVahRANCAARnAF3RspwyFe53haYt1u2O3FD7yykf
dLG6xOlHPRR2xiDYj6Oq4CV3gCfsiJJc1o/Y58u6lPsVIj4i3vHJAENd
-----END PRIVATE KEY-----";

            string sharedKey = "YOUR_SHARED_KEY_HERE";

            string license = "YOUR_LICENSE_HERE";

            var serverIdentity = DittoIdentity.SharedKey(
                appId,
                sharedKey
            );
            ditto = new Ditto(serverIdentity);
            ditto.DeviceName = "TestServer";

            // Server is an HTTP/WebSocket server only
            var serverConfig = new DittoTransportConfig();
            serverConfig.Listen.Http.Enabled = true;
            serverConfig.Listen.Http.InterfaceIp = "127.0.0.1";
            serverConfig.Listen.Http.Port = 45002;
            serverConfig.Listen.Http.WebsocketSync = true;
            serverConfig.Listen.Http.IdentityProvider = true;
            /* Optional: for HTTPS
            serverConfig.Listen.Http.TlsKeyPath = "";
            serverConfig.Listen.Http.TlsCertificatePath = "";
            */
            serverConfig.Listen.Http.IdentityProviderSigningKey = signingKey;
            serverConfig.Listen.Http.IdentityProviderVerifyingKeys.Add(verifyingKey);
            ditto.TransportConfig = serverConfig;

            try
            {
                ditto.SetOfflineOnlyLicenseToken(license);
                ditto.StartSync();
            }
            catch (DittoException ex)
            {
                Console.WriteLine("There was an error starting Ditto.");
                Console.WriteLine("Here's the following error");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("Ditto cannot start sync but don't worry.");
                Console.WriteLine("Ditto will still work as a local database.");
            }

            // Handle any incoming authentication requests
            ditto.DittoIdentityProviderAuthenticationRequest += (sender, args) =>
            {
                Console.WriteLine("\nGot Request: ");
                Console.WriteLine(args.ThirdPartyToken);
                Console.WriteLine(args.AppId);
                if (args.AppId == appId && args.ThirdPartyToken == "jellybeans")
                {
                    var success = new DittoAuthenticationSuccess();
                    success.AccessExpires = DateTime.Now + new TimeSpan(1, 0, 0);
                    success.UserId = "bob";
                    success.ReadEverythingPermission = true;
                    success.WriteEverythingPermission = true;
                    Console.WriteLine("Sign in success!");
                    args.Allow(success);
                }
                else
                {
                    args.Deny();
                }
            };

            Console.WriteLine("Welcome to Ditto's Task App");

            liveQuery = ditto.Store["tasks"].FindAll().ObserveLocal((docs, _event) => {

                Console.WriteLine("Got new tasks");
                tasks = docs.ConvertAll(d => new Task(d));
            });

            ListCommands();

            while (!isAskedToExit)
            {

                Console.Write("\nYour command: ");
                string command = Console.ReadLine();

                switch (command)
                {

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

