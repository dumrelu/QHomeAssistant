import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    id: root

    default property alias theContent: contentItem.data

    property alias title: titleText.text
    property alias titleFont: titleText.font

    implicitWidth: Math.max(
                       titleText.implicitWidth + titleText.anchors.leftMargin + titleText.anchors.rightMargin,
                       contentItem.implicitWidth + contentItem.anchors.leftMargin + contentItem.anchors.rightMargin)
    implicitHeight: titleText.implicitHeight + contentItem.implicitHeight + contentItem.anchors.topMargin

    Rectangle {
        id: background

        anchors.fill: parent
        radius: 10

        color: {
            if(Material.theme === Material.Light)
            {
                Qt.darker(Material.background, 1.1);
            }
            else
            {
                Qt.lighter(Material.background, 1.4);
            }
        }
    }

    Loader {
        id: dropShadowLoader

        anchors.fill: background

        property var _source: background
        property int _samples: 32
        property int _verticalOffset: 5
        property int _horizontalOffset: _verticalOffset

        source: HomeAssistant.isQt5 ? "/QHomeAssistant/internal/Qt5DropShadow.qml" : "/QHomeAssistant/internal/Qt6DropShadow.qml"
    }

    Label {
        id: titleText

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        elide: Label.ElideRight

        font.pixelSize: Qt.application.font.pixelSize * 1.5
        font.bold: true
    }

    Item {
        id: contentItem

        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height

        anchors.top: titleText.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
