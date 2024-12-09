import QtQuick
import QtQuick.Layouts

// A component for abstracting the width and height configuration when using grid layouts, as they can add a lot of
// extra lines of code

Rectangle{
    // Specify position and presentation
    property int compRowSpan: 1
    property int compColumnSpan: 1

    Layout.columnSpan: compColumnSpan
    Layout.rowSpan: compRowSpan

    Layout.preferredWidth: ((parent.width / parent.columns) * compColumnSpan) - parent.columnSpacing
    Layout.preferredHeight: ((parent.height / parent.rows) * compRowSpan) - parent.rowSpacing

    // Standarize a radius of 5
    radius: 5
}
