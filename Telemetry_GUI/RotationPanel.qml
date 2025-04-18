import QtQuick
import QtQuick.Layouts

///////////// Rotation Panel Layout QML /////////////
Rectangle {
    anchors.fill: parent
    // Properties of main rectangle for panel
    // border.color: "#d0d0d0"
    // border.width: 1
    color: "#181818"
    radius: 5

    // External layout
    ColumnLayout{
        // Configuration
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        ///// PANEL TITLE /////
        Rectangle{
            anchors.margins: 25
            height: 50 + 25
            Layout.fillWidth: true
            color: "#181818"
            radius: 5
            // border.color: "#d0d0d0"
            // border.width: 1

            Text{
                anchors.centerIn: parent
                text: "CAR STATUS"
                font.pointSize: 22
                font.bold: false
                color: "white"
            }
        }

        ///// GUBI IMAGE /////
        Rectangle{
            height: gubiImage.height + 60
            Layout.fillWidth: true
            color: "#181818"
            // border.color: "blue"
            // border.width: 1

            Image{
                id: gubiImage
                anchors.centerIn: parent
                source: "qrc:/Images/Gubi.png"
            }
        }

        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#181818"
            // border.color: "blue"
            // border.width: 1
        }
    }
}
