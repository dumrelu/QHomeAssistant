#include "QHomeAssistantPlugin.h"

#include "homeassistantimageprovider.h"

QString QHomeAssistantPlugin::g_url;
QByteArray QHomeAssistantPlugin::g_token;

bool QHomeAssistantPlugin::initialize(QQmlEngine &engine, QString homeAssistantUrl, QByteArray homeAssistantToken)
{
    g_url = homeAssistantUrl;
    g_token = homeAssistantToken;

    engine.addImportPath(":/");
    engine.addImageProvider("mdi", new HomeAssistantImageProvider);

    return true;
}
