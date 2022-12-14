#ifndef HOMEASSISTANTIMPL_H
#define HOMEASSISTANTIMPL_H

#include <QObject>
#include <QQmlPropertyMap>
#include <QDateTime>

#include "homeassistantapi.h"

class HomeAssistantImpl : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlPropertyMap* states READ states NOTIFY statesChanged)

    Q_PROPERTY(bool isQt5 READ isQt5 CONSTANT)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY isLoadedChanged)
    Q_PROPERTY(int secondsSinceLastUpdate READ secondsSinceLastUpdate NOTIFY secondsSinceLastUpdateChanged)
public:
    explicit HomeAssistantImpl(QObject *parent = nullptr);

    QQmlPropertyMap* states();
    bool isQt5() const;
    bool isLoaded() const;
    int secondsSinceLastUpdate() const;

    Q_INVOKABLE void callService(QString service, QString entityId, QVariantMap data);
    Q_INVOKABLE void updateLocalState(QString entityId, QString state);
    Q_INVOKABLE void updateLocalAttr(QString entityId, QString attributeName, QVariant value);

signals:
    void statesChanged();
    void isLoadedChanged();
    void secondsSinceLastUpdateChanged();

private:
    void onStatesReceived(QJsonArray stateArray);
    void onError(QString errorMessage);

    bool m_isLoaded = false;

    QDateTime m_lastUpdateTime;
    int m_secondsSinceLastUpdate = -1;


    HomeAssistantApi m_api;
    QQmlPropertyMap m_states;

    // After updating the local state, ignore a certain number of
    //updates to give HA a chance to update its states.
    int m_numberOfUpdatesToIgnore = 2;
    QHash<QString, int> m_localStateOverrides;
};

#endif // HOMEASSISTANTIMPL_H
