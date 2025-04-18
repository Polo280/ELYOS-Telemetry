import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

////////// OTHER SETTINGS //////////
Rectangle{
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: configurePanel.panelColor
    border.color: configurePanel.borderColor
    radius: 5


    GridLayout{
        anchors.fill: parent
        anchors.margins: 2
        rowSpacing: 2
        columns: 30
        rows: 30

        ///////// TITLE /////////
        GridRectAux{
            compRowSpan: 3
            compColumnSpan: parent.columns
            color: "#1c2424"
            radius: 5
            border.color: "#909090"

            Text{
                anchors.centerIn: parent
                text: "OTHER SETTINGS"
                font.pointSize: 15
                font.weight: Font.DemiBold
                color: "white"
            }
        }

        //////// LORA SETTINGS TITLE ////////
        GridRectAux {
            compRowSpan: 12
            compColumnSpan: parent.columns
            radius: 5
            border.color: "#909090"
            color: configurePanel.color

            ////// LORA PANEL //////
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.leftMargin: 4
                rowSpacing: 7
                columns: 10
                rows: 30

                /// Top spacer
                GridRectAux {
                    compRowSpan: 1
                    compColumnSpan: parent.columns
                    color: configurePanel.color
                }

                /// LORA CONFIG TITLE //
                GridRectAux{
                    compRowSpan: 7
                    compColumnSpan: parent.columns
                    color: "#252526"
                    border.color: "#c1c5c9"

                    Text {
                        anchors.topMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        leftPadding: 15
                        text: "LORA SETTINGS"
                        font.pointSize: 14
                        color: "white"
                    }
                }


                /// TIME TO SEND SETTING CONFIG ///
                GridRectAux {
                    compRowSpan: 7
                    compColumnSpan: parent.columns
                    color: configurePanel.color
                    RowLayout {
                        anchors.fill: parent
                        anchors.rightMargin: 10
                        spacing: 3

                        //// SEND INTERVAL TEXT ////
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: configurePanel.color
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                leftPadding: 15
                                text: "SEND INTERVAL (S)"
                                font.pointSize: 13
                                color: "white"
                            }
                        }

                        //// SEND INTERVAL TEXT FIELD ////
                        TextField {
                            id: sendTextField
                            Layout.fillHeight: true
                            Layout.preferredWidth: 70
                            verticalAlignment: TextField.AlignVCenter
                            font.pointSize: 12
                            placeholderText: qsTr("2 s")
                            placeholderTextColor: sendTextField.activeFocus ? "transparent" : "white"
                            color: "white"

                            background: Rectangle {
                                color: "#191919"
                                radius: 5
                                border.color: "grey"
                            }

                            validator: IntValidator { bottom: 1 } // Only allow positive integers

                            // Remove placeholder issue when typing
                            onTextChanged: {
                                if (text.length > 0) {
                                    placeholderText = "";
                                } else {
                                    placeholderText = qsTr("2");
                                }
                            }
                        }

                    }
                }
                /// EMPTY Rect LORA Panel ///
                GridRectAux {
                    compRowSpan: 15
                    compColumnSpan: parent.columns
                    color: configurePanel.color
                }

                //////////////////////////////////////////////
            }
        }

        //////////////// EMPTY (GENERAL) TO STRUCTURE  ////////////////
        GridRectAux{
            compRowSpan: 15
            compColumnSpan: parent.columns
            color: configurePanel.panelColor
        }
    }
}
