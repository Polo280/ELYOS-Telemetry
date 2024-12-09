import QtQuick
import QtCharts
import SerialHandler

Rectangle {
    anchors.fill: parent
    color:"#181818"

    ChartView {
        anchors.fill: parent
        antialiasing: true
        theme: ChartView.ChartThemeDark  // Apply the dark theme
        // ChartView.ChartThemeHighContrast
        // ChartView.ChartThemeBlueCerulean

        title: "RT DATA"
        titleColor: "gray"
        animationOptions: ChartView.SeriesAnimations

        // Voltage
        SplineSeries {
            id: voltageSeries
            name: "Voltage (V)"
            color: "cyan"
        }

        // Current
        SplineSeries {
            id: currentSeries
            name: "Current (A)"
            color: "yellow"
        }


        Connections {
            target: SerialHandler

            onNewDataReceived: {
                voltageSeries.append(root.timeRunning, root.dataValues[2]);
                currentSeries.append(root.timeRunning, root.dataValues[3]);
            }
        }
    }
}
