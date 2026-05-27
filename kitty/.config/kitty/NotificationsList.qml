import QtQuick
import QtQuick.Layouts

// Notifications panel. The header is wired up; the list is a stub
// that you can connect to Quickshell.Services.Notifications.NotificationServer
// once you're ready.

Item {
    id: root

    property int count: 0
    signal clearAll()

    implicitHeight: 36 + (root.count === 0 ? 200 : Math.min(root.count * 60, 400))

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Count badge
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 24
                radius: 12
                color: Colors.danger

                Text {
                    anchors.centerIn: parent
                    text: root.count.toString()
                    color: Colors.background
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Text {
                text: "notifications"
                color: Colors.text
                font.pixelSize: 13
                font.family: "Hack Nerd Font"
                Layout.fillWidth: true
            }

            // Clear all button
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: 70
                radius: 8
                color: clearMouse.pressed ? Colors.surfaceHover : Colors.surface
                border.color: Colors.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Clear all"
                    color: Colors.text
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

        // Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.count === 0

            Text {
                anchors.centerIn: parent
                text: "No notifications"
                color: Colors.textDim
                font.pixelSize: 12
                font.family: "Hack Nerd Font"
            }
        }

        // TODO: when ready, plug in:
        //   import Quickshell.Services.Notifications
        //   NotificationServer { id: notifs; onNotification: ... }
        // Then render the model in a ListView here.
    }
}
