#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QFile>

#include "QHomeAssistantPlugin.h"

QString read_file(QString filename)
{
    QFile file{ filename };
    if(!file.open(QFile::ReadOnly | QFile::Text))
    {
        qFatal("Could not read file");
        return {};
    }

    return file.readAll().trimmed();
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    QHomeAssistantPlugin::initialize(engine, )
    engine.load(url);

    return app.exec();
}
