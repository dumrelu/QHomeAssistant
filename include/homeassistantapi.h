#ifndef HOMEASSISTANTAPI_H
#define HOMEASSISTANTAPI_H

#include <QObject>
#include <QVariant>
#include <QSet>
#include <QTimer>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QJsonArray>
#include <QJsonObject>

class HomeAssistantApi : public QObject
{
    Q_OBJECT
public:
    explicit HomeAssistantApi(QObject *parent = nullptr);

    void startPolling();
    void fetchStates();

    void callService(QString service, QString entityId, QVariantMap data);

signals:
    void error(QString errorMessage);
    void statesReceived(QJsonArray stateArray);

private:
    void onError(QNetworkReply::NetworkError code);
    void onFinishedGetStates();

    QNetworkRequest prepareRequest(QString url) const;
    void prepareReply(QNetworkReply* reply) const;

    QNetworkAccessManager m_manager;

    QString m_url;
    QByteArray m_token;

    QNetworkReply* m_getStatesReply = nullptr;
    QByteArray m_statesData;
};

#endif // HOMEASSISTANTAPI_H
