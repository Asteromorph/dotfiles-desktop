import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Generic slider row: icon + slider + optional trailing button.
// Used for volume, mic, and brightness.

Item {
    id: root

    property string iconText: ""        // Nerd Font glyph for the leading icon
    property real value: 0.5            // 0.0 to 1.0
    property bool showExpandButton: false
    property string trailingIcon: ""    // optional icon on trailing button

    signal valueChanged(real v)
    signal expandClicked()

    implicitHeight: 32

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: root.iconText
            font.family: "Hack Nerd Font"
            font.pixelSize: 16
            color: Colors.textSecondary
            Layout.preferredWidth: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            from: 0
            to: 1
            value: root.value
            onMoved: root.valueChanged(value)

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 6
                radius: 3
                color: Colors.sliderTrack

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Colors.sliderFill
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * slider.availableWidth - width / 2
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 0
                height: 0
                // Invisible handle — the fill speaks for itself
            }
        }

        Rectangle {
            visible: root.showExpandButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: trailingMouse.pressed ? Colors.surfaceHover : Colors.surface
            border.color: Colors.borderSubtle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: root.trailingIcon !== "" ? root.trailingIcon : ""
                font.family: "Hack Nerd Font"
                font.pixelSize: 11
                color: Colors.textSecondary
            }

            MouseArea {
                id: trailingMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expandClicked()
            }
        }
    }
}
