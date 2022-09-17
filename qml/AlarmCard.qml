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
    }

    ColumnLayout {
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
                    HomeAssistant.call_service("alarm_control_panel.alarm_arm_away", root.entityId);
                    HomeAssistant.update_local_state(root.entityId, "pending")
                }
            }

            RoundButton {
                text: qsTr("HOME")
                visible: internal.state === "disarmed"
                font.pixelSize: Qt.application.font.pixelSize * 1.5
                highlighted: true
                padding: 20

                onClicked: {
                    HomeAssistant.call_service("alarm_control_panel.alarm_arm_home", root.entityId);
                    HomeAssistant.update_local_state(root.entityId, "pending")
                }
            }
        }
    }
}
