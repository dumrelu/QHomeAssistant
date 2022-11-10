import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

// Import the qml module
import QHomeAssistant 1.0

Window {
    id: root

    width: 500
    height: 700
    visible: true
    title: qsTr("Example Project")

    // TODO: Change me
    property string lightId: "light.main_lights"
    property string binarySensorId: "binary_sensor.lumi_lumi_sensor_magnet_aq2_on_off"


    Column {
        anchors.centerIn: parent

        Label {
            text: "Some examples of reusable entities: "
            font.pixelSize: Qt.application.font.pixelSize * 2
            font.bold: true
        }

        Label {
            text: "Don't forget to update the ids at the top of the qml"
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            font.italic: true
            color: Material.color(Material.Red)
        }

        RowLayout {
            Label {
                text: "Click on the icon to turn on/off. Click and hold to adjust: "
            }

            LightIcon {
                entityId: root.lightId
            }
        }

        RowLayout {
            Label {
                text: "Simple toggle entity: "
            }

            SwitchControl {
                entityId: "fan.air_purifier"
                icon.source: "image://mdi/fan"
            }
        }

        RowLayout {
            Label {
                text: "Show the state of a sensor: "
            }

            SensorInfo {
                Layout.fillWidth: true
                name: "Door Sensor"
                entityId: root.binarySensorId
                icon.source: HomeAssistant.state(entityId) === "on" ? "image://mdi/door_open" : "image://mdi/door_front"
                icon.color: HomeAssistant.state(entityId) === "on" ? Material.color(Material.Orange) : Material.foreground
            }
        }

        Label {
            text: "See the qml dir for more reusable types(WeatherForcast, AlarmoCard, etc)"
            width: root.width
            font.pixelSize: Qt.application.font.pixelSize
            font.italic: true
            wrapMode: Text.Wrap
        }


        Label {
            text: "Some examples of using the api"
            font.pixelSize: Qt.application.font.pixelSize * 2
            font.bold: true
        }

        Label {
            text: "Get the state of an entity: " + HomeAssistant.state(root.lightId)
        }

        Label {
            text: "Get an attribute of an entity: " + HomeAssistant.state_attr(root.lightId, "brightness")
        }

        Button {
            text: "Print the entire state of an entity(click and see the logs)"
            onClicked: {
                console.log(JSON.stringify(HomeAssistant.states[root.lightId]))
            }
        }

        Button {
            text: "Call a service(See comments in the onClicked method)"
            onClicked: {
                HomeAssistant.call_service("light.turn_on", root.lightId, {"brightness": 255});

                //Implementation note: The internal state if fetched from HomeAssistant every second(by default)
                //So if you just call a service, the effects on the UI will be visible only after the update from
                //HomeAssistant is received.
                //To get over this limitation, you can pre-update the internal state using the update_local_state and
                //update_local_attr functions.
                //In our example, we call a service to turn on the light. So we expect that the state of the light will be
                //changed to "on" and the "brightness" attribute to the value we just set.
                HomeAssistant.update_local_state(root.lightId, "on");
                HomeAssistant.update_local_attr(root.lightId, "brightness", 255);
            }
        }
    }
}
