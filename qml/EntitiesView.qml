import QtQuick 2.12
import QtQuick.Controls 2.12

import QHomeAssistant 1.0

ListView {
    id: root

    implicitWidth: 250
    implicitHeight: 250

    property var switchDomains: ["switch", "climate"]
    property var sensorDomains: ["sensor", "binary_sensor"]
    property var lightDomains: ["light"]

    property Component sensorView: Label {
        id: state

        verticalAlignment: Label.AlignVCenter
        elide: Label.ElideRight

        text: {
            var state = HomeAssistant.state(_model.entityId);
            if(state !== undefined)
            {
                var unitOfMeasure = "";
                if(state !== "unavailable")
                {
                    unitOfMeasure = HomeAssistant.state_attr(_model.entityId, "unit_of_measurement");
                }

                return state + (unitOfMeasure !== undefined ? unitOfMeasure : "");
            }
            return "N/A"
        }
    }

    property Component switchView: OnOffSwitch {
        entityId: _model.entityId
    }

    property Component lightView: LightSlider {
        entityId: _model.entityId
    }

    delegate: Item {
        id: delegate

        width: parent.width
        height: Math.max(image.height)

        property var domain: {
            var pair = model.entityId.split(".");
            if(pair.length < 2)
            {
                return "";
            }

            return pair[0];
        }

        ColoredImage {
            id: image
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            sourceSize: Qt.size(width, height)
            source: model.icon ? model.icon : ""
        }

        Label {
            id: name

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: image.right
            anchors.leftMargin: 10
            anchors.right: entityView.left
            anchors.rightMargin: 10
            verticalAlignment: Label.AlignVCenter
            elide: Label.ElideRight

            visible: !root.lightDomains.includes(delegate.domain)

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

        Loader {
            id: entityView

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10

            property var _model: model

            sourceComponent: {
                if(root.sensorDomains.includes(delegate.domain))
                {
                    return root.sensorView;
                }
                else if(root.switchDomains.includes(delegate.domain))
                {
                    return root.switchView;
                }
                else if(root.lightDomains.includes(delegate.domain))
                {
                    return root.lightView;
                }
            }
        }
    }
}
