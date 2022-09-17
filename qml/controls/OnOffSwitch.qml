import QtQuick 2.12
import QtQuick.Controls 2.12
import QHomeAssistant 1.0

Switch {
    id: root

    property string entityId: ""

    // Extract the domain name. Will call "domain".turn_on and "domain".turn_off
    readonly property string domain: {
        var pair = entityId.split(".")
        if(pair.length >= 2)
        {
            return pair[0];
        }
        return "";
    }

    checked: HomeAssistant.state(root.entityId) === "on"

    onClicked: {
        var service = root.domain + ".";
        var newState;
        if(checked)
        {
            service += "turn_on";
            newState = "on";
        }
        else
        {
            service += "turn_off";
            newState = "off";
        }

        HomeAssistant.call_service(service, entityId);
        HomeAssistant.update_local_state(entityId, newState);
    }
}
