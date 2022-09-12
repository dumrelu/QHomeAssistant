import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QHomeAssistant 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")


    Column {
        Image {
            source: "image://mdi/light"
        }

        Text {
            text: HomeAssistant.state("light.lampa") + ", " + HomeAssistant.state_attr("light.lampa", "brightness")
        }

        Button {
            text: "click me"
            onClicked: {
                impl.callService("light.turn_off", "light.lampa", {});
            }
        }
    }
}
