#include <format>
#include <iostream>
#include <string>
#include <string_view>
#include "Ditto.h"

using namespace std;
using namespace ditto;
using nlohmann::json;

class Task
{
public:
    string _id;
    string body;
    bool isCompleted;

    Task(string body, bool isCompleted) : body(body), isCompleted(isCompleted) {}
    Task(string _id, string body, bool isCompleted) : _id(_id), body(body), isCompleted(isCompleted) {}
    Task(Document &document)
    {
        _id = document["_id"].get_string_value();
        body = document["body"].get_string_value();
        isCompleted = document["isCompleted"].get_bool_value();
    }
};

vector<Task> tasks;
bool isAskingToExit = false;

void listCommands()
{
    cout << "Welcome to Ditto tasks as a C++ command line application \n";
    cout << "Here are some commands \n";
    cout << "************ \n";
    cout << "--list\n";
    cout << "--exit\n";
    cout << "************ \n";
}

int main()
{
    std::cout << "\nWelcome to Ditto Tasks for C++\n";

    Ditto ditto;
    auto identity =
        Identity::OnlinePlayground("REPLACE_ME_WITH_YOUR_APP_ID",
                                   "REPLACE_ME_WITH_YOUR_PLAYGROUND_TOKEN", true);
    try
    {

        ditto = Ditto(identity);
        ditto.set_minimum_log_level(LogLevel::debug);
        ditto.start_sync();
    }
    catch (const DittoError &err)
    {
        // handle exception
    }


    ditto.get_store().collection("tasks").find_all()
            .observe_local([&](std::vector<Document> docs, LiveQueryEvent event) {
            // transform the vector of docs into the vector<Task>
            std::transform(docs.begin(), docs.end(), std::back_inserter(tasks),
                           [](Document &doc) -> Task
                           { return Task(doc); });
        });

    while (!isAskingToExit)
    {
        listCommands();

        string command;
        cout << "Your command:";
        getline(cin, command);

        if (command.find("--list") == 0)
        {
            for (auto &task : tasks)
            {
                // process tasks
            }
        }

        if (command.find("--exit") == 0)
        {
            cout << "Exiting the app. Thank you for playing! \n";
            return 0;
        }
    }

    return 0;
}
