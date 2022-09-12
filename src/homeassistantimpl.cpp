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

void HomeAssistantImpl::callService(QString service, QString entityId, QVariantMap data)
{
    m_api.callService(service, entityId, data);
}

void HomeAssistantImpl::onStatesReceived(QJsonArray stateArray)
{
    for(const auto stateValue : stateArray)
    {
        if(stateValue.isObject())
        {
            const auto stateObject = stateValue.toObject();
            const auto entityId = stateObject["entity_id"].toString();

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
}

void HomeAssistantImpl::onError(QString errorMessage)
{
    qWarning() << "TODO: error handle: " << errorMessage;
}
