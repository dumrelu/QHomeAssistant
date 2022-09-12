import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import QHomeAssistant 1.0

Item {
    id: root

    property string entityId: ""
    property alias iconSource: coloredIcon.source

    implicitHeight: coloredIcon.height
    implicitWidth: coloredIcon.width + slider.implicitWidth

    QtObject {
        id: internal

        property int lastKnownValue: 100
    }

    Rectangle {
        id: colorIconBackground
        anchors.fill: coloredIcon

        radius: height / 2

        color: root.Material.accent
        visible: mouseArea.pressed
    }

    ColoredImage {
        id: coloredIcon

        source: "image://mdi/light"
        color: "yellow"
        intensityFactor: {
            var intensity = slider.value / 255;
            if(intensity === 0.0)
            {
                return 0;
            }
            return 0.5 + intensity;
        }

        MouseArea {
            id: mouseArea
            anchors.fill: coloredIcon

            onClicked: {
                if(HomeAssistant.state(entityId) === "on")
                {
                    HomeAssistant.call_service("light.turn_off", entityId);
                    HomeAssistant.update_local_state(entityId, "off");
                }
                else
                {
                    HomeAssistant.call_service("light.turn_on", entityId);
                    HomeAssistant.update_local_state(entityId, "on");
                    HomeAssistant.update_local_attr(entityId, "brightness", internal.lastKnownValue);
                }
            }
        }
    }

    Slider {
        id: slider

        anchors.left: coloredIcon.right
        anchors.right: parent.right
        anchors.verticalCenter: coloredIcon.verticalCenter

        from: 0
        stepSize: 0
        to: 255

        value: {
            if(HomeAssistant.state(entityId) === "off")
            {
                return 0;
            }

            var currentBrightness = HomeAssistant.state_attr(entityId, "brightness");
            if(currentBrightness !== undefined)
            {
                if(currentBrightness !== 0)
                {
                    internal.lastKnownValue = currentBrightness;
                }

                return currentBrightness;
            }
            return 0;
        }

        // Use a timer so we don't spam HA with too many call_service calls
        Timer {
            id: callServiceTimer
            interval: 100
            onTriggered: {
                var roundedValue = Math.round(slider.value);
                HomeAssistant.call_service("light.turn_on", entityId, {"brightness": roundedValue});
                HomeAssistant.update_local_state(entityId, roundedValue !== 0 ? "on" : "off");
                HomeAssistant.update_local_attr(entityId, "brightness", roundedValue);
            }
        }

        onMoved: {
            callServiceTimer.start();
        }
    }
}
