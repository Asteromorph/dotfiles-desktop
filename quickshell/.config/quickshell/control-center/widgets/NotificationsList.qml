import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int count: 0

    // Theming
    property color surfaceColor: Colors.surface
    property color surfaceHoverColor: Colors.surfaceHover
    property color borderColor: Colors.borderSubtle
    property color textColor: Colors.text
    property color textDimColor: Colors.textDim
    property color dangerColor: Colors.danger
    property color bgColor: Colors.background

    signal clearAll()

    implicitHeight: 36 + (root.count === 0 ? 200 : Math.min(root.count * 60, 400))

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 24
                radius: 12
                color: root.dangerColor

                Text {
                    anchors.centerIn: parent
                    text: root.count.toString()
                    color: root.bgColor
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Text {
                text: "notifications"
                color: root.textColor
                font.pixelSize: 13
                font.family: "Hack Nerd Font"
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 70
                radius: 8
                color: clearMouse.pressed ? root.surfaceHoverColor : root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Clear all"
                    color: root.textColor
                    font.pixelSize: 11
                    font.family: "Hack Nerd Font"
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clearAll()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.count === 0

            Text {
                anchors.centerIn: parent
                text: "No notifications"
                color: root.textDimColor
                font.pixelSize: 12
                font.family: "Hack Nerd Font"
            }
        }
    }
}
