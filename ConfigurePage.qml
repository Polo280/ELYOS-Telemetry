import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SerialHandler

Rectangle {
    id: configurePanel
    // Properties
    property string panelColor: "#181818"
    property string borderColor: "#606060"
    // Functional properties
    property int baudRate: 9600
    property string portName: "DEF_COM"
    property var availablePorts: []          // Stores the available COM port names
    property bool connectedState: false      // Is base station currently connected?
    // Signals
    signal connectButtonClicked()
    signal successfulConnection()
    signal successfulDisconnection()

    anchors.fill: parent
    anchors.margins: 3
    color: panelColor
    state: "disabled"  // Default initial state

    /////// SERIAL HANDLER EVENTS ///////
    Connections{
        target: SerialHandler

        function onConnected(){
            // console.log("Succesfully connected")
            successfulConnection()
        }
        function onDisconnected(){
            // console.log("Disconnected")
            successfulDisconnection()
        }
        function onErrorOccurred(){
            // console.log(errorMessage)
        }
    }

    ///////////////////// MAIN LAYOUT /////////////////////
    RowLayout{
        id: mainLayout
        property int numCols: 3   // Number of subpanels in main panel
        anchors.fill: parent
        anchors.margins: 3
        spacing: 10

        ////////// GENERAL PARAMETERS CONFIG LAYOUT //////////
        Rectangle{
            Layout.fillHeight: true
            Layout.preferredWidth: mainLayout.width / mainLayout.numCols
            color: configurePanel.panelColor
            border.color: configurePanel.borderColor
            radius: 7

            GridLayout{
                // Configuration
                anchors.fill: parent
                anchors.margins: 5
                // Cols and rows configurations
                columns: 30
                rows: 20
                columnSpacing: 3
                rowSpacing: 3

                //////// GENERAL CONFIG TITLE  ////////
                Rectangle{
                    // Specify position and presentation
                    property int generalTitleRowSpan: 2
                    property int generalTitleColumnSpan: 30

                    Layout.columnSpan: generalTitleColumnSpan
                    Layout.rowSpan: generalTitleRowSpan

                    Layout.preferredWidth: ((parent.width / parent.columns) * generalTitleColumnSpan)
                    Layout.preferredHeight: ((parent.height / parent.rows) * generalTitleRowSpan)

                    // Style
                    color: "#1c2424"
                    radius: 5
                    border.color: "#909090"
                    // border.width: 1

                    // PANEL TITLE
                    Text{
                        anchors.centerIn: parent
                        text: "GENERAL SETTINGS"
                        font.pointSize: 15
                        font.weight: Font.DemiBold
                        color: "white"
                    }
                }

                //////// EMPTY (GENERAL) TO STRUCTURE  ////////
                GridRectAux{
                    compRowSpan: 18; compColumnSpan: 30
                    color: configurePanel.panelColor
                }
                ////////////////////////////////////////////////
            }
        }

        ///////////////////// SERIAL CONFIG LAYOUT /////////////////////
        SerialConfigPage{
        }

        /////////////////////  OTHER CONFIG LAYOUT /////////////////////
        OtherSettings{
        }
    }

    ////// Define Page states //////
    states: [
       // Disabled State (not visible)
       State{
            name: "disabled"
            PropertyChanges {
                target: configurePanel
                visible: false
            }
        },
        // Enabled State (visible)
        State{
             name: "enabled"
             PropertyChanges {
                 target: configurePanel
                 visible: true
             }
         }
    ]

    onSuccessfulConnection: connectedState = true;
    onSuccessfulDisconnection: connectedState = false;

    // Timer to control this panel
    Timer{
        id: configurePanelTimer
        interval: 1000
        repeat: true
        running: true

        onTriggered: {
            var aux = SerialHandler.getAvailablePorts();
            var coms = [];
            for(var i = 0; i < aux.length; i++){
                coms.push(aux[i]["name"])
            }
            if(coms.length == 0){
                coms.push("NO PORTS")
            }
            configurePanel.availablePorts = coms;
        }
    }
}
