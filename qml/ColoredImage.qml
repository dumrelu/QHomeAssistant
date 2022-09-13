import QtQuick 2.0

//TODO
//import QtGraphicalEffects 1.12
//import Qt5Compat.GraphicalEffects

Item {
    id: root

    property alias source: image.source
    property color color: "black"
    property real intensityFactor: 1.0
    width: 48
    height: 48

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

        source: HomeAssistant.isQt5 ? "Qt5ColorOverlay.qml" : "Qt6ColorOverlay.qml"
    }
}
