#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QFile>
#include <QFileInfo>
#include <QDir>

#include "QHomeAssistantPlugin.h"

#include "homeassistantapi.h"

QByteArray read_file(QString filename)
{
    QFile file{ filename };
    if(!file.open(QFile::ReadOnly | QFile::Text))
    {
        qFatal("Could not read file %s", filename.toStdString().c_str());
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

    QFileInfo currentSrcFile{__FILE__};
    auto exampleProjectDir = currentSrcFile.dir().absolutePath();

    auto haUrl = read_file(exampleProjectDir + "/url.txt");
    auto haToken = read_file(exampleProjectDir + "/token.txt");
    QHomeAssistantPlugin::initialize(engine, haUrl, haToken);

    HomeAssistantApi api;
    api.fetchState("light.lampa");
    QObject::connect(&api, &HomeAssistantApi::stateChanged, [](QString entityId, QVariantMap state)
    {
        qWarning() << "State changed: " << entityId;
    });

    engine.load(url);

    return app.exec();
}
