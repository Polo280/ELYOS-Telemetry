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
    property int time_limit_increment: 10
    // Amps
    property int current_min_limit: -5
    property int current_max_limit: 40
    // Volts
    property int pitch_max_limit: 55
    property int pitch_min_limit: 20
    ///////////////////////////////////

    ChartView {
        anchors.fill: parent
        antialiasing: true
        theme: ChartView.ChartThemeDark  // Apply the dark theme
        // ChartView.ChartThemeHighContrast
        // ChartView.ChartThemeBlueCerulean

        title: "RT DATA"
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

        // pitch
        SplineSeries {
            id: pitchSeries
            name: "Pitch (°)"
            color: "cyan"
            axisX: xAxis
            axisY: pitchAxis
        }

        ValuesAxis {
            id: currentAxis
            min: rt_chart.current_min_limit
            max: rt_chart.current_max_limit
            titleText: "Current (A)"
        }

        ValuesAxis {
            id: pitchAxis
            min: rt_chart.pitch_min_limit
            max: rt_chart.pitch_max_limit
            titleText: "Pitch (°)"
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
                pitchSeries.clear();
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

                pitchSeries.append(root.timeRunningAttempt, Math.random() * (50 - 44) + 44);
                currentSeries.append(root.timeRunningAttempt, root.dataValues[3] / 5);
            }
        }
    }
}
