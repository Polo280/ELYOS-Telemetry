/* ELYOS TELEMETRY APPLICATION V2 */

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCharts
// OTHER QT MODULES
import QtQuick 2.12
import QtLocation 5.15
import QtPositioning 5.15
// Custom QMLs
import "."  // Include same folder (imports are managed with folders)
import SerialHandler
import CsvHandler
// Global variables
import "qrc:/jsFiles/Globals.js" as GlobalsJs
import "qrc:/jsFiles/mainAuxFunctions.js" as AuxFunctionsJs

Window {
    id: root
    /////// BASIC WINDOW PROPERTIES ///////
    width: 1500
    height: 780
    visible: true
    opacity: 0.98
    color: "#272727"
    title: qsTr("ELYOS")

    ////// Define App Variables //////
    // General control
    property bool isConnected: false
    property var dataValues: []
    // Time control
    property int timeRunningAttempt: 0
    property int timeRunning: 0
    property bool timePaused: true
    property bool finishedRace: false
    // Race settings
    property int maxNumberLaps: 5
    property int attemptAvailableSecs: 1200
    // Current Status
    property int remainingTime: attemptAvailableSecs
    property int lapTimeAux: 0
    property int currentLaps: 0

    // Aliases for variables
    property alias speed: midLayoutMain.currentSpeed
    property alias distance: midLayoutMain.currentDistance
    property alias performanceValues: midLayoutMain.performanceValues
    property alias accelerations: midLayoutMain.accelerations
    property alias orientationAngles: midLayoutMain.orientationAngles

    ////// Define Signals //////
    signal resetAttemptTrigger()

    ///////////// GRID LAYOUT MAIN PANEL /////////////
    GridLayout{
        // Specify adjustment in parent item (window)
        anchors.fill: parent
        anchors.margins: 3
        // Specify layer
        z: 0
        // Rows and columns
        columns: 10
        rows: 80
        // Specify gaps between the rows and columns
        property int xSpacing: 4  // column spacing
        property int ySpacing: 0  // row spacing

        columnSpacing: xSpacing
        rowSpacing: ySpacing

        ///////////// Top Panel /////////////
        Item{
            id: topPanel
            property int columnSpanTop: 10
            property int rowSpanTop: 8

            Layout.columnSpan: columnSpanTop
            Layout.rowSpan: rowSpanTop

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanTop) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanTop) - parent.rowSpacing

            Rectangle{
                anchors.fill: parent
                radius: 7
                color: "#181818"

                ////// TOP PANEL ITEM //////
                TopPanel{
                    id: topPanelItem
                    // Properties to display attempt status
                    attemptCurrentLaps: currentLaps
                    attemptRemainingSecs: remainingTime
                    // Manage side menu bar visibility
                    onMenuButtonClicked: sideMenuBar.state = (sideMenuBar.state === "disabled")? "enabled" : "disabled"

                }
            }
        }

        //////////////// Mid panel MAIN PAGE  ////////////////
        Item{
            id: midPanel
            property int columnSpanMid: 10
            property int rowSpanMid: 69

            Layout.columnSpan: columnSpanMid
            Layout.rowSpan: rowSpanMid

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanMid) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanMid) - parent.rowSpacing

            ///// Inner layout rectangle /////
            Rectangle{
                anchors.fill: parent
                radius: 7
                color: "#181818"

                ///// Middle layout item /////
                MiddleLayout{
                    id: midLayoutMain
                    visible: true
                    // Update properties
                    lapCurrent: currentLaps; // Get the current lap
                    runningTimeAttempt: timeRunningAttempt;  // Attempt run time
                    predictedTimePerLap: (timeRunningAttempt === 0)? 0 : Math.ceil(remainingTime / (maxNumberLaps - currentLaps))

                    // Signals from map panel //
                    // Pause behavior
                    onMapPauseButtonClicked: {
                        timePaused = !timePaused;
                        if(finishedRace){
                            finishedRace = false;
                        }
                    }
                    // New lap behavior
                    onMapLapButtonClicked: {
                        // Has only effect when timer is not paused
                        if(!timePaused && !finishedRace){
                            // Evaluate current lap to decide if finish race
                            if(currentLaps > 3){
                                finishedRace = true;
                            }

                            avgSecsPerLap = (timeRunningAttempt === 0)? 0 : Math.ceil(timeRunningAttempt / (currentLaps + 1));
                            //// Map panel (bottom) ////
                            // Update the boolean array of which laps are completed
                            var newLapsCompleted = lapsCompleted.slice(); // Create a copy of the array
                            newLapsCompleted[lapCurrent] = true;
                            lapsCompleted = newLapsCompleted; // Reassign to trigger update

                            // Update current lap time to complete
                            var newLapTimesSecs = lapTimesSecs.slice(); // Create a copy of the array
                            newLapTimesSecs[lapCurrent] = timeRunningAttempt - lapTimeAux;
                            lapTimesSecs = newLapTimesSecs; // Reassign to trigger update
                            lapTimeAux = timeRunningAttempt;  // Update aux to store the time of each individual lap

                            // Update current laps
                            currentLaps = (currentLaps < maxNumberLaps)? currentLaps + 1 : maxNumberLaps;
                        }
                    }
                    // Reset behavior
                    onMapResetButtonClicked: {
                        resetAttemptTrigger()   // Handler to reset in this file
                    }
                }

                //////////////// Mid panel CONFIGURE PAGE  ////////////////
                ConfigurePage{
                    id: midPanelConfigure
                    ////// SERIAL SIGNALS /////
                    onSuccessfulConnection: isConnected = true;
                    onSuccessfulDisconnection: isConnected = false;
                }
            }
        }


        ///////////// Bottom panel  /////////////
        Item{
            id: bottomPanel
            property int columnSpanBottom: 10
            property int rowSpanBottom: 3

            Layout.columnSpan: columnSpanBottom
            Layout.rowSpan: rowSpanBottom

            Layout.preferredWidth: ((parent.width / parent.columns) * columnSpanBottom) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * rowSpanBottom) - parent.rowSpacing

            BottomPanel{
                id: bottomPanel1
                telemetryConnected: isConnected
                batteryPercentage: Math.ceil(midLayoutMain.performanceValues[1] * 2)   // ASSUMING BATTERY IS 50V NOMINAL
                                                                                   // Apply formula to find ratio
            }
        }
    }

    ///////////// SIDE MENU ITEM /////////////
    SideMenu{
        id: sideMenuBar
        // Handle exit button clicked
        onExitButtonClicked: Qt.quit()
        // Handle according to signal
        onMainPageButtonClicked: {
            midLayoutMain.visible = true;
            midPanelConfigure.state = "disabled";
        }
        onConfigButtonClicked:{
            midLayoutMain.visible = false;
            midPanelConfigure.state = "enabled";
        }
    }

    ///////////// Timer1 (1000 ms)  /////////////
    Timer {
        id: timer1
        interval: 1000  // 1000 milliseconds = 1 second
        repeat: true    // Keep repeating the timer
        running: true

        onTriggered: {
            // Update the text display with the current time
            var date = new Date();
            topPanelItem.hourText = Qt.formatTime(date, "hh:mm:ss");
            // App total run time update
            timeRunning += 1;

            // Check data gather conditions (register received data in internal lists)
            GlobalsJs.get_data_en = (isConnected && !timePaused);

            // Remaining time update (if not paused)
            if(!timePaused && !finishedRace){
                timeRunningAttempt += 1;
                remainingTime = (remainingTime === 0)? 0 : remainingTime - 1;

                // Check if AUTOSAVE interval (to csv) has ellapsed
                if(isConnected && timeRunning - GlobalsJs.autosave_time_aux >= GlobalsJs.autosave_time_secs){
                    GlobalsJs.ready_to_save = true;
                    GlobalsJs.autosave_time_aux = timeRunning;
                }

            }else{
                // Reset interval counter if app is paused or not available
                GlobalsJs.autosave_time_aux = timeRunning;
            }
        }
    }

    /////// RESET ATTEMPT HANDLER ///////
    onResetAttemptTrigger: {
        finishedRace = false;
        currentLaps = 0;
        timeRunningAttempt = 0;
        remainingTime = attemptAvailableSecs;
        midLayoutMain.avgSecsPerLap = 0;
        // Map panel bottom
        midLayoutMain.lapsCompleted = [false, false, false, false, false]
        midLayoutMain.lapTimesSecs = [0, 0, 0, 0, 0]
        lapTimeAux = 0; // Auxiliar in this file
    }

    /////////////// SERIAL MESSAGE RECEIVED ///////////////
    Connections{
        target: SerialHandler

        // Extract the different values from the message when a new string is received
        function onNewDataReceived (message){
            dataValues = message.split(",");

            // Update the variables for displaying data
            let performanceVals = [0.0, 0.0, 0.0, 0.0, 0.0];  // It seems like elements of the array cant be changed individually inside this block
            let accels = [0.0, 0.0, 0.0];
            let orientAngles = [0.0, 0.0, 0.0];
            // Adjust this depending on telemetry data format (first item is just a validation character (s))
            speed = dataValues[4];
            distance = dataValues[4];
            performanceVals[0] = dataValues[1];  // Current
            performanceVals[1] = dataValues[2];  // Voltage
            // CHANGE
            performanceVals[2] = 0;  // RPMS
            performanceVals[3] = 0;  // Consumption
            performanceVals[4] = 0;  // Efficiency
            performanceValues = performanceVals;  // Copy the whole array, not single elements
            accels[0] = dataValues[3];
            accels[1] = dataValues[4];
            accels[2] = dataValues[5];
            accelerations = accels;
            orientAngles[0] = dataValues[6];
            orientAngles[1] = dataValues[7];
            orientAngles[2] = dataValues[8];
            orientationAngles = orientAngles;

            // Append data into record lists (ADJUST INDEXES AS NEEDED) when new data is received
            if(GlobalsJs.get_data_en){
                GlobalsJs.time_record.push(timeRunningAttempt)
                GlobalsJs.current_record.push(dataValues[1]);
                GlobalsJs.voltage_record.push(dataValues[2]);
                // Accelerations
                GlobalsJs.accelX_record.push(dataValues[3]);
                GlobalsJs.accelY_record.push(dataValues[4]);
                GlobalsJs.accelZ_record.push(dataValues[5]);
            }else{
                // If get data is not enabled, discard the data that has been already stored
                GlobalsJs.time_record = [];
                GlobalsJs.current_record = [];
                GlobalsJs.voltage_record = [];
                // Accelerations
                GlobalsJs.accelX_record = [];
                GlobalsJs.accelY_record = [];
                GlobalsJs.accelZ_record = [];
            }

            // Check if data is ready to be stored
            if(GlobalsJs.ready_to_save){
                console.log("Ready")
                // The order of the sublists has to be the same as you want to store in the CSV
                GlobalsJs.main_data_store = [GlobalsJs.time_record, GlobalsJs.current_record, GlobalsJs.voltage_record,
                                             GlobalsJs.accelX_record, GlobalsJs.accelY_record, GlobalsJs.accelZ_record];
                GlobalsJs.time_record = [];
                GlobalsJs.current_record = [];
                GlobalsJs.voltage_record = [];
                // Accelerations
                GlobalsJs.accelX_record = [];
                GlobalsJs.accelY_record = [];
                GlobalsJs.accelZ_record = [];
                // Convert to string and save to CSV constantly
                CsvHandler.csvWrite(AuxFunctionsJs.convertToCsv(GlobalsJs.main_data_store));
                // Reset control variable
                GlobalsJs.ready_to_save = false;
            }
        }
    }

    //////////////////// CSV MANAGER ////////////////////
    Connections {
        id: csvHandle_conn
        target: CsvHandler

        function onCsvOpenSuccess() {
            console.log("Open success!");
        }

        function onCsvOpenFailure(errorString) {
           console.log("Failed to open csv") ;
        }
    }


    //////////////// WINDOW APP START ////////////////
    // When App starts, set the CSV path and write the header
    Component.onCompleted: {
        CsvHandler.openCsv("C:/Users/jorgl/OneDrive/Escritorio/testqt.csv");
        CsvHandler.csvWrite("Time_s,Current_amps,Voltage_V,Accel X_m/s^2,Accel Y_m/s^2,Accel Z_m/s^2\n");
    }

    //////////////////////////////////////////////////
}
