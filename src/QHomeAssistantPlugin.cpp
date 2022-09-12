#include "QHomeAssistantPlugin.h"

QString QHomeAssistantPlugin::g_url;
QString QHomeAssistantPlugin::g_token;

bool QHomeAssistantPlugin::initialize(QQmlEngine &engine, QString homeAssistantUrl, QString homeAssistantToken)
{
    g_url = homeAssistantUrl;
    g_token = homeAssistantToken;

    engine.addImportPath(":/");

    return true;
}
