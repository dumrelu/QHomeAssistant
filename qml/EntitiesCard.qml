import QtQuick 2.12
import QHomeAssistant 1.0

Card {
    title: qsTr("Entities")

    property alias model: entitiesView.model

    EntitiesView {
        id: entitiesView

        implicitWidth: parent.width
        implicitHeight: contentItem.childrenRect.height
    }
}
