import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QHomeAssistant 1.0

Item {
    id: root

    property string entityId: ""
    property string temperatureUnit: "°C"

    //https://www.home-assistant.io/dashboards/weather-forecast/
    property var stateFriendlyNames: ({
        "sunny": qsTr("Sunny"),
        "partlycloudy": qsTr("Partly Cloudy"),
        "cloudy": qsTr("Cloudy")
    })
    property var stateIcons: ({
        "sunny": "image://mdi/sunny",
        "partlycloudy": "image://mdi/partly_cloudy",
        "cloudy": "image://mdi/cloudy"
    })

    //TODO
    implicitWidth: 200
    implicitHeight: rootLayout.implicitHeight

    function getStateFriendlyName(state)
    {
        if(state in stateFriendlyNames)
        {
            return stateFriendlyNames[state];
        }
        return state;
    }

    function getStateIcon(state)
    {
        if(state in stateIcons)
        {
            return stateIcons[state];
        }
        return "";
    }

    QtObject {
        id: internal

        property string currentState: HomeAssistant.state(entityId)
        property string currentTemperature: HomeAssistant.state_attr(entityId, "temperature")

        property var forecast: HomeAssistant.state_attr(entityId, "forecast")

        property string locationFriendlyName: HomeAssistant.state_attr(entityId, "friendly_name")
    }

    ColumnLayout {
        id: rootLayout

        width: parent.width
        spacing: 10

        RowLayout {
           id: currentWeather

           Layout.fillWidth: true

           ColoredImage {
                id: currentWeatherIcon
                source: getStateIcon(internal.currentState)
           }

           Column {
               Label {
                   text: getStateFriendlyName(internal.currentState)
                   font.bold: true
                   font.pixelSize: Qt.application.font.pixelSize * 2
               }

               Label {
                   text: internal.locationFriendlyName
               }
           }

           Item {
               Layout.fillHeight: true
               Layout.fillWidth: true
           }

           Column {
               Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
               Layout.rightMargin: 10

               Label {
                   text: internal.currentTemperature + root.temperatureUnit
                   font.bold: true
                   font.pixelSize: Qt.application.font.pixelSize * 2
               }

               //TODO: precipitation
           }
        }

        RowLayout {
            id: weatherForecast

            Layout.fillWidth: true

            Repeater {
                model: internal.forecast

                Item {
                    id: forecastDelegate
                    Layout.fillWidth: true
                    Layout.preferredHeight: forecastColumn.implicitHeight

                    Column {
                        id: forecastColumn

                        anchors.centerIn: parent

                        ColoredImage {
                            source: getStateIcon(modelData["condition"])
                        }

                        Label {
                            text: modelData["temperature"] + root.temperatureUnit
                        }

                        Label {
                            text: modelData["templow"] + root.temperatureUnit
                        }
                    }
                }
            }
        }
    }
}
