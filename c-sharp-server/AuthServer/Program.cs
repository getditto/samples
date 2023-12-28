using System;
using System.Collections.Generic;
using DittoSDK;

namespace AuthServer {

    class App {
        static Ditto ditto;

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

            string sharedKey = "YOUR_SHARED_KEY";

            string license = "YOUR_OFFLINE_LICENSE_TOKEN";

            var serverIdentity = DittoIdentity.SharedKey(
                appId,
                sharedKey
            );
            ditto = new Ditto(serverIdentity);
            ditto.DisableSyncWithV3();
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
                Console.WriteLine("Ditto launched!");
                Console.WriteLine("Waiting for auth requests...");
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


            // This while loop is to keep the program running
            while (true) { }

        }
    }
}

