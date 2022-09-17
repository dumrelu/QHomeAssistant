import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QHomeAssistant 1.0

Item {
    id: root

    property string entityId: ""
    property string name: ""
    property alias icon: image

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

        Label {
            id: stateLabel

            Layout.rightMargin: 10
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            elide: Text.ElideRight

            text: {
                var state = HomeAssistant.state(root.entityId);
                if(state !== undefined)
                {
                    var unitOfMeasure = "";
                    if(state !== "unavailable")
                    {
                        unitOfMeasure = HomeAssistant.state_attr(root.entityId, "unit_of_measurement");
                    }

                    return state + (unitOfMeasure !== undefined ? unitOfMeasure : "");
                }
                return "N/A"
            }
        }
    }
}
