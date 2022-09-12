import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QHomeAssistant 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    QmlType {

    }

    HomeAssistantImpl {
        id: impl
    }

    Column {
        Image {
            source: "image://mdi/light"
        }

        Text {
            text: impl.states["light.lampa"]["attributes"]["brightness"]
        }

        Button {
            text: "click me"
            onClicked: {
                impl.callService("light.turn_off", "light.lampa", {});
            }
        }
    }
}
