import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QHomeAssistant 1.0

Window {
    width: 600
    height: 1024
    visible: true
    title: qsTr("Example Project")

    Rectangle {
        anchors.fill: parent
        color: "pink"
    }


    Column {
        Image {
            source: "image://mdi/light"
        }

        BusyIndicator {
            visible: true
            running: true
            width: 100
            height: 100
        }

        LightSlider {
            entityId: "light.lampa"
        }

        SensorsView {
            model: ListModel {
                ListElement {
                    entityId: "sensor.air_purifier_humidity"
                }

                ListElement {
                    entityId: "sensor.daikinap02467_inside_temperature"
                    name: qsTr("Inside temperatur custom name pretty long")
                    icon: "image://mdi/cloud"
                }

                ListElement {
                    entityId: "binary_sensor.lumi_lumi_sensor_magnet_aq2_on_off"
                }
            }
        }

        Button {
            icon.source: "image://mdi/cloud"
            icon.width: 48
            icon.height: 48

            text: qsTr("Day Time")

            onClicked: {
                HomeAssistant.call_service("scene.turn_on", "scene.day_time");
            }
        }

        Button {
            icon.source: "image://mdi/cloud"
            icon.width: 48
            icon.height: 48

            text: qsTr("Before Bed")

            onClicked: {
                HomeAssistant.call_service("scene.turn_on", "scene.before_bed");
            }
        }
    }
}
