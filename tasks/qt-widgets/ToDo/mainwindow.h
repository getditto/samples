#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QDateTime>
#include <QInputDialog>
#include <QListWidgetItem>
#include <QMainWindow>

#include "DittoSyncKit.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

public slots:
    void addTask();
    void removeSelected();

    void addTaskToList(QString text, bool isComplete, QString id);
    void removeTaskFromList(int index);
    void updateTaskInList(int index, bool isComplete);
    void moveTaskInList(ditto::LiveQueryMove move);

    void onTasksListWidgetItemChanged(QListWidgetItem *changed);
    void onTasksListWidgetItemSelectionChanged();

signals:
    void taskInserted(QString text, bool isComplete, QString id);
    void taskDeleted(int index);
    void taskUpdated(int index, bool isComplete);
    void taskMoved(ditto::LiveQueryMove move);

private:
    Ui::MainWindow *ui;
    ditto::DittoSyncKit ditto;
    std::shared_ptr<ditto::LiveQuery> live_query;
};
#endif // MAINWINDOW_H
