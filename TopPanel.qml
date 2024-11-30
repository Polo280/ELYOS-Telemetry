import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "qrc:/jsFiles/mainAuxFunctions.js" as AuxFunctionsJs

///////////// Top Panel QML /////////////
Rectangle {
    anchors.fill: parent
    // Define Signals
    signal menuButtonClicked()
    // Item properties
    property string hourText: "00:00:00"
    property int attemptRemainingSecs: 0
    property int attemptCurrentLaps: 0
    property int adaptedLaps: 1

    // Properties of main rectangle for panel
    border.color: "#d0d0d0"
    border.width: 1
    color: "#181818"
    radius: 5

    GridLayout{
        // Specify adjustment in parent item (window)
        anchors.fill: parent
        anchors.margins: 10
        // Rows and columns
        columns: 40
        rows: 4
        // Specify gaps between the rows and columns
        property int xSpacing: 2  // column spacing
        property int ySpacing: 2  // row spacing

        columnSpacing: xSpacing
        rowSpacing: ySpacing

        ///////////// SIDE MENU BUTTON /////////////
        Item{
            property int columnSpanMenuButton: 2
            property int rowSpanMenuButton: 4

            Layout.columnSpan: columnSpanMenuButton
            Layout.rowSpan: rowSpanMenuButton

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanMenuButton) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanMenuButton) - parent.rowSpacing

            ///// Actual Menu Button /////
            Rectangle {
                anchors.fill: parent
                color: mouseArea.containsMouse ? "#3b3c3d" : "#181818"  // Change color on hover
                radius: 5  // Rounded corners
                border.color: "#d0d0d0"
                border.width: 1

                ///// Button Activity /////
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Menu button clicked!")
                        menuButtonClicked()  // Emit signal
                    }
                }

                ///// Button Text /////
                Text {
                    text: "MENU"
                    anchors.centerIn: parent
                    color: "white"
                }
            }
        }

        ///////////// Hour/Date Text /////////////
        Rectangle{
            property int columnSpanDate: 6
            property int rowSpanDate: 4

            Layout.columnSpan: columnSpanDate
            Layout.rowSpan: rowSpanDate

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanDate) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanDate) - parent.rowSpacing
            anchors.margins: 5

            color: "#181818"
            //border.color: "#d0d0d0"
            //border.width: 1

            ///// Hour /////
            ColumnLayout{
                anchors.margins: 2
                anchors.fill: parent
                spacing: 10

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text{
                        anchors.centerIn: parent
                        text: hourText
                        font.family: "Calibri"
                        font.pointSize: 15
                        font.bold: true
                        color: "white"
                    }
                }

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text{
                        anchors.centerIn: parent
                        text: "ELYOS TELEMETRY"
                        // font.family: "Calibri"
                        font.pointSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        ///////////// Empty Space /////////////
        Item{
            property int columnSpanEmpty: 22
            property int rowSpanEmpty: 4

            Layout.columnSpan: columnSpanEmpty
            Layout.rowSpan: rowSpanEmpty

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanEmpty) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanEmpty) - parent.rowSpacing

            Rectangle{
                anchors.fill: parent
                radius: 7
                color: "#181818"
            }
        }

        /////////// Thermometer Image ///////////
        // Rectangle{
        //     property int columnSpanTempImg: 1
        //     property int rowSpanTempImg: 4

        //     Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanTempImg) - parent.columnSpacing
        //     Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanTempImg) - parent.rowSpacing
        //     radius: 5
        //     color: "#181818"
        //     border.color: "White"

        //     Image{
        //         anchors.fill: parent
        //         source: "qrc:/Images/Thermometer.png"
        //     }
        // }

        // Rectangle{
        //     property int columnSpanTemp: 2
        //     property int rowSpanTemp: 4

        //     Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanTemp) - parent.columnSpacing
        //     Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanTemp) - parent.rowSpacing
        //     radius: 5
        //     color: "#181818"
        //     border.color: "White"
        // }

        ///////////// Lap Control  /////////////
        Item{
            property int columnSpanLaps: 6
            property int rowSpanLaps: 4

            Layout.columnSpan: columnSpanLaps
            Layout.rowSpan: rowSpanLaps

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanLaps) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanLaps) - parent.rowSpacing

            /////// Current lap text ///////
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 2
                spacing: 1

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text{   
                        x: 15
                        text: "CURRENT LAP: " + adaptedLaps
                        font.pointSize: 12
                        font.bold: true
                        color: "white"
                    }
                }

                //////// Remaining time text ////////
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text{
                        id: remainingTimeText
                        x: 15
                        text: "REMAINING TIME: " + AuxFunctionsJs.formatTime(attemptRemainingSecs)

                        font.pointSize: 12
                        font.bold: true
                        color: "White"
                    }
                }  
            }
        } 
    }

    onAttemptCurrentLapsChanged: {
        adaptedLaps = (attemptCurrentLaps >= 4)? 5 : attemptCurrentLaps + 1;
    }

    // Change the color of remaining Time label
    onAttemptRemainingSecsChanged: {
            // Logic to change the color based on remaining seconds
            if(attemptRemainingSecs >= 600){
                remainingTimeText.color =  "Green";
            }else if (attemptRemainingSecs >= 300){
                remainingTimeText.color = "#fad20c";
            }else if (attemptRemainingSecs > 0){
                remainingTimeText.color = "Red";
            }else{
               remainingTimeText.color = "White";
            }
        }
}
