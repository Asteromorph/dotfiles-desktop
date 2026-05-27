import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// User card: avatar + username + uptime + settings/power buttons.

Rectangle {
    id: root

    property string username: "user"
    property string avatarPath: "file:///home/" + username + "/.face.jpg"
    property string uptime: "up 00:00:00"

    signal settingsClicked()
    signal powerClicked()

    radius: 10
    color: Colors.surface
    border.color: Colors.borderSubtle
    border.width: 1
    implicitHeight: 60

    // Poll uptime every 30s
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProcess.running = true
    }

    Process {
        id: uptimeProcess
        command: ["sh", "-c", "uptime -p | sed 's/^up //'"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") root.uptime = "up " + text.trim()
            }
        }
    }

    // Username from $USER on startup
    Process {
        id: userProcess
        command: ["sh", "-c", "echo $USER"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") root.username = text.trim()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 10

        // Avatar
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            radius: 20
            color: Colors.accentDim
            clip: true

            Image {
                anchors.fill: parent
                source: root.avatarPath
                fillMode: Image.PreserveAspectCrop
                onStatusChanged: if (status === Image.Error) visible = false
            }

            // Fallback initial if no avatar
            Text {
                anchors.centerIn: parent
                visible: parent.children[0].status === Image.Error
                text: root.username.charAt(0).toUpperCase()
                color: Colors.accentText
                font.pixelSize: 18
                font.bold: true
            }
        }

        // Username + uptime
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: root.username
                color: Colors.text
                font.pixelSize: 13
                font.bold: true
                font.family: "Hack Nerd Font"
            }

            Text {
                text: root.uptime
                color: Colors.textSecondary
                font.pixelSize: 11
                font.family: "Hack Nerd Font"
            }
        }

        // Settings button
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: settingsMouse.pressed ? Colors.surfaceHover : "transparent"

            Text {
                anchors.centerIn: parent
                text: ""   // gear
                font.family: "Hack Nerd Font"
                font.pixelSize: 14
                color: Colors.textSecondary
            }

            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.settingsClicked()
            }
        }

        // Power button
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: powerMouse.pressed ? Colors.danger : "transparent"

            Behavior on color { ColorAnimation { duration: 80 } }

            Text {
                anchors.centerIn: parent
                text: "⏻"   // power
                font.family: "Hack Nerd Font"
                font.pixelSize: 14
                color: Colors.textSecondary
            }

            MouseArea {
                id: powerMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.powerClicked()
            }
        }
    }
}
