#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , ditto(ditto::DittoSyncKit())
{
    ui->setupUi(this);

    this->setStyleSheet("QPushButton { color: rgb(47, 114, 180); border: none; }" \
                        "QPushButton:disabled { color: rgb(129, 176, 222); }" \
                        "QListWidget { border:none; }" \
                        "QWidget { background-color: white; }");

    ui->tasksListWidget->setSelectionMode(QListWidget::SelectionMode::SingleSelection);
    ui->removeSelectedButton->setEnabled(false);

    connect(ui->addTaskButton, &QPushButton::clicked, this, &MainWindow::addTask);
    connect(ui->removeSelectedButton, &QPushButton::clicked, this, &MainWindow::removeSelected);
    connect(ui->tasksListWidget, &QListWidget::itemChanged, this, &MainWindow::onTasksListWidgetItemChanged);
    connect(ui->tasksListWidget, &QListWidget::itemSelectionChanged, this, &MainWindow::onTasksListWidgetItemSelectionChanged);

    connect(this, &MainWindow::taskInserted, this, &MainWindow::addTaskToList, Qt::QueuedConnection);
    connect(this, &MainWindow::taskDeleted, this, &MainWindow::removeTaskFromList, Qt::QueuedConnection);
    connect(this, &MainWindow::taskUpdated, this, &MainWindow::updateTaskInList, Qt::QueuedConnection);
    connect(this, &MainWindow::taskMoved, this, &MainWindow::moveTaskInList, Qt::QueuedConnection);

    ditto.set_access_license("<INSERT ACCESS LICENSE>");
    ditto.start();
    ditto::Collection collection = ditto.get_store()->collection("tasks");

    live_query = collection.find_all().sort("dateCreated", true).observe(ditto::LiveQueryEventHandler{
        [collection, this](std::vector<ditto::Document> docs, ditto::LiveQueryEvent event) {
            if (event.is_initial) {
                for (auto &doc: docs) {
                    std::string text = doc.value()["text"];
                    bool isComplete = doc.value()["isComplete"];
                    emit taskInserted(QString::fromStdString(text), isComplete, QString::fromStdString(doc.id().to_string()));
                }
                return;
            }

            for (auto idx: event.deletions) {
                emit taskDeleted(int(idx));
            }

            for (auto move: event.moves) {
                emit taskMoved(move);
            }

            for (auto idx: event.insertions) {
                ditto::Document &doc = docs[idx];
                std::string text = doc.value()["text"];
                bool isComplete = doc.value()["isComplete"];
                emit taskInserted(QString::fromStdString(text), isComplete, QString::fromStdString(doc.id().to_string()));
            }

            for (auto idx: event.updates) {
                ditto::Document &doc = docs[idx];
                bool isComplete = doc.value()["isComplete"];
                emit taskUpdated(int(idx), isComplete);
            }
         }});
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::addTaskToList(QString text, bool isComplete, QString id) {
    this->ui->tasksListWidget->addItem(text);
    QListWidgetItem *item = this->ui->tasksListWidget->item(this->ui->tasksListWidget->count() - 1);
    item->setSizeHint(QSize(0, 40));
    item->setData(Qt::UserRole, QVariant(id));
    item->setFlags(item->flags() | Qt::ItemIsUserCheckable);
    if (isComplete) {
        item->setCheckState(Qt::Checked);
    } else {
        item->setCheckState(Qt::Unchecked);
    }
}

void MainWindow::removeTaskFromList(int index) {
    this->ui->tasksListWidget->takeItem(index);
}

void MainWindow::updateTaskInList(int index, bool isComplete) {
    QListWidgetItem *item = this->ui->tasksListWidget->item(index);
    if (isComplete) {
        item->setCheckState(Qt::Checked);
    } else {
        item->setCheckState(Qt::Unchecked);
    }
}

void MainWindow::moveTaskInList(ditto::LiveQueryMove move) {
    QListWidgetItem *item = this->ui->tasksListWidget->takeItem(int(move.from));
    this->ui->tasksListWidget->insertItem(int(move.to), item);
}

void MainWindow::addTask() {
    bool ok;
    QString text = QInputDialog::getText(this, tr("Add task"), "", QLineEdit::Normal, tr("A task"), &ok);
    if (ok && !text.isEmpty()) {
        auto dateStr = QDateTime::currentDateTimeUtc().toString("yyyy-MM-dd hh:mm:ss.zzz");
        ditto::DocumentId docID = ditto.get_store()->collection("tasks").insert({
            {"dateCreated", dateStr.toStdString()},
            {"isComplete", false},
            {"text", text.toStdString()}
        });
    }
}

void MainWindow::removeSelected() {
    auto selectedItems = this->ui->tasksListWidget->selectedItems();
    int selectedSize = selectedItems.size();
    if (selectedSize != 1) { return; }
    QListWidgetItem *selected = selectedItems.first();
    std::string taskId = selected->data(Qt::UserRole).toString().toStdString();
    ditto.get_store()->collection("tasks").find_by_id(taskId).remove();
}

void MainWindow::onTasksListWidgetItemChanged(QListWidgetItem *changed) {
    std::string taskId = changed->data(Qt::UserRole).toString().toStdString();
    bool taskComplete = changed->checkState();
    ditto.get_store()->collection("tasks").find_by_id(taskId).update([taskComplete](ditto::MutableDocument &doc) {
        doc["isComplete"].set(taskComplete);
    });
}

void MainWindow::onTasksListWidgetItemSelectionChanged() {
    bool enabled = this->ui->tasksListWidget->selectedItems().size() == 1;
    this->ui->removeSelectedButton->setEnabled(enabled);
}
