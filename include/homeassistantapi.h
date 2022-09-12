#ifndef HOMEASSISTANTAPI_H
#define HOMEASSISTANTAPI_H

#include <QObject>
#include <QVariant>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class HomeAssistantApi : public QObject
{
    Q_OBJECT
public:
    explicit HomeAssistantApi(QObject *parent = nullptr);

    void fetchState(QString entityId);

signals:
    void error(QString errorMessage);
    void stateChanged(QString entityId, QVariantMap state);

private:
    void onError(QNetworkReply::NetworkError code);
    void onFinishedGetState();

    QNetworkRequest request(QString url) const;
    void handleError(QNetworkReply* reply) const;

    QNetworkAccessManager m_manager;

    QString m_url;
    QByteArray m_token;
};

#endif // HOMEASSISTANTAPI_H
