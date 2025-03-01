import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtLocation 5.15
import QtPositioning 5.15
import SerialHandler
import "qrc:/jsFiles/mainAuxFunctions.js" as AuxFunctionsJs

///////////// MAP PANEL  /////////////

Rectangle {
    // Positioning
    anchors.fill: parent
    anchors.topMargin: 10
    anchors.leftMargin: 5
    anchors.rightMargin: 5
    anchors.bottomMargin: 5
    // Style
    color: "#363638"
    radius: 5

    // Properties -> TIME CONTROL
    property int runningTimeAttempt: 0
    property int avgSecsPerLap: 0
    property int predictedSecsPerLap: 0
    // Properties -> RACE CONDITIONS
    property var lapTimesSecs: [0, 0, 0, 0, 0]
    property var lapsCompleted: [false, false, false, false, false]
    property int lapCurrent: 0

    // Define component signals
    signal lapButtonClicked()
    signal pauseButtonClicked()
    signal resetButtonClicked()

    // External layout
    GridLayout{
        // Configuration
        anchors.fill: parent
        anchors.margins: 0
        // Cols and rows configurations
        columns: 10
        rows: 20
        columnSpacing: 3
        rowSpacing: 3

        ///// MAP LAYOUT  /////
        Rectangle{
            // Specify position and presentation
            property int mapRowSpan: 11
            property int mapColumnSpan: parent.columns

            Layout.columnSpan: mapColumnSpan
            Layout.rowSpan: mapRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * mapColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * mapRowSpan) - parent.rowSpacing

            // Style
            color: "#363638"
            radius: 5
            border.width: 1
            clip: true

            /////////// OFFLINE MAP COMPONENT ///////////
            Map {
                id: map
                width: Math.sqrt(Math.pow(parent.width, 2) + Math.pow(parent.height, 2))
                height: width
                anchors.centerIn: parent
                activeMapType: map.supportedMapTypes[0]
                zoomLevel: 15

                center: QtPositioning.coordinate(39.795017, -86.234566) // Center the map on this location

                plugin: Plugin {
                    name: 'osm';
                    // Load offline tiles (already loaded into resources.qrc file)
                    PluginParameter {
                        name: 'osm.mapping.offline.directory'
                        value: ':/offline_tiles/'
                        // value: "C:/Users/jorgl/OneDrive/Escritorio/OfficialMap/offline_tiles"
                    }

                    // PluginParameter {
                    //     name: "osm.mapping.cache.directory"
                    //     value: "C:/Users/jorgl/OneDrive/Escritorio/OfficialMap/offline_tiles"
                    // }

                    PluginParameter {
                      name: "osm.mapping.providersrepository.disabled"
                      value: true
                   }
                }

                transform: Rotation{
                    angle: -90
                    origin.x: map.width / 2
                    origin.y: map.height / 2
                }

                // Add location point
                MapQuickItem {
                    id: marker
                    visible: false
                    anchorPoint.x: icon.width / 2
                    anchorPoint.y: icon.height
                    coordinate: QtPositioning.coordinate(39.799286, -86.235049)

                    sourceItem: Image {
                        id: icon
                        source: "qrc:/Images/MapMarker.svg"
                        width: 32
                        height: 48
                    }

                    transform: Rotation{
                        angle: 90
                        origin.x: icon.width / 2
                        origin.y: icon.height
                    }
                }
            }

            Connections {
                target: SerialHandler

                function onNewDataReceived(message){
                    // console.log(root.dataValues)
                    // CHANGE THIS ACCORDINGLY TO SENDING FORMAT
                    let latitude = root.dataValues[9];
                    let longitude = root.dataValues[10];
                    // console.log(latitude + "," + longitude)
                    if(latitude === 0.0 || longitude === 0.0){
                        marker.visible = false;
                    }else{
                        marker.visible = true;
                    }

                    marker.coordinate = QtPositioning.coordinate(latitude, longitude);
                }
            }
        }

        //////////// MAP PANEL BOTTOM  ////////////
        Rectangle{
            // Specify position and presentation
            property int g2TitleRowSpan: 9
            property int g2TitleColumnSpan: parent.columns

            Layout.columnSpan: g2TitleColumnSpan
            Layout.rowSpan: g2TitleRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * g2TitleColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * g2TitleRowSpan) - parent.rowSpacing

            // Style
            color: "#363640"
            radius: 5
            // border.color: "blue"
            // border.width: 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            /////// BOTTOM MAP LAYOUT ///////
            GridLayout{
                // Configuration
                anchors.fill: parent
                anchors.margins: 2
                // Cols and rows configurations
                columns: 20
                rows: 10
                columnSpacing: 1
                rowSpacing: 4

                /////// MINI PANEL 1 BOTTOM -> Time control ///////
                Rectangle{
                    id: timeControlPanel
                    // Specify position and presentation
                    property int mapDataRowSpan: 10
                    property int mapDataColumnSpan: 8
                    property string panelColor: "#303030"

                    Layout.columnSpan: mapDataColumnSpan
                    Layout.rowSpan: mapDataRowSpan

                    Layout.preferredWidth: ((parent.width / parent.columns) * mapDataColumnSpan) - parent.columnSpacing
                    Layout.preferredHeight: ((parent.height / parent.rows) * mapDataRowSpan) - parent.rowSpacing

                    // Style
                    color: panelColor
                    radius: 5
                    border.color: "#959595"
                    border.width: 1

                    //////// Internal Panel Layout ////////
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 7
                        //////// Properties of individual labels to use a repeater ////////
                        ListModel {
                            id: timeControlModel
                            ListElement {labelText: "TIME CONTROL"}
                            ListElement {labelText: "RUNNING TIME:   "}
                            ListElement {labelText: "AVERAGE TIME/LAP:   "}
                            ListElement {labelText: "TARGET TIME/LAP:   "}
                        }

                        // REPEAT labels in this mini panel
                        Repeater {
                            model: timeControlModel                            
                            delegate: Component {

                                Rectangle{
                                    Layout.preferredHeight: model.labelText === "TIME CONTROL" ? 50 : 30
                                    Layout.fillWidth: true
                                    color: (model.labelText === "TIME CONTROL")? "#181818" : "#272727"  // Change color for title container
                                    border.color: model.labelText === "TIME CONTROL" ? "#959595" : "gray"

                                    radius: 5

                                    // Labels
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        // Only center title
                                        anchors.horizontalCenter: model.labelText === "TIME CONTROL" ? parent.horizontalCenter : undefined
                                        // Text other than title
                                        x: model.labelText !== "TIME CONTROL" ? 10 : 0
                                        // Handle text logic
                                        text: model.labelText
                                        color: model.labelText === "TIME CONTROL" ? "#4977e3" : "#c1c5c9"
                                        font.pointSize: model.labelText === "TIME CONTROL" ? 14 : 11
                                        //font.weight: (model.labelText === "TIME CONTROL")? Font.Medium : Font.DemiBold
                                    }

                                    // Numbers
                                    Text {
                                        Layout.fillWidth: true
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.pointSize: 11
                                        rightPadding: 10
                                        color: "#c1c5c9"

                                        text: {
                                            if(model.labelText === "AVERAGE TIME/LAP:   "){
                                                AuxFunctionsJs.formatTime(avgSecsPerLap)
                                            }else if (model.labelText === "RUNNING TIME:   "){
                                                AuxFunctionsJs.formatTime(runningTimeAttempt)
                                            }else if (model.labelText === "TARGET TIME/LAP:   "){
                                                AuxFunctionsJs.formatTime(predictedSecsPerLap)
                                            }else{
                                                ""
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        /////// Empty rectangle time control layout ///////
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            // Style
                            color: timeControlPanel.panelColor
                            radius: 0
                        }
                    }
                }
/////////////////////////////////////////////////////////////////////////////////////////////
                /////// MINI PANEL 2 BOTTOM -> Track conditions  ///////
                Rectangle{
                    // Specify position and presentation
                    property int mapData2RowSpan: 10
                    property int mapData2ColumnSpan: 8

                    Layout.columnSpan: mapData2ColumnSpan
                    Layout.rowSpan: mapData2RowSpan

                    Layout.preferredWidth: ((parent.width / parent.columns) * mapData2ColumnSpan) - parent.columnSpacing
                    Layout.preferredHeight: ((parent.height / parent.rows) * mapData2RowSpan) - parent.rowSpacing
                    anchors.margins: 3

                    // Style
                    color: "#303030"
                    radius: 5
                    border.color: "#959595"
                    border.width: 1

                    //////// Internal Panel Layout ////////
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: 1
                        spacing: 3

                        ////////// TITLE RACE CONDITIONS //////////
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: "#181818"
                            border.color: "#959595"
                            radius: 5

                            Text{
                                anchors.centerIn: parent
                                color: "#4977e3"
                                text: "RACE PROGRESS"
                                font.pointSize: 14
                                font.weight: Font.Medium
                            }
                        }

                        ////////////// CHART FOR SHOWING LAP TIMES  //////////////
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: (5 * listView.rowHeight) + 5
                            color: timeControlPanel.panelColor
                            radius: 5


                            ListView {
                                id: listView
                                anchors.fill: parent
                                anchors.margins: 3
                                anchors.rightMargin: 7
                                anchors.leftMargin: 7
                                clip: true  // Clipping to prevent drawing outside the bounds
                                spacing: 0  // Spacing between rows

                                // Width of every row in the table
                                property int rowHeight: 27

                                model: ListModel {
                                    ListElement { name: "LAP 1"; index: 0; completed: false}
                                    ListElement { name: "LAP 2"; index: 1; completed: false}
                                    ListElement { name: "LAP 3"; index: 2; completed: false}
                                    ListElement { name: "LAP 4"; index: 3; completed: false}
                                    ListElement { name: "LAP 5"; index: 4; completed: false}
                                }

                                delegate: Rectangle {
                                    width: listView.width
                                    height: listView.rowHeight
                                    color: (index === lapCurrent)? "#323d47" : "#272727"  // Background color of each row
                                    border.color: "gray"
                                    radius: 2

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
                                            color: (lapsCompleted[index])? "Green" :  "#c1c5c9" // Text color
                                        }

                                        // Lap Time columns
                                        Text {
                                            id: lapTimeCol
                                            text: AuxFunctionsJs.formatTime(lapTimesSecs[index])
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                            verticalAlignment: Text.AlignVCenter
                                            rightPadding: 10
                                            font.pixelSize: 14
                                            color: (lapsCompleted[index])? "Green" :  "#c1c5c9"  // Text color
                                        }
                                    }
                                }
                            }
                        }
                        /////// Empty rectangle time control layout ///////
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            // Style
                            color: timeControlPanel.panelColor
                            radius: 0
                        }
                    }
                }

                /////// MINI PANEL 3 BOTTOM ///////
                Rectangle{
                    id: buttonPanelContainer
                    // Specify position and presentation
                    property int mapButtonsRowSpan: 10
                    property int mapButtonsColumnSpan: 4
                    property string panelColor: "#303030"

                    Layout.columnSpan: mapButtonsColumnSpan
                    Layout.rowSpan: mapButtonsRowSpan

                    Layout.preferredWidth: ((parent.width / parent.columns) * mapButtonsColumnSpan) - parent.columnSpacing
                    Layout.preferredHeight: ((parent.height / parent.rows) * mapButtonsRowSpan) - parent.rowSpacing

                    // Style
                    color: panelColor
                    radius: 6
                    border.color: "#959595"
                    border.width: 1

                    ///////// BUTTON LAYOUT ////////
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.topMargin: 15
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 8

                        //////// Properties of individual buttons to use a repeater ////////
                        ListModel {
                            id: buttonModel
                            ListElement { buttonText: "START"; action: "pauseButtonClicked"; textColor: "Green"}
                            ListElement { buttonText: "NEW LAP"; action: "lapButtonClicked"; textColor: "White"}
                            ListElement { buttonText: "RESET"; action: "resetButtonClicked"; textColor: "White"}
                        }

                        //////// Repeat same button template ////////
                        Repeater {
                            model: buttonModel
                            delegate: Component {
                                Rectangle {
                                    id: buttonContainer
                                    Layout.preferredHeight: 60
                                    Layout.fillWidth: true
                                    color: "#272727"  // default color
                                    radius: 7
                                    border.color: "#505050"
                                    border.width: 1

                                    MouseArea {
                                        id: buttonMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true

                                        // Define states based on mouse presence and press
                                        states: [
                                            State {
                                                name: "hover"
                                                when: buttonMouseArea.containsMouse && !buttonMouseArea.pressed
                                                PropertyChanges { target: buttonContainer; color: "#3b3c3d" }
                                            },
                                            State {
                                                name: "pressed"
                                                when: buttonMouseArea.pressed
                                                PropertyChanges { target: buttonContainer; color: "#808085" }
                                            },
                                            State {
                                                name: "idle"
                                                when: !buttonMouseArea.released
                                                PropertyChanges { target: buttonContainer; color: "#272727" }
                                            }

                                        ]

                                        // Define transitions for smooth color change
                                        transitions: [
                                            Transition {
                                                from: "*"
                                                to: "hover"
                                                ColorAnimation { property: "color"; duration: 100 }
                                            },
                                            Transition {
                                                from: "hover"
                                                to: "pressed"
                                                ColorAnimation { property: "color"; duration: 100 }
                                            },
                                            Transition {
                                                from: "*"
                                                to: "idle"
                                                ColorAnimation { property: "color"; duration: 100 }
                                            }
                                        ]

                                        // Define behaviors on clicked
                                        onClicked: {
                                            // console.log("Map button clicked!");
                                            if (model.buttonText === "NEW LAP") {
                                                lapButtonClicked()
                                            } else if (model.buttonText === "PAUSE") {
                                                pauseButtonClicked()
                                                model.buttonText = "START"
                                                model.textColor = "Green"
                                            } else if (model.buttonText === "START") {
                                                pauseButtonClicked()
                                                model.buttonText = "PAUSE"
                                                model.textColor = "Red"
                                            } else if(model.buttonText === "RESET"){
                                                resetButtonClicked()
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.buttonText
                                        color: model.textColor
                                        font.pointSize: 12
                                        font.bold: false
                                    }
                                }
                            }
                        }

                        /////// Empty rectangle button layout ///////
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            // Style
                            color: buttonPanelContainer.panelColor
                            radius: 0
                        }
                    }
                }
            }
        }
    }
}
