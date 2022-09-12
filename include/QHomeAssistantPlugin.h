#pragma once

#include <QString>
#include <QQmlEngine>

class QHomeAssistantPlugin {
public:
    static bool initialize(QQmlEngine& engine, QString homeAssistantUrl, QString homeAssistantToken);

    static QString g_url;
    static QString g_token;
};
