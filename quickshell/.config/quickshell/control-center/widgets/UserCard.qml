import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property string username: "user"
    property string avatarPath: "file:///home/" + username + "/.face.jpg"
    property string uptime: "up 00:00:00"

    // Theming
    property color surfaceColor: Colors.surface
    property color surfaceHoverColor: Colors.surfaceHover
    property color borderColor: Colors.borderSubtle
    property color textColor: Colors.text
    property color textSecondaryColor: Colors.textSecondary
    property color accentColor: Colors.accent
    property color dangerColor: Colors.danger

    signal settingsClicked()
    signal powerClicked()

    radius: 10
    color: root.surfaceColor
    border.color: root.borderColor
    border.width: 1
    implicitHeight: 64

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
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: 22
            color: root.accentColor
            clip: true

            Image {
                id: avatarImage
                anchors.fill: parent
                source: root.avatarPath
                fillMode: Image.PreserveAspectCrop
                onStatusChanged: if (status === Image.Error) visible = false
            }

            Text {
                anchors.centerIn: parent
                visible: avatarImage.status === Image.Error || avatarImage.status === Image.Null
                text: root.username.charAt(0).toUpperCase()
                color: root.surfaceColor
                font.pixelSize: 20
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: root.username
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
                font.family: "Hack Nerd Font"
            }

            Text {
                text: root.uptime
                color: root.textSecondaryColor
                font.pixelSize: 12
                font.family: "Hack Nerd Font"
            }
        }

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: settingsMouse.pressed ? root.surfaceHoverColor : "transparent"

            Text {
                anchors.centerIn: parent
                text: "\uf013"
                font.family: "Hack Nerd Font"
                font.pixelSize: 18
                color: root.textSecondaryColor
            }

            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.settingsClicked()
            }
        }

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: powerMouse.pressed ? root.dangerColor : "transparent"

            Behavior on color { ColorAnimation { duration: 80 } }

            Text {
                anchors.centerIn: parent
                text: "\uf011"
                font.family: "Hack Nerd Font"
                font.pixelSize: 18
                color: root.textSecondaryColor
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
