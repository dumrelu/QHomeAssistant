#ifndef HOMEASSISTANTAPI_H
#define HOMEASSISTANTAPI_H

#include <QObject>
#include <QVariant>
#include <QSet>
#include <QTimer>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class HomeAssistantApi : public QObject
{
    Q_OBJECT
public:
    explicit HomeAssistantApi(QObject *parent = nullptr);

    void trackState(QString entityId);

signals:
    void error(QString errorMessage);
    void stateChanged(QString entityId, QVariantMap state);

private:
    void checkForUpdates();
    void fetchState(QString entityId);

    void onError(QNetworkReply::NetworkError code);
    void onFinishedGetState();
    void onFinishedGetUpdates();

    QNetworkRequest request(QString url) const;
    void handleError(QNetworkReply* reply) const;

    QNetworkAccessManager m_manager;

    QString m_url;
    QByteArray m_token;

    QSet<QString> m_trackedEntities;
    QString m_trackedEntitiesString;
    QDateTime m_lastUpdateCheck = QDateTime::currentDateTimeUtc();
};

#endif // HOMEASSISTANTAPI_H
