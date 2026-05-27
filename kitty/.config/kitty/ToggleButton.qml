import QtQuick
import QtQuick.Layouts

// Pill-shaped button used for the AirFiber / Noisy / Recording rows.
// The status dot is optional (used for Recording in the screenshot).

Rectangle {
    id: root

    property string label: "Label"
    property string iconText: ""          // Nerd Font glyph
    property bool showChevron: true       // right-arrow indicator
    property bool showStatusDot: false    // bullet dot on the left
    property color statusDotColor: Colors.accent
    property bool active: false           // toggled-on visual state

    signal clicked()

    implicitHeight: 38
    radius: 10
    color: mouseArea.pressed
        ? Colors.surfaceHover
        : (active ? Colors.surfaceElevated : Colors.surface)
    border.color: Colors.borderSubtle
    border.width: 1

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 8

        // Optional status dot
        Rectangle {
            visible: root.showStatusDot
            width: 8
            height: 8
            radius: 4
            color: root.statusDotColor
            Layout.alignment: Qt.AlignVCenter
        }

        // Icon
        Text {
            visible: root.iconText !== "" && !root.showStatusDot
            text: root.iconText
            font.family: "Hack Nerd Font"
            font.pixelSize: 14
            color: Colors.text
            Layout.alignment: Qt.AlignVCenter
        }

        // Label
        Text {
            text: root.label
            color: Colors.text
            font.pixelSize: 13
            font.family: "Hack Nerd Font"
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        // Chevron
        Text {
            visible: root.showChevron
            text: ""   // Nerd Font chevron-right
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            color: Colors.textSecondary
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
