import QtQuick
import QtQuick.Layouts

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
            color: "#2c2c34"
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
