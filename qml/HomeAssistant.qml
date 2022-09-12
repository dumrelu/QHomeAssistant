pragma Singleton

import QtQuick 2.0
import QHomeAssistant 1.0

Item {
    id: root

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

        cpp.callService(service, entity_id, data);
    }
}
