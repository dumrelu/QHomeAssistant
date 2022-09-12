#pragma once

#include <QString>
#include <QQmlEngine>

class QHomeAssistantPlugin {
public:
    static bool initialize(QQmlEngine& engine, QString homeAssistantUrl, QByteArray homeAssistantToken);

    static QString g_url;
    static QByteArray g_token;
};
