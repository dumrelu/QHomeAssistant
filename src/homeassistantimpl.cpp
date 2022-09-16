#include "../include/homeassistantimpl.h"

HomeAssistantImpl::HomeAssistantImpl(QObject *parent)
    : QObject{parent}
{
    connect(&m_api, &HomeAssistantApi::statesReceived, this, &HomeAssistantImpl::onStatesReceived);

    m_api.fetchStates();
    m_api.startPolling();
}

QQmlPropertyMap *HomeAssistantImpl::states()
{
    return &m_states;
}

bool HomeAssistantImpl::isQt5() const
{
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    return false;
#endif
    return true;
}

bool HomeAssistantImpl::isLoaded() const
{
    return m_isLoaded;
}

void HomeAssistantImpl::callService(QString service, QString entityId, QVariantMap data)
{
    m_api.callService(service, entityId, data);
}

void HomeAssistantImpl::updateLocalState(QString entityId, QString state)
{
    if(m_states.contains(entityId))
    {
        auto currentState = m_states.value(entityId).toJsonObject();
        currentState["state"] = state;
        m_states.insert(entityId, currentState);

        m_localStateOverrides[entityId] = m_numberOfUpdatesToIgnore;

        m_api.startPolling();
    }
}

void HomeAssistantImpl::updateLocalAttr(QString entityId, QString attributeName, QVariant value)
{
    if(m_states.contains(entityId))
    {
        auto currentState = m_states.value(entityId).toJsonObject();
        auto attributes = currentState["attributes"].toObject();
        attributes[attributeName] = QJsonValue::fromVariant(value);
        currentState["attributes"] = attributes;
        m_states.insert(entityId, currentState);

        m_localStateOverrides[entityId] = m_numberOfUpdatesToIgnore;

        m_api.startPolling();
    }
}

void HomeAssistantImpl::onStatesReceived(QJsonArray stateArray)
{
    for(const auto stateValue : stateArray)
    {
        if(stateValue.isObject())
        {
            const auto stateObject = stateValue.toObject();
            const auto entityId = stateObject["entity_id"].toString();

            auto localOverrideIt = m_localStateOverrides.find(entityId);
            if(localOverrideIt != m_localStateOverrides.end())
            {
                --localOverrideIt.value();
                if(localOverrideIt.value() <= 0)
                {
                    m_localStateOverrides.erase(localOverrideIt);
                }
                continue;
            }

            if(m_states.contains(entityId))
            {
                const auto currentState = m_states.value(entityId).toJsonObject();

                if(stateObject["last_updated"] != currentState["last_updated"] && stateObject != currentState)
                {
                    m_states.insert(entityId, stateObject);
                }
            }
            else
            {
                m_states.insert(entityId, stateObject);
            }
        }
    }

    if(!m_isLoaded)
    {
        m_isLoaded = true;
        emit isLoadedChanged();
    }
}

void HomeAssistantImpl::onError(QString errorMessage)
{
    qWarning() << "TODO: error handle: " << errorMessage;
}
