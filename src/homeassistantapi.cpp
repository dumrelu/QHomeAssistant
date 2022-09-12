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
}

void HomeAssistantApi::startPolling()
{
    auto* timer = new QTimer{ this };
    connect(timer, &QTimer::timeout, this, &HomeAssistantApi::fetchStates);
    timer->start(1000); //TODO: configurable and ensure called only once
}

void HomeAssistantApi::fetchStates()
{
    qDebug() << __FUNCTION__;
    if(m_getStatesReply)
    {
        qWarning() << "fetchStates already in progress";
        return;
    }

    auto request = prepareRequest(m_url + "/api/states");

    m_getStatesReply = m_manager.get(request);
    prepareReply(m_getStatesReply);
    connect(m_getStatesReply, &QNetworkReply::readyRead, this,
        [this]()
        {
            m_statesData.append(m_getStatesReply->readAll());
        }
    );
    connect(m_getStatesReply, &QNetworkReply::finished, this, &HomeAssistantApi::onFinishedGetStates);
}

void HomeAssistantApi::callService(QString service, QString entityId, QVariantMap data)
{
    qDebug() << __FUNCTION__ << "(" << service << ", " << entityId << ", " << data << ")";

    if(!service.contains("."))
    {
        qWarning() << "Invalid service";
        return;
    }

    auto json = QJsonObject::fromVariantMap(data);
    json["entity_id"] = entityId;

    auto request = prepareRequest(m_url + "/api/services/" + service.replace(".", "/"));


    auto* reply = m_manager.post(request, QJsonDocument{ json }.toJson(QJsonDocument::Compact));
    prepareReply(reply);
    connect(reply, &QNetworkReply::finished, reply, &QObject::deleteLater);
}

void HomeAssistantApi::onError(QNetworkReply::NetworkError code)
{
    qWarning() << "Network error: " << code;
    emit error("Network error. TBD");
}

void HomeAssistantApi::onFinishedGetStates()
{
    if(!m_getStatesReply)
    {
        qWarning() << "Invalid call";
        return;
    }

    if(m_getStatesReply->error() != QNetworkReply::NoError)
    {
        qWarning() << "Reply network error";
        return;
    }

    auto json = QJsonDocument::fromJson(m_statesData);
    if(json.isArray())
    {
        emit statesReceived(json.array());
    }

    m_statesData.clear();
    m_getStatesReply->deleteLater();
    m_getStatesReply = nullptr;
}

QNetworkRequest HomeAssistantApi::prepareRequest(QString url) const
{
    QNetworkRequest request;
    request.setUrl(QUrl{ url });
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader(QByteArrayLiteral("Authorization"), QByteArray{"Bearer "} +  m_token);

    return request;
}

void HomeAssistantApi::prepareReply(QNetworkReply *reply) const
{
    reply->setReadBufferSize(0);
#if QT_VERSION < QT_VERSION_CHECK(5,15,0)
    connect(reply, qOverload<QNetworkReply::NetworkError>(&QNetworkReply::error), this, &HomeAssistantApi::onError);
#else
    connect(reply, &QNetworkReply::errorOccurred, this, &HomeAssistantApi::onError);
#endif
}
