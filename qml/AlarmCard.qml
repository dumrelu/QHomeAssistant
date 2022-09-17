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
          "icon": "image://mdi/safety_check",
          "color": Material.color(Material.Orange)
      },
      "armed_home": {
          "name": qsTr("Armed home"),
          "icon": "image://mdi/shield_with_house",
          "color": Material.color(Material.Orange)
      },
      "armed_away": {
          "name": qsTr("Armed away"),
          "icon": "image://mdi/security",
          "color": Material.color(Material.Orange)
      },
      "pending": {
          "name": qsTr("Pending"),
          "icon": "image://mdi/safety_check",
          "color": Material.color(Material.Orange)
      },
      "triggered": {
          "name": qsTr("Triggered"),
          "icon": "image://mdi/notification_important",
          "color": Material.color(Material.Red)
      }
  })
    property int numberOfPasscodeDigits: -1

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

        property Timer clearPasscodeTimer: Timer {
            interval: internal.timer.interval
            onTriggered: {
                codeLabel.text = "";
            }
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
                text: {
                    if(internal.state === "disarmed")
                    {
                        return qsTr("Could not arm the alarm due to: ");
                    }
                    return qsTr("Alarm triggered due to: ");
                }
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
            spacing: 0

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
                    internal.clearPasscodeTimer.start();
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

                    onTextChanged: {
                        if(text.length === root.numberOfPasscodeDigits)
                        {
                            disarmButton.clicked();
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    text: "1"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    text: "2"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    text: "3"
                    onClicked: codeLabel.text += text;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "4"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "5"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "6"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    onClicked: codeLabel.text += text;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "7"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "8"
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    onClicked: codeLabel.text += text;
                }

                Button {
                    text: "9"
                    font.pixelSize: Qt.application.font.pixelSize * 2
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
                    font.pixelSize: Qt.application.font.pixelSize * 2
                    text: "0"
                    onClicked: codeLabel.text += text;
                }

                Button {
                    font.pixelSize: Qt.application.font.pixelSize * 2
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
