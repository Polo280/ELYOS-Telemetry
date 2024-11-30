import QtQuick
import QtQuick.Layouts

///////////// Middle Panel 1 Layout  /////////////

// NOTE: This panel will be used to hold the speedometers (gauges), and some general plots along with additional data

Rectangle {
    // Gauge/performance panel
    property alias performanceValues: gaugePanel1.performanceValues
    property alias currentSpeed: gaugePanel1.speedGaugeValue
    property alias currentDistance: gaugePanel1.gauge2Value   // Assumming gauge 2 is being used to show traveled distance
    // Plot panel
    property alias accelerations: plotPanel1.accelerations
    property alias orientationAngles: plotPanel1.orientationAngles

    anchors.fill: parent
    anchors.margins: 3
    // Properties of main rectangle for panel
    // border.color: "#d0d0d0"
    // border.width: 1
    color: "#181818"
    radius: 5

    // External layout
    GridLayout{
        // Configuration
        anchors.fill: parent
        anchors.margins: 1
        // Cols and rows configurations
        columns: 10
        rows: 20
        columnSpacing: 3
        rowSpacing: 1

        ///// GAUGE PANEL  /////
        Rectangle{
            // Specify position and presentation
            property int gaugeRowSpan: 8
            property int gaugeColumnSpan: 10

            Layout.columnSpan: gaugeColumnSpan
            Layout.rowSpan: gaugeRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * gaugeColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * gaugeRowSpan)

            // Style
            color: "#181818"
            radius: 5
            // border.color: "red"
            // border.width: 1

            // Gauge Panel Component
            GaugePanel{
                id: gaugePanel1
            }
        }

        ///// PLOT PANEL  /////
        Rectangle{
            // Specify position and presentation
            property int plotRowSpan: 12
            property int plotColumnSpan: 10

            Layout.columnSpan: plotColumnSpan
            Layout.rowSpan: plotRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * plotColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * plotRowSpan)

            // Style
            color: "#181818"

            ///// PLOT PANEL COMPONENT /////
            PlotPanel{
                id: plotPanel1
            }
        }
    }
}
