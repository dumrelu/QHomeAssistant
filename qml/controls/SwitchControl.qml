import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QHomeAssistant 1.0

Item {
    id: root

    property string entityId: ""
    property string name: ""
    property alias icon: image

    // Extract the domain name. Will call "domain".turn_on and "domain".turn_off
    readonly property string domain: {
        var pair = entityId.split(".")
        if(pair.length >= 2)
        {
            return pair[0];
        }
        return "";
    }
    readonly property alias checked: quickSwich.checked

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout

        width: parent.width

        ColoredImage {
            id: image
            width: 48
            height: 48
            sourceSize: Qt.size(width, height)
        }

        Label {
            id: friendlyNameLabel

            Layout.fillWidth: true

            elide: Text.ElideRight

            text: {
                if(root.name !== "")
                {
                    return root.name;
                }

                var friendly_name = HomeAssistant.state_attr(root.entityId, "friendly_name");
                if(friendly_name)
                {
                    return friendly_name;
                }

                return "N/A";
            }
        }

        Switch {
            id: quickSwich
            Layout.rightMargin: 10
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            checked: {
                var haState = HomeAssistant.state(root.entityId);
                if(haState !== "off" && haState !== "unavailable")
                {
                    return true;
                }
                return false;
            }

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
    }
}
