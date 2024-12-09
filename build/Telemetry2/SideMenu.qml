import QtQuick
import QtQuick.Layouts

///////////// SIDE MENU QML /////////////
Item {
    anchors.fill: parent
    property int transitionDurationMs: 150  // Adjust transition duration as needed
    property int menuButtonsHeight: 50
    property int fontSizePt: 15
    property bool fontIsBold: false

    // Define Signals
    signal somethingClicked()
    signal mainPageButtonClicked()
    signal configButtonClicked()
    signal statsButtonClicked()
    signal exitButtonClicked()

   // Create overlapping Rectangle for sidebar
   Rectangle {
       // Adjust side menu width as needed
       property int menuWidth: 350
       id: sideMenuRect
       visible: false // Not visible unless triggered via button
       z: 1           // Ensure it is above the middle panel

       // Adjust size and position
       height: parent.height - topPanel.height - 5
       width: menuWidth
       x: 0; y: topPanel.height + 5

       // Define color and appearance
       color: "#181818"
       opacity: 0.97
       radius: 5
       border.color: "#d0d0d0"
       border.width: 1
       // Set an initial state
       state: "enabled"

       /////////// MENU ITEMS ///////////
       ColumnLayout{
           anchors.fill: parent
           anchors.margins: 25
           spacing: 3

           //////// Properties of individual buttons to use a repeater ////////
           ListModel {
               id: buttonModel
               ListElement { buttonText: "MAIN PAGE"; action: "mainPageButtonClicked"}
               ListElement { buttonText: "CONFIGURATION"; action: "configButtonClicked" }
               ListElement { buttonText: "STATS"; action: "statsButtonClicked" }
           }

           //////// Repeat same button template ////////
           Repeater {
               model: buttonModel
               delegate: Component {

                   /////// Button Template ///////
                   Rectangle {
                       Layout.fillWidth: true
                       Layout.preferredHeight: menuButtonsHeight
                       color: buttonMouseArea.containsMouse ? "#363640" : "#181818"
                       radius: 7

                       MouseArea {
                           id: buttonMouseArea
                           anchors.fill: parent
                           hoverEnabled: true
                           onClicked: {
                               // Call this signal independentely of the button clicked
                               somethingClicked()

                               // Emit signals based on condition
                               if (model.buttonText === "MAIN PAGE") {
                                   mainPageButtonClicked()
                               } else if (model.buttonText === "CONFIGURATION") {
                                   configButtonClicked()
                               } else if (model.buttonText === "STATS"){
                                   statsButtonClicked()
                               }
                           }
                       }
                       // Individual button text
                       Text {
                           anchors.centerIn: parent
                           text: model.buttonText
                           font.pointSize: fontSizePt
                           font.bold: fontIsBold
                           color: "white"
                       }
                   }
               }
           }

           //////// Fill Empty Space ////////
           Rectangle {
               Layout.fillWidth: true
               Layout.fillHeight: true
               radius: 7  // Rounded corners
               color: "#181818"
               // border.color: "#d0d0d0"
               // border.width: 1
           }

           /////////// Exit Button  ///////////
           Rectangle {
               Layout.fillWidth: true
               Layout.preferredHeight: menuButtonsHeight
               color: exitMouseArea.containsMouse ? "#505050" : "#363640"
               radius: 7

               MouseArea {
                   id: exitMouseArea
                   anchors.fill: parent
                   hoverEnabled: true
                   onClicked: {
                       // Call exit signal
                       exitButtonClicked()
                   }
               }
               // Individual button text
               Text {
                   anchors.centerIn: parent
                   text: "EXIT"
                   font.pointSize: fontSizePt
                   font.bold: fontIsBold
                   color: "white"
               }
           }
       }
   }

   // Define Menu states
   states: [
      // Disabled State (not visible)
      State{
           name: "disabled"
           PropertyChanges {
               target: sideMenuRect
               width: 5
               visible: false
           }
       },

       // Enabled State (visible)
       State{
            name: "enabled"
            PropertyChanges {
                target: sideMenuRect
                width: menuWidth
                visible: true
            }
        }
   ]

   // Define transitions disabled<->enabled
   transitions: [
      Transition{
         from: "disabled"
         to: "enabled"

         NumberAnimation {
             property: "width"
             duration: transitionDurationMs
         }
         PropertyAction {
             property: "visible"
             value: true
         }
      },

       Transition{
          from: "enabled"
          to: "disabled"

          SequentialAnimation{   // Sequential to avoid it dissapearing immediately
              NumberAnimation {
                  property: "width"
                  duration: transitionDurationMs
              }
              PropertyAction {
                  property: "visible"
                  value: false
              }
          }
       }
   ]
}
