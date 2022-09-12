import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QHomeAssistant 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

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
    }
}
