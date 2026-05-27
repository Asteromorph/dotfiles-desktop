import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string currentDevice: "Built-in Audio Analog Stereo"

    property color surfaceColor: Colors.surface
    property color surfaceElevatedColor: Colors.surfaceElevated
    property color surfaceHoverColor: Colors.surfaceHover
    property color borderColor: Colors.borderSubtle
    property color textColor: Colors.text

    signal openSettings()

    radius: 10
    color: root.surfaceColor
    border.color: root.borderColor
    border.width: 1
    implicitHeight: contentLayout.implicitHeight + 24

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "\uf130"       // microphone icon
                font.family: "Hack Nerd Font"
                font.pixelSize: 17
                color: root.textColor
            }
            Text {
                text: "Sound Input"
                color: root.textColor
                font.pixelSize: 14
                font.bold: true
                font.family: "Hack Nerd Font"
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 8
            color: root.surfaceElevatedColor
            border.color: root.borderColor
            border.width: 1
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                Text { text: "\uf130"; font.family: "Hack Nerd Font"; font.pixelSize: 15; color: root.textColor }
                Text {
                    text: root.currentDevice
                    color: root.textColor
                    font.pixelSize: 13
                    font.family: "Hack Nerd Font"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text { text: "\uf00c"; font.family: "Hack Nerd Font"; font.pixelSize: 15; color: root.textColor }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 8
            color: settingsMouse.pressed ? root.surfaceHoverColor : root.surfaceElevatedColor
            border.color: root.borderColor
            border.width: 1
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10
                Text { text: "\uf013"; font.family: "Hack Nerd Font"; font.pixelSize: 15; color: root.textColor }
                Text {
                    text: "Sound Settings"
                    color: root.textColor
                    font.pixelSize: 13
                    font.family: "Hack Nerd Font"
                    Layout.fillWidth: true
                }
            }
            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openSettings()
            }
        }
    }
}
