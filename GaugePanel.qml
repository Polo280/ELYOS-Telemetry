import QtQuick
import QtQuick.Layouts
import CustomControls

///////////// GAUGE PANEL  /////////////

Rectangle {
    // PROPERTIES FOR SHOWING VALUES
    property var performanceValues: [0.0, 0.0, 0.0, 0.0, 0.0]  // Current, voltage, rpms, kwh, mi/kwh
    property real speedGaugeValue: 0.0   // Speed
    property real gauge2Value: 0.0       // Distance

    anchors.fill: parent
    anchors.margins: 0
    // Properties of main rectangle for panel
    // border.color: "#d0d0d0"
    // border.width: 1
    color: "#181818"
    radius: 5

    // External layout
    GridLayout{
        // Configuration
        anchors.fill: parent
        anchors.margins: 3
        // Cols and rows configurations
        columns: 20
        rows: 16
        columnSpacing: 3
        rowSpacing: 7

        //////// GAUGE 1 TITLE  ////////
        Rectangle{
            // Specify position and presentation
            property int g1TitleRowSpan: 2
            property int g1TitleColumnSpan: 6

            Layout.columnSpan: g1TitleColumnSpan
            Layout.rowSpan: g1TitleRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g1TitleColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g1TitleRowSpan) - parent.rowSpacing

            // Style
            color: "#181818"
            radius: 5
            // border.color: "red"
            // border.width: 1

            // Gauge Title
            Text{
                anchors.centerIn: parent
                text: "SPEED"
                font.pointSize: 15
                font.weight: Font.Medium
                color: "#edaf3b"
            }
        }

        //////////// SECOND GAUGE ////////////
        Rectangle{
            // Specify position and presentation
            property int g2TitleRowSpan: 2
            property int g2TitleColumnSpan: 6

            Layout.columnSpan: g2TitleColumnSpan
            Layout.rowSpan: g2TitleRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g2TitleColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g2TitleRowSpan) - parent.rowSpacing

            // Style
            color: "#181818"
            radius: 5
            // border.color: "red"
            // border.width: 1

            // Gauge Title
            Text{
                anchors.centerIn: parent
                text: "DISTANCE"
                font.pointSize: 15
                font.weight: Font.Medium
                color: "#3baced"
            }
        }

        ///// GAUGE 2 Title  /////
        Rectangle{
            // Specify position and presentation
            property int g2TitleRowSpan: 3
            property int g2TitleColumnSpan: 8

            Layout.columnSpan: g2TitleColumnSpan
            Layout.rowSpan: g2TitleRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g2TitleColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g2TitleRowSpan) - parent.rowSpacing

            // Style
            color: "#181818"
            radius: 5
            // border.color: "blue"
            // border.width: 1

            // Gauge Title
            Text{
                anchors.centerIn: parent
                text: "PERFORMANCE"
                font.pointSize: 15
                font.weight: Font.Medium
                color: "#04f3bd"
            }
        }

        ///// GAUGE 1 COMPONENT /////
        Rectangle{
            // Specify position and presentation
            property int g1RowSpan: 14
            property int g1ColumnSpan: 6

            Layout.columnSpan: g1ColumnSpan
            Layout.rowSpan: g1RowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g1ColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g1RowSpan) - parent.rowSpacing

            // Style
            color: "#181818"
            radius: 5
            // border.color: "white"
            // border.width: 1

            RadialBar{
                // Properties for radial progress bar value
                property real minSpeed: 0.0    // Speed in mi/hr
                property real maxSpeed: 60.0
                property real currentSpeed: speedGaugeValue

                property string barColor: "#edaf3b"

                anchors.centerIn: parent
                height: parent.height - 20
                penStyle: Qt.RoundCap
                progressColor: barColor
                dialWidth: 12
                // Values
                minValue: minSpeed
                maxValue: maxSpeed
                value: currentSpeed
                textFont {
                    weight: Font.DemiBold
                    pointSize: 20
                }
                suffixText: " mi/h"
                textColor: barColor
            }
        }

        ///// GAUGE 2 COMPONENT /////
        Rectangle{
            // Specify position and presentation
            property int g1RowSpan: 14
            property int g1ColumnSpan: 6

            Layout.columnSpan: g1ColumnSpan
            Layout.rowSpan: g1RowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g1ColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g1RowSpan) - parent.rowSpacing

            // Style
            color: "#181818"
            radius: 5
            // border.color: "white"
            // border.width: 1

            RadialBar{
                // Properties for radial progress bar value
                property real minDist: 0.0    // Distance in mi
                property real maxDist: 100.0
                property real currentDist: gauge2Value

                property string barColor: "#3baced"

                anchors.centerIn: parent
                height: parent.height - 20
                penStyle: Qt.RoundCap
                progressColor: barColor
                dialWidth: 12
                // Values
                minValue: minDist
                maxValue: maxDist
                value: currentDist
                textFont {
                    weight: Font.DemiBold
                    pointSize: 20
                }
                suffixText: " mi"
                textColor: barColor
            }
        }

        //////////// PANEL (PERFORMANCE) COMPONENT  ////////////
        Rectangle{
            // Specify position and presentation
            property int g2RowSpan: 13
            property int g2ColumnSpan: 8

            Layout.columnSpan: g2ColumnSpan
            Layout.rowSpan: g2RowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g2ColumnSpan)
            Layout.preferredHeight: ((parent.height / parent.rows) * g2RowSpan)
            anchors.margins: 5

            // Style
            color: "#181818"
            radius: 5
            // border.color: "#606060"
            // border.width: 1

            ////////////// ELEMENTS FOR THE TABLE //////////////
            ListView {
                property int margin: 5
                id: listViewPerformance
                anchors.fill: parent
                clip: true  // Clipping to prevent drawing outside the bounds
                spacing: 0  // Spacing between rows

                // Width of every row in the table
                property int rowHeight: 35

                model: ListModel {
                    ListElement { name: "CURRENT"; index: 0; tag: "current"}
                    ListElement { name: "VOLTAGE"; index: 1; tag: "voltage"}
                    ListElement { name: "RPMS"; index: 2; tag: "RPM"}
                    ListElement { name: "TOTAL CONSUMPTION"; index: 3; tag: "consumption"}
                    ListElement { name: "EFFICIENCY"; index: 4; tag: "efficiency"}
                }

                delegate: Rectangle {
                    width: listViewPerformance.width
                    height: listViewPerformance.rowHeight
                    color: "#202020"  // Background color of each row
                    border.color: "#707070"
                    radius: 3

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0  // Spacing between columns

                        // Name Column
                        Text {
                            text: name
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            font.pixelSize: 14
                            color: "#04f3bd" // Text color
                        }

                        // PERFORMANCE COLUMNS
                        Text {
                            text: {
                                if(model.tag === "current"){
                                   performanceValues[model.index] + " A"
                                }else if(model.tag === "voltage"){
                                   performanceValues[model.index] + " V"
                                }else if (model.tag === "RPM"){
                                    Math.floor(performanceValues[model.index]) + " RPM"
                                }else if(model.tag === "consumption"){
                                   performanceValues[model.index] + " kWh"
                                }else if(model.tag === "efficiency"){
                                   performanceValues[model.index] + " mi/kWh"
                                }
                            }

                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            rightPadding: 10
                            font.pixelSize: 14
                            color: "#999999"  // Text color
                        }
                    }
                }
            }
        }
    }
}
