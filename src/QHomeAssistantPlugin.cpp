#include "QHomeAssistantPlugin.h"

#include "homeassistantimageprovider.h"
#include "homeassistantimpl.h"

QString QHomeAssistantPlugin::g_url;
QByteArray QHomeAssistantPlugin::g_token;

bool QHomeAssistantPlugin::initialize(QQmlEngine &engine, QString homeAssistantUrl, QByteArray homeAssistantToken)
{
    g_url = homeAssistantUrl;
    g_token = homeAssistantToken;

    qmlRegisterType<HomeAssistantImpl>("QHomeAssistant", 1, 0, "HomeAssistantImpl");

    engine.addImportPath(":/");
    engine.addImageProvider("mdi", new HomeAssistantImageProvider);

    return true;
}
