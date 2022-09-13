import QtQuick 2.12
import QtQuick.Controls 2.12

import QHomeAssistant 1.0

ListView {
    id: root

    implicitWidth: 250
    implicitHeight: 250

    delegate: Item {
        width: parent.width
        height: Math.max(image.height)

        ColoredImage {
            id: image
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            sourceSize: Qt.size(width, height)
            source: model.icon ? model.icon : ""
        }

        Text {
            id: name

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: image.right
            anchors.leftMargin: 10
            anchors.right: state.left
            anchors.rightMargin: 10
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            text: {
                if(model.name)
                {
                    return model.name;
                }

                var friendly_name = HomeAssistant.state_attr(model.entityId, "friendly_name");
                if(friendly_name)
                {
                    return friendly_name;
                }

                return "N/A";
            }
        }

        Text {
            id: state

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            text: {
                var state = HomeAssistant.state(model.entityId);
                if(state !== undefined)
                {
                    var unitOfMeasure = "";
                    if(state !== "unavailable")
                    {
                        unitOfMeasure = HomeAssistant.state_attr(model.entityId, "unit_of_measurement");
                    }

                    return state + (unitOfMeasure !== undefined ? unitOfMeasure : "");
                }
                return "N/A"
            }
        }
    }
}
