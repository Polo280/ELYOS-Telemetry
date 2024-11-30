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
        anchors.margins: 5
        rowSpacing: 2
        columns: 30
        rows: 30

        ///////// TITLE /////////
        GridRectAux{
            compRowSpan: 3
            compColumnSpan: parent.columns
            color: "#2c2c34"
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

        //////////////// EMPTY (GENERAL) TO STRUCTURE  ////////////////
        GridRectAux{
            compRowSpan: 27
            compColumnSpan: 30
            color: configurePanel.panelColor
        }
    }
}
