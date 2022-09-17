import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QHomeAssistant 1.0

Card {
    id: root

    title: qsTr("Alarm")

    property string entityId: ""
    property var config: ({
      "disarmed": {
          "name": qsTr("Disarmed"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Green)
      },
      "arming": {
          "name": qsTr("Arming"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Orange)
      },
      "armed_home": {
          "name": qsTr("Armed home"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Orange)
      },
      "armed_away": {
          "name": qsTr("Armed away"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Orange)
      },
      "pending": {
          "name": qsTr("Pending"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Orange)
      },
      "triggered": {
          "name": qsTr("Triggered"),
          "icon": "image://mdi/remove_moderator",
          "color": Material.color(Material.Red)
      }
  })

    QtObject {
        id: internal

        property string state: {
            var haState = HomeAssistant.state(root.entityId);
            if(haState)
            {
                return haState;
            }
            return "";
        }

        property var openSensors: {
            var haOpenSensors = HomeAssistant.state_attr(root.entityId, "open_sensors");
            if(haOpenSensors)
            {
                return haOpenSensors;
            }
            return {};
        }

        property bool pendingOperation: false

        property Timer timer: Timer {
            id: pendingOperationTimer
            interval: 3 * 1000
            running: internal.pendingOperation
            onTriggered: internal.pendingOperation = false;
        }
        property var stateObject: HomeAssistant.states[root.entityId]
        onStateObjectChanged: {
            internal.pendingOperation = false;
        }
    }

    ColumnLayout {
        id: mainColumnLayout

        width: parent.width

        RowLayout {
            id: topRow

            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                Layout.preferredWidth: stateIcon.width * 1.2
                Layout.preferredHeight: stateIcon.height * 1.2
                color: "transparent"

                border.color: stateIcon.color
                border.width: 2
                radius: width

                ColoredImage {
                    id: stateIcon

                    anchors.centerIn: parent

                    source: {
                        return root.config[internal.state].icon;
                    }

                    color: {
                        return root.config[internal.state].color;
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: 20
                Label {
                    text: qsTr("Alarm")
                    font.pixelSize: Qt.application.font.pixelSize * 2
                }

                Label {
                    text: root.config[internal.state].name;
                }
            }
        }

        ColumnLayout {
            id: openSensors

            visible: openSensorsRepeater.count > 0

            Layout.alignment: Qt.AlignHCenter

            Label {
                font.bold: true
                font.pixelSize: Qt.application.font.pixelSize * 1.5

                color: root.config["pending"].color
                text: qsTr("Could not arm the alarm due to: ")
            }

            Repeater {
                id: openSensorsRepeater
                model: Object.keys(internal.openSensors)
                delegate: Label {
                    font.bold: true
                    text: modelData + ": " + internal.openSensors[modelData]
                }
            }
        }

        RowLayout {
            id: actionButtons

            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            RoundButton {
                text: qsTr("AWAY")
                visible: internal.state === "disarmed"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                highlighted: true
                padding: 20

                onClicked: {
                    internal.pendingOperation = true;
                    HomeAssistant.call_service("alarm_control_panel.alarm_arm_away", root.entityId);
                }
            }

            RoundButton {
                text: qsTr("HOME")
                visible: internal.state === "disarmed"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                highlighted: true
                padding: 20

                onClicked: {
                    internal.pendingOperation = true;
                    HomeAssistant.call_service("alarm_control_panel.alarm_arm_home", root.entityId);
                }
            }

            RoundButton {
                id: disarmButton

                text: qsTr("DISARM")
                visible: internal.state !== "disarmed"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                highlighted: true
                padding: 20

                onClicked: {
                    internal.pendingOperation = true;
                    HomeAssistant.call_service("alarm_control_panel.alarm_disarm", root.entityId, {"code": codeLabel.text});
                    codeLabel.text = "";
                }
            }
        }

        ColumnLayout {
            id: keypad

            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            visible: disarmButton.visible

            Rectangle {
                Layout.preferredWidth: root.width / 2
                Layout.preferredHeight: codeLabel.implicitHeight * 2
                Layout.alignment: Qt.AlignHCenter

                border.width: 2
                border.color: Material.foreground

                TextEdit {
                    id: codeLabel
                    anchors.fill: parent
                    anchors.margins: 5
                    horizontalAlignment: TextEdit.AlignHCenter
                    verticalAlignment: TextEdit.AlignVCenter
                    font.pixelSize: Qt.application.font.pixelSize * 1.5
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "1"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "2"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "3"
                    onClicked: codeLabel.text += text;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "4"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "5"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "6"
                    onClicked: codeLabel.text += text;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "7"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "8"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "9"
                    onClicked: codeLabel.text += text;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Item {
                    implicitHeight: button0.implicitHeight
                    implicitWidth: button0.implicitWidth
                }

                Button {
                    id: button0
                    text: "0"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: qsTr("CLEAR")
                    onClicked: codeLabel.text = ""
                }
            }
        }
    }

    Rectangle {
        anchors.fill: mainColumnLayout

        visible: internal.pendingOperation
        color: "#99333333"

        BusyIndicator {
            anchors.centerIn: parent
            running: true
        }
    }
}
