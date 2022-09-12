#ifndef HOMEASSISTANTIMPL_H
#define HOMEASSISTANTIMPL_H

#include <QObject>
#include <QQmlPropertyMap>

#include "homeassistantapi.h"

class HomeAssistantImpl : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlPropertyMap* states READ states NOTIFY statesChanged)
public:
    explicit HomeAssistantImpl(QObject *parent = nullptr);

    QQmlPropertyMap* states();

    Q_INVOKABLE void callService(QString service, QString entityId, QVariantMap data);

signals:
    void statesChanged();

private:
    void onStatesReceived(QJsonArray stateArray);
    void onError(QString errorMessage);

    HomeAssistantApi m_api;
    QQmlPropertyMap m_states;
};

#endif // HOMEASSISTANTIMPL_H
