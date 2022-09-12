#include "../include/homeassistantapi.h"

#include "QHomeAssistantPlugin.h"

#include <QJsonDocument>
#include <QJsonObject>

HomeAssistantApi::HomeAssistantApi(QObject *parent)
    : QObject{parent}
    , m_url{ QHomeAssistantPlugin::g_url }
    , m_token{ QHomeAssistantPlugin::g_token }
{
}

void HomeAssistantApi::trackState(QString entityId)
{
    if(!m_trackedStates.contains(entityId))
    {
        m_trackedStates.insert(entityId);

        fetchState(entityId);
    }
}

void HomeAssistantApi::fetchState(QString entityId)
{
    auto req = request(m_url + "/api/states/" + entityId);

    auto* reply = m_manager.get(req);
    handleError(reply);
    connect(reply, &QNetworkReply::finished, this, &HomeAssistantApi::onFinishedGetState);
}

void HomeAssistantApi::onError(QNetworkReply::NetworkError code)
{
    qWarning() << "Network error: " << code;
    emit error("Network error. TBD");
}

void HomeAssistantApi::onFinishedGetState()
{
    auto* reply = qobject_cast<QNetworkReply*>(sender());
    if(!reply)
    {
        qWarning() << "Invalid cast for reply";
        return;
    }

    auto json = QJsonDocument::fromJson(reply->readAll());
    if(json.isObject())
    {
        auto state = json.object().toVariantMap();
        auto entityId = state["entity_id"].toString();

        emit stateChanged(entityId, state);
    }
    else
    {
        qWarning() << "Could not parse json";
    }
}

QNetworkRequest HomeAssistantApi::request(QString url) const
{
    QNetworkRequest request;
    request.setUrl(QUrl{ url });
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader(QByteArrayLiteral("Authorization"), QByteArray{"Bearer "} +  m_token);

    return request;
}

void HomeAssistantApi::handleError(QNetworkReply *reply) const
{
#if QT_VERSION < QT_VERSION_CHECK(5,15,0)
    connect(reply, qOverload<QNetworkReply::NetworkError>(&QNetworkReply::error), this, &HomeAssistantApi::onError);
#else
    connect(reply, &QNetworkReply::errorOccurred, this, &HomeAssistantApi::onError);
#endif
}
