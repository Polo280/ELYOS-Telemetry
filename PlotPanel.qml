import QtQuick
import QtQuick.Layouts
import QtCharts 2.3

///////////// PLOT PANEL  /////////////
Rectangle {
    anchors.fill: parent
    anchors.margins: 1
    color: "#181818"
    // border.color: "white"
    // border.width: 1

    // Variables to update stats
    property var accelerations: [0.0, 0.0, 0.0]      // Acceleration vector [x, y, z]
    property var orientationAngles: [0.0, 0.0, 0.0]  // Orientation vector [x, y, z]

    GridLayout{
        // Specify adjustment in parent item (window)
        anchors.fill: parent
        anchors.margins: 1
        // Rows and columns
        columns: 20
        rows: 20
        // Specify gaps between the rows and columns
        property int xSpacing: 4  // column spacing
        property int ySpacing: 4  // row spacing

        columnSpacing: xSpacing
        rowSpacing: ySpacing

        ///////////// PLOT 1 LAYOUT /////////////
        Rectangle{
            // Specify position and presentation
            property int plotRowSpan: 20
            property int plotColumnSpan: 12

            Layout.columnSpan: plotColumnSpan
            Layout.rowSpan: plotRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * plotColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * plotRowSpan) - parent.rowSpacing

            color: "#181818"
            radius: 7
            border.color: "#606060"
            border.width: 1

            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 1
                spacing: 1

                //// PLOT 1 title ////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#2c2c34"
                    radius: 5
                    border.color: "#606060"
                    border.width: 1

                    // Text component for title
                    Text{
                        anchors.centerIn: parent
                        text: "CONSUMPTION STATS"
                        font.pointSize: 15
                        font.bold: false
                        font.weight: Font.DemiBold
                        color: "#3cd45c"
                    }
                }

                //// PLOT 1 container ////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#181818"
                    radius: 5
                    // border.color: "white"
                    // border.width: 1

                    ////// PLOT COMPONENT //////
                    RT_Chart{

                    }
                }
            }
        }

        ///////////////////// IMU PANEL /////////////////////
        Rectangle{
            id: imuPanel
            // Specify position and presentation
            property int plotRowSpan: 20
            property int plotColumnSpan: 8

            Layout.columnSpan: plotColumnSpan
            Layout.rowSpan: plotRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * plotColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * plotRowSpan) - parent.rowSpacing

            color: "#181818"
            radius: 7
            border.color: "#606060"
            border.width: 1

            /////////// IMU PANEL LAYOUT ///////////
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 1
                spacing: 4

                /////// IMU PANEL TITLE ///////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#2c2c34"
                    radius: 5
                    border.color: "#606060"
                    border.width: 1

                    // Text component for title
                    Text{
                        anchors.centerIn: parent
                        text: "IMU DATA"
                        font.pointSize: 15
                        font.bold: false
                        font.weight: Font.DemiBold
                        color: "Orange"
                    }
                }

                /////// GYROSCOPE TITLE  ///////
                Rectangle{
                    Layout.preferredWidth: parent.width -  listViewGyro.sideSpacing
                    Layout.preferredHeight: listViewGyro.rowHeight
                    // Layout.alignment: parent.verticalCenter
                    Layout.leftMargin: 4
                    color: "#383e45"
                    // border.color: "white"
                    radius: 5

                    Text{
                        x: 15
                        anchors.verticalCenter: parent.verticalCenter
                        text: "GYROSCOPE"
                        font.pixelSize: 15
                        font.bold: false
                        font.weight: Font.DemiBold
                        color: "White"
                    }
                }

                /////// GYROSCOPE TABLE  ///////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: (3 * listViewGyro.rowHeight) + 5
                    color: imuPanel.color
                    // border.color: "white"
                    radius: 5


                    ////////////// ELEMENTS FOR THE TABLE //////////////
                    ListView {
                        property int sideSpacing: 7
                        id: listViewGyro
                        anchors.fill: parent
                        anchors.rightMargin: sideSpacing
                        anchors.leftMargin: sideSpacing
                        clip: true  // Clipping to prevent drawing outside the bounds
                        spacing: 0  // Spacing between rows

                        // Width of every row in the table
                        property int rowHeight: 30

                        model: ListModel {
                            ListElement { name: "ROLL"; index: 0}
                            ListElement { name: "PITCH"; index: 1}
                            ListElement { name: "YAW"; index: 2}
                        }

                        delegate: Rectangle {
                            width: listViewGyro.width
                            height: listViewGyro.rowHeight
                            color: "#272727"  // Background color of each row
                            border.color: "gray"
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
                                    color: "#c1c5c9" // Text color
                                }

                                // GYROSCOPE COLUMNS
                                Text {
                                    text: orientationAngles[index] + "°"  // Get the orientation axis according to index
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                    rightPadding: 10
                                    font.pixelSize: 14
                                    color: "#c1c5c9"  // Text color
                                }
                            }
                        }
                    }
                }

                /////////// ACCELEROMETER TITLE  ///////////
                Rectangle{
                    Layout.preferredWidth: parent.width -  listViewAccel.sideSpacing
                    Layout.preferredHeight: listViewAccel.rowHeight
                    Layout.leftMargin: 4
                    color: "#383e45"
                    // border.color: "white"
                    radius: 5

                    Text{
                        x: 15
                        anchors.verticalCenter: parent.verticalCenter
                        text: "ACCELERATIONS"
                        font.pixelSize: 15
                        font.bold: false
                        font.weight: Font.DemiBold
                        color: "White"
                    }
                }

                /////// ACCELEROMETER TABLE  ///////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: (3 * listViewAccel.rowHeight) + 5
                    color: imuPanel.color
                    // border.color: "white"
                    radius: 5


                    ////////////// ELEMENTS FOR THE TABLE //////////////
                    ListView {
                        property int sideSpacing: 7
                        id: listViewAccel
                        anchors.fill: parent
                        anchors.rightMargin: sideSpacing
                        anchors.leftMargin: sideSpacing
                        clip: true  // Clipping to prevent drawing outside the bounds
                        spacing: 0  // Spacing between rows

                        // Width of every row in the table
                        property int rowHeight: 30

                        model: ListModel {
                            ListElement { name: "ACCEL X"; index: 0}
                            ListElement { name: "ACCEL Y"; index: 1}
                            ListElement { name: "ACCEL Z"; index: 2}
                        }

                        delegate: Rectangle {
                            width: listViewAccel.width
                            height: listViewAccel.rowHeight
                            color: "#272727"  // Background color of each row
                            border.color: "gray"
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
                                    color: "#c1c5c9" // Text color
                                }

                                // ACCELERATION COLUMNS
                                Text {
                                    text: accelerations[index] + " m/s2"  // Get the orientation axis according to index
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                    rightPadding: 10
                                    font.pixelSize: 14
                                    color: "#c1c5c9"  // Text color
                                }
                            }
                        }
                    }
                }

                ///////// EMPTY RECTANGLE TO FILL LAYOUT /////////
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: imuPanel.color
                }

            }
        }

        // Rectangle{
        //     // Specify position and presentation
        //     property int plotRowSpan: 20
        //     property int plotColumnSpan: 0

        //     Layout.columnSpan: plotColumnSpan
        //     Layout.rowSpan: plotRowSpan

        //     Layout.preferredWidth: ((parent.width / parent.columns) * plotColumnSpan) - parent.columnSpacing
        //     Layout.preferredHeight: ((parent.height / parent.rows) * plotRowSpan) - parent.rowSpacing

        //     color: "#181818"
        //     radius: 7
        //     border.color: "White"
        //     border.width: 1
        // }
    }
}
