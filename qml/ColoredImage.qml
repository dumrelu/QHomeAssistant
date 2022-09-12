import QtQuick 2.0

//TODO
//import QtGraphicalEffects 1.12
import Qt5Compat.GraphicalEffects

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

    ColorOverlay {
        anchors.fill: image
        source: image
        color: Qt.lighter(root.color, root.intensityFactor < 0.1 ? 0.1 : root.intensityFactor)
    }
}
