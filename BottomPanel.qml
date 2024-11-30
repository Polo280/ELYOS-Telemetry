import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item{
    anchors.fill: parent
    // PROPERTIES
    property bool telemetryConnected: false    // Telemetry status
    property int batteryPercentage: 0

    ///// Inner layout  /////
    Rectangle{
        id: panelRect
        // Color of the panel
        property string panelColor: "#181818"

        anchors.fill: parent
        radius: 4
        color: panelColor

        RowLayout{
            anchors.fill: parent
            anchors.margins: 2
            spacing: 1

            /////// PROGRESS BAR MAIN RECTANGLE  ///////
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: 850
                color: panelRect.panelColor

                RowLayout{
                    anchors.fill: parent
                    anchors.margins: 1
                    spacing: 1

                    ////////// BATTERY STATS TEXT //////////
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.preferredWidth: 95
                        Layout.alignment: Qt.AlignLeft
                        color: panelRect.panelColor
                        // border.color: "white"

                        //// Battery charge text ////
                        Text{
                            anchors.centerIn: parent
                            text: "BATTERY"
                            font.pointSize: 11
                            font.weight: Font.Bold
                            color: "green"
                        }
                    }

                    ////// PROGRESS BAR FOR BATTERY STATS ///////
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: panelRect.panelColor

                        // Percentage text
                        Text{
                            z: 1
                            anchors.centerIn: parent
                            text: batteryPercentage + " %"
                            font.pointSize: 11
                            font.weight: Font.DemiBold
                            color: "white"
                        }

                        ProgressBar{
                            property real barValue: batteryPercentage / 100  // Value between 0 and 1
                            // Color for the bar
                            property string barColor: "green"

                            id: batteryProgressBar
                            anchors.fill: parent
                            anchors.margins: 2
                            value: barValue

                            // Styling the background
                            background: Rectangle {
                                anchors.fill: parent
                                radius: 5
                                color: panelRect.panelColor
                                border.color: "white"
                            }

                            contentItem: Item {
                                Rectangle {
                                    x: 2 // Leave a small initial margin
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: batteryProgressBar.visualPosition * parent.width
                                    height: parent.height * 0.8
                                    color: batteryProgressBar.barColor
                                    radius: 5

                                }
                            }
                        }
                    }
                }
            }

            /////// EMPTY RECTANGLE TO STRUCTURE ///////
            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: panelRect.panelColor
                // border.color: "white"
            }


            /////////// TELEMETRY STATUS TEXT ////////////
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: (telemetryConnected)? 180 : 200
                color: panelRect.panelColor

                RowLayout{
                    anchors.fill: parent
                    spacing: 1

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.preferredWidth: 80
                        color: "#272727"
                        radius: 5
                        // border.color: "white"

                        Text{
                            anchors.centerIn: parent
                            text: "STATUS"
                            font.pointSize: 11
                            font.weight: Font.DemiBold
                            color: "white"
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: panelRect.panelColor
                        // border.color: "white"

                        Text{
                            x: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: (telemetryConnected)? "Connected" : "Disconnected"
                            font.pointSize: 11
                            font.bold: false
                            font.weight: Font.Medium
                            color: (telemetryConnected)? "Green" : "Red"
                        }
                    }
                }
            }

            /////// EMPTY RECTANGLE TO STRUCTURE (RIGHT MARGIN) ///////
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: 5
                color: panelRect.panelColor
                // border.color: "white"
            }
        }
    }
}
