import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    // Content
    property string label: "Label"
    property string iconText: ""
    property bool showChevron: true
    property bool showStatusDot: false
    property color statusDotColor: Colors.accent
    property bool active: false

    // Theming (set from parent)
    property color surfaceColor: Colors.surface
    property color surfaceHoverColor: Colors.surfaceHover
    property color surfaceElevatedColor: Colors.surfaceElevated
    property color borderColor: Colors.borderSubtle
    property color textColor: Colors.text
    property color textSecondaryColor: Colors.textSecondary

    signal clicked()

    implicitHeight: 42
    radius: 10
    color: mouseArea.pressed
        ? root.surfaceHoverColor
        : (active ? root.surfaceElevatedColor : root.surfaceColor)
    border.color: root.borderColor
    border.width: 1

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 10

        Rectangle {
            visible: root.showStatusDot
            width: 10
            height: 10
            radius: 5
            color: root.statusDotColor
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.iconText !== "" && !root.showStatusDot
            text: root.iconText
            font.family: "Hack Nerd Font"
            font.pixelSize: 18
            color: root.textColor
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.label
            color: root.textColor
            font.pixelSize: 13
            font.family: "Hack Nerd Font"
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.showChevron
            text: "\uf054"
            font.family: "Hack Nerd Font"
            font.pixelSize: 14
            color: root.textSecondaryColor
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
