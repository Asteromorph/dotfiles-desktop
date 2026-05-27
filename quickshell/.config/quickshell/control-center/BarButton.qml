import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    // Theme — optional, falls back to Colors singleton
    property var theme: null
    readonly property color textColor: theme ? theme.textPrimary : Colors.text
    readonly property color surfaceColor: theme ? theme.bgSurface : Colors.surface
    readonly property color surfaceHoverColor: theme ? Qt.lighter(theme.bgSurface, 1.1) : Colors.surfaceHover

    implicitWidth: 40
    implicitHeight: 32
    radius: 8
    color: mouseArea.pressed
        ? root.surfaceHoverColor
        : (mouseArea.containsMouse ? root.surfaceColor : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: "\uf1de"
        font.family: "Hack Nerd Font"
        font.pixelSize: 18
        color: root.textColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ipcProcess.running = true
    }

    Process {
        id: ipcProcess
        command: ["qs", "ipc", "call", "controlCenter", "toggle"]
    }
}
