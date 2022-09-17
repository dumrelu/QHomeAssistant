import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QHomeAssistant 1.0

Rectangle {
    id: root

    property string entityId: ""
    property alias icon: coloredImage

    signal brightnessUpdated(int newBrightness);

    implicitWidth: coloredImage.implicitWidth * 1.5
    implicitHeight: coloredImage.implicitHeight * 1.5
    radius: width / 2

    color: Material.accent

    QtObject {
        id: internal

        property int lastKnownValue: 100
        property int brightness: {
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
    }

    ColoredImage {
        id: coloredImage

        anchors.centerIn: parent

        source: "image://mdi/light"

        color: Material.color(Material.Yellow)
        intensityFactor: {
            var intensity = internal.brightness / 255;
            if(intensity === 0.0)
            {
                return 0;
            }
            return 0.5 + intensity;
        }
    }

    MouseArea {
        id: mouseArea

        property bool isHold: false
        property int holdPositionY: 0
        property int baseBrightness: 0

        anchors.fill: parent

        Timer {
            id: callServiceTimer
            interval: 100
            onTriggered: {
                HomeAssistant.call_service("light.turn_on", entityId, {"brightness": internal.brightness});
            }
        }

        onPressAndHold: {
            mouseArea.isHold = true;
            mouseArea.holdPositionY = mouseArea.mouseY;
            mouseArea.baseBrightness = internal.brightness;
        }

        onMouseYChanged: {
            if(mouseArea.isHold)
            {
                var newBrightness = mouseArea.baseBrightness + (mouseArea.holdPositionY - mouseArea.mouseY) * 2.5;
                newBrightness = Math.min(255, Math.max(0, newBrightness));
                HomeAssistant.update_local_state(entityId, newBrightness !== 0 ? "on" : "off");
                HomeAssistant.update_local_attr(entityId, "brightness", newBrightness);
                root.brightnessUpdated(newBrightness);

                callServiceTimer.start();
            }
        }

        onReleased: {
            mouseArea.isHold = false;
        }

        onClicked: {
            if(HomeAssistant.state(entityId) === "on")
            {
                HomeAssistant.call_service("light.turn_off", entityId);
                HomeAssistant.update_local_state(entityId, "off");

                root.brightnessUpdated(0);
            }
            else
            {
                HomeAssistant.call_service("light.turn_on", entityId);
                HomeAssistant.update_local_state(entityId, "on");
                HomeAssistant.update_local_attr(entityId, "brightness", internal.lastKnownValue);

                root.brightnessUpdated(internal.lastKnownValue);
            }
        }
    }

    Popup {
        anchors.centerIn: parent
        modal: true
        visible: mouseArea.isHold

        width: sliderBackground.width
        height: sliderBackground.height

        background: Item { }

        leftPadding: -(parent.width / 2 + sliderBackground.width)
        bottomPadding: sliderBackground.height

        Rectangle {
            id: sliderBackground
            width: 50
            height: 125
            radius: 20

            Rectangle {
                id: brightnessSlider
                anchors.bottom: parent.bottom
                width: parent.width
                radius: parent.radius
                color: Material.accent
                height: Math.min(parent.height, parent.height * (internal.brightness / 255))
            }
        }
    }
}
