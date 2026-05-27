import QtQuick
import QtQuick.Layouts

// The "Sound Output" card that expands below the volume slider.
// Shows current device + a Sound Settings link.

Rectangle {
    id: root

    property string currentDevice: "Built-in Audio Analog Stereo"
    signal openSettings()

    radius: 10
    color: Colors.surface
    border.color: Colors.borderSubtle
    border.width: 1
    implicitHeight: contentLayout.implicitHeight + 20

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: ""   // headphones icon
                font.family: "Hack Nerd Font"
                font.pixelSize: 13
                color: Colors.text
            }

            Text {
                text: "Sound Output"
                color: Colors.text
                font.pixelSize: 13
                font.bold: true
                font.family: "Hack Nerd Font"
                Layout.fillWidth: true
            }
        }

        // Current device row
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 36
            radius: 8
            color: Colors.surfaceElevated
            border.color: Colors.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""   // music/audio icon
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    color: Colors.text
                }

                Text {
                    text: root.currentDevice
                    color: Colors.text
                    font.pixelSize: 12
                    font.family: "Hack Nerd Font"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: ""   // check mark
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    color: Colors.text
                }
            }
        }

        // Settings link
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 36
            radius: 8
            color: settingsMouse.pressed ? Colors.surfaceHover : Colors.surfaceElevated
            border.color: Colors.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""   // gear icon
                    font.family: "Hack Nerd Font"
                    font.pixelSize: 12
                    color: Colors.text
                }

                Text {
                    text: "Sound Settings"
                    color: Colors.text
                    font.pixelSize: 12
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
