import QtQuick 2.12
import QHomeAssistant 1.0

Item {
    id: root

    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property color color: "black"
    property real intensityFactor: 1.0

    implicitHeight: 48
    implicitWidth: 48

    Image {
        id: image
        width: parent.width
        height: parent.height
        sourceSize: Qt.size(parent.width, parent.height)
        smooth: true
        visible: false
    }

    Loader {
        id: colorOverlayLoader
        anchors.fill: image

        property var _source: image
        property color _color: Qt.lighter(root.color, root.intensityFactor < 0.1 ? 0.1 : root.intensityFactor)

        source: HomeAssistant.isQt5 ? "/QHomeAssistant/internal/Qt5ColorOverlay.qml" : "/QHomeAssistant/internal/Qt6ColorOverlay.qml"
    }
}
