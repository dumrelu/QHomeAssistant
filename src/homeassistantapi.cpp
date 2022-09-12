#include "../include/homeassistantapi.h"

#include "QHomeAssistantPlugin.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

HomeAssistantApi::HomeAssistantApi(QObject *parent)
    : QObject{parent}
    , m_url{ QHomeAssistantPlugin::g_url }
    , m_token{ QHomeAssistantPlugin::g_token }
{
    checkForUpdates();

    auto* timer = new QTimer{ this };
    connect(timer, &QTimer::timeout, this, &HomeAssistantApi::checkForUpdates);
    timer->start(1000); //TODO: configurable
}

void HomeAssistantApi::trackState(QString entityId)
{
    if(!m_trackedEntities.contains(entityId))
    {
        m_trackedEntities.insert(entityId);
        m_trackedEntitiesString = QStringList{ m_trackedEntities.values() }.join(",");

        fetchState(entityId);
    }
}

void HomeAssistantApi::checkForUpdates()
{
    if(m_trackedEntities.size() == 0)
    {
        return;
    }

    auto req = request(m_url + "/api/history/period/"
                       + m_lastUpdateCheck.toString(Qt::ISODate)
                       + "?minimal_response&no_attributes&significant_changes_only&filter_entity_id="
                       + m_trackedEntitiesString);
    m_lastUpdateCheck = QDateTime::currentDateTimeUtc();

    auto* reply = m_manager.get(req);
    handleError(reply);
    reply->setReadBufferSize(0);
    connect(reply, &QNetworkReply::finished, this, &HomeAssistantApi::onFinishedGetUpdates);
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

void HomeAssistantApi::onFinishedGetUpdates()
{
    auto* reply = qobject_cast<QNetworkReply*>(sender());
    if(!reply)
    {
        qWarning() << "Invalid cast for reply";
        return;
    }

    qWarning() << __PRETTY_FUNCTION__;

    auto json = QJsonDocument::fromJson(reply->readAll());
//    qWarning() << json.toJson(QJsonDocument::Compact).toStdString().c_str();
    if(json.isArray())
    {
        auto array = json.array();
        for(auto element : array)
        {
            if(element.isArray())
            {
                auto elementArray = element.toArray();

                if(elementArray.size() > 1)
                {
                    auto object = element.toArray()[0].toObject();
                    auto entityId = object["entity_id"].toString();

                    if(m_trackedEntities.contains(entityId))
                    {
                        fetchState(entityId);
                    }
                }
            }
        }
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
