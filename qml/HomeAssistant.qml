pragma Singleton

import QtQuick 2.0
import QHomeAssistant 1.0

Item {
    id: root

    property alias isQt5: impl.isQt5

    HomeAssistantImpl {
        id: impl
    }

    function state(entityId)
    {
        var stateObj = impl.states[entityId];
        if(!stateObj)
        {
            return undefined;
        }

        return stateObj.state;
    }

    function state_attr(entityId, attributeName)
    {
        var stateObj = impl.states[entityId];
        if(!stateObj || !stateObj.attributes)
        {
            return undefined;
        }

        return stateObj.attributes[attributeName];
    }

    function call_service(service, entity_id, data)
    {
        if(!data)
        {
            data = {};
        }

        impl.callService(service, entity_id, data);
    }

    function update_local_state(entity_id, localState)
    {
        impl.updateLocalState(entity_id, localState);
    }

    function update_local_attr(entity_id, attributeName, value)
    {
        impl.updateLocalAttr(entity_id, attributeName, value);
    }
}
