import QtQuick
import QtCharts
import SerialHandler

Rectangle {
    id: rt_chart
    anchors.fill: parent
    color:"#181818"

    /////////// Plot limits ///////////
    property int time_axis_min: 0
    property int time_axis_max: 120  // Original max (to handle reset)
    property int time_axis_max_aux: 120
    property int time_limit_increment: 20
    // Amps
    property int current_min_limit: -5
    property int current_max_limit: 40
    // Volts
    property int voltage_max_limit: 55
    property int voltage_min_limit: 20
    ///////////////////////////////////

    ChartView {
        anchors.fill: parent
        antialiasing: true
        theme: ChartView.ChartThemeDark  // Apply the dark theme
        // ChartView.ChartThemeHighContrast
        // ChartView.ChartThemeBlueCerulean

        title: ""
        titleColor: "gray"
        animationOptions: ChartView.SeriesAnimations

        // Current
        SplineSeries {
            id: currentSeries
            name: "Current (A)"
            color: "yellow"
            axisX: xAxis
            axisY: currentAxis
        }

        // voltage
        SplineSeries {
            id: voltageSeries
            name: "Voltage (V)"
            color: "cyan"
            axisX: xAxis
            axisY: voltageAxis
        }

        ValuesAxis {
            id: currentAxis
            min: rt_chart.current_min_limit
            max: rt_chart.current_max_limit
            titleText: "Current (A)"
        }

        ValuesAxis {
            id: voltageAxis
            min: rt_chart.voltage_min_limit
            max: rt_chart.voltage_max_limit
            titleText: "Voltage (V)"
        }

        ///// Time Axis /////
        ValuesAxis {
            id: xAxis
            min: rt_chart.time_axis_min
            max: rt_chart.time_axis_max_aux
        }

        //// Mid layout instance to catch reset button event ////
        Connections {
            target: midLayoutMain

            function onMapResetButtonClicked(){
                voltageSeries.clear();
                currentSeries.clear();
                rt_chart.time_axis_min = 0;
                rt_chart.time_axis_max_aux = rt_chart.time_axis_max;
            }
        }

        // Handle new data incoming through serial handler
        Connections {
            target: SerialHandler

            function onNewDataReceived (message) {
                let time_aux = 0;
                if(root.timeRunningAttempt >= rt_chart.time_axis_max_aux){
                    rt_chart.time_axis_max_aux += rt_chart.time_limit_increment;
                    rt_chart.time_axis_min += rt_chart.time_limit_increment;
                }

                voltageSeries.append(root.timeRunningAttempt, Math.random() * (50 - 44) + 44);
                currentSeries.append(root.timeRunningAttempt, root.dataValues[5]);
            }
        }
    }
}
