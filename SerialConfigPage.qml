import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SerialHandler

///////////////////// SERIAL CONFIG LAYOUT /////////////////////
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
        rows: 30
        columnSpacing: 0
        rowSpacing: 2

        //////// SERIAL CONFIG TITLE  ////////
        Rectangle{
            // Specify position and presentation
            property int serialTitleRowSpan: 3
            property int serialTitleColumnSpan: 30

            Layout.columnSpan: serialTitleColumnSpan
            Layout.rowSpan: serialTitleRowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * serialTitleColumnSpan)
            Layout.preferredHeight: ((parent.height / parent.rows) * serialTitleRowSpan)

            // Style
            color: "#2c2c34"
            radius: 5
            border.color: "#909090"
            // border.width: 1

            // Subpanel Title
            Text{
                anchors.centerIn: parent
                text: "SERIAL SETTINGS"
                font.pointSize: 15
                font.weight: Font.DemiBold
                color: "white"
            }
        }

        //////// SELECT BAUD RATE TITLE ////////
        GridRectAux{
            compRowSpan: 2
            compColumnSpan: 11
            color: configurePanel.panelColor
            border.color: "white"

            Text{
                anchors.verticalCenter: parent.verticalCenter
                x: 20
                text: "BAUD RATE"
                font.pointSize: 13
                font.weight: Font.Medium
                color: "white"
            }
        }

        //////// SELECT PORT TITLE ////////
        GridRectAux{
            compRowSpan: 2
            compColumnSpan: 12
            color: configurePanel.panelColor
            border.color: "white"

            Text{
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                text: "PORT"
                font.pointSize: 13
                font.weight: Font.Medium
                color: "white"
            }
        }

        ////////////// CONNECT BUTTON //////////////
        GridRectAux{
            id: connButtonContainer
            compRowSpan: 5
            compColumnSpan: 7
            color: "#252526"
            border.color: "#d0d0d0"

            states: [
                State {
                    name: "hover"
                    when: connButtonMouseArea.containsMouse && !connButtonMouseArea.pressed
                    PropertyChanges { target: connButtonContainer; color: "#3b3c3d" }
                },
                State {
                    name: "pressed"
                    when: connButtonMouseArea.pressed
                    PropertyChanges { target: connButtonContainer; color: "#808085" }
                },
                State {
                    name: "idle"
                    when: !connButtonMouseArea.released
                    PropertyChanges { target: connButtonContainer; color: "#272727" }
                }

            ]
            ///// Button Activity /////
            MouseArea {
                id: connButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                // CONNECT BUTTON is clicked
                onClicked: {
                    connectButtonClicked()              // Emit signal
                    if(!SerialHandler.isConnected()){   // If it is not already connected, attempt to connect
                        SerialHandler.configurePort(configurePanel.baudRate, configurePanel.portName);
                        SerialHandler.openPort(2);
                    }else{                              // Otherwise disconnect
                        SerialHandler.closePort();
                    }
                }
            }
            ///// Connect Button Text /////
            Text {
                text: (connectedState)? "DISCONNECT" : "CONNECT"
                anchors.centerIn: parent
                color: "white"
            }
        }

        //////// Baud rate combobox rect //////////
        Rectangle {
            // Specify position and presentation
            property int comp1RowSpan: 3
            property int comp1ColumnSpan: 11

            Layout.columnSpan: comp1ColumnSpan
            Layout.rowSpan: comp1RowSpan

            Layout.preferredWidth: ((parent.width / parent.columns) * comp1ColumnSpan) - parent.columnSpacing
            Layout.preferredHeight: ((parent.height / parent.rows) * comp1RowSpan) - parent.rowSpacing
            color: configurePanel.panelColor
            radius: 5
            border.color: "white"

            /////////// SELECT BAUD RATE DROPDOWN /////////
            ComboBox {
                id: control
                x: 10
                model: [300, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]
                currentIndex: 4   // Default to 9600

                delegate: ItemDelegate {
                    width: control.width
                    contentItem: Text {
                        text: modelData
                        color: "white"      // This is the color of the text inside the popup
                        font: control.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: control.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvas
                    x: control.width - width - control.rightPadding
                    y: control.topPadding + (control.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: control
                        function onPressedChanged() { canvas.requestPaint(); }
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = control.pressed ? "gray" : "#04f3bd";  // Triangle inside combobox to dropdown
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 10
                    rightPadding: control.indicator.width + control.spacing

                    text: control.displayText
                    font: control.font
                    color: control.pressed ? "gray" : "#04f3bd"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    color: "#303030"    // COLOR OF BACKGROUND RECTANGLE
                    border.color: control.pressed ? "gray" : "#04f3bd"
                    border.width: control.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: control.height - 1
                    height: 200
                    width: control.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: control.popup.visible ? control.delegateModel : null
                        currentIndex: control.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    // BACKGROUND OF POPUP
                    background: Rectangle {
                        color: "#303030"
                        border.color: "gray"
                        radius: 2
                    }
                }

                // ON SELECTED ITEM CHANGED BAUD RATE COMBOBOX
                onCurrentIndexChanged: {
                   configurePanel.baudRate = model[currentIndex]  // Update the global property to contain baud rate value
                }
            }
        }

        ///////////////// SELECT COM PORT DROPDOWN /////////////////
        GridRectAux{
            compRowSpan: 3
            compColumnSpan: 12
            color: configurePanel.color
            border.color: "white"

            ComboBox {
                id: portComboBox
                x: 10
                model: configurePanel.availablePorts
                currentIndex: 4   // Default to 9600

                delegate: ItemDelegate {
                    width: portComboBox.width
                    contentItem: Text {
                        text: modelData
                        color: "white"      // This is the color of the text inside the popup
                        font: portComboBox.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: portComboBox.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvasPorts
                    x: portComboBox.width - width - portComboBox.rightPadding
                    y: portComboBox.topPadding + (portComboBox.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: portComboBox
                        function onPressedChanged() { canvasPorts.requestPaint(); }
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = portComboBox.pressed ? "gray" : "#04f3bd";  // Triangle inside combobox to dropdown
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 10
                    rightPadding: portComboBox.indicator.width + portComboBox.spacing

                    text: portComboBox.displayText
                    font: portComboBox.font
                    color: portComboBox.pressed ? "gray" : "#04f3bd"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    color: "#303030"    // COLOR OF BACKGROUND RECTANGLE
                    border.color: portComboBox.pressed ? "gray" : "#04f3bd"
                    border.width: portComboBox.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: portComboBox.height - 1
                    height: 50 * configurePanel.availablePorts.length
                    width: portComboBox.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: portComboBox.popup.visible ? portComboBox.delegateModel : null
                        currentIndex: portComboBox.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    // BACKGROUND OF POPUP
                    background: Rectangle {
                        color: "#303030"
                        border.color: "gray"
                        radius: 2
                    }
                }

                // ADD THE AVAILABLE PORT NAMES INTO COMBOBOX
                Component.onCompleted: {
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

                // ON SELECTED ITEM CHANGED COM PORTS COMBOBOX
                onCurrentIndexChanged: {
                   configurePanel.portName = model[currentIndex];  // Update the global property to contain baud rate value
                }
            }
        }

        //////////////// EMPTY (GENERAL) TO STRUCTURE  ////////////////
        GridRectAux{
            compRowSpan: 22
            compColumnSpan: 30
            color: configurePanel.panelColor
        }
    }
}

