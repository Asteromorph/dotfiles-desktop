import QtQuick
import QtQuick.Layouts

// Drop this into your bar QML wherever you want the toggle.
// Or use the Hyprland keybind below to toggle without a bar button.

Rectangle {
    id: root
    implicitWidth: 36
    implicitHeight: 28
    radius: 8
    color: mouseArea.pressed
        ? Colors.surfaceHover
        : (mouseArea.containsMouse ? Colors.surface : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: ""   // sliders icon — pick a Nerd Font glyph you like
        font.family: "Hack Nerd Font"
        font.pixelSize: 14
        color: Colors.text
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
