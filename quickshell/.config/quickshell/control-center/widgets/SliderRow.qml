import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    // Content
    property string iconText: ""
    property real value: 0.5
    property bool showExpandButton: false
    property string trailingIcon: ""

    // Theming
    property color surfaceColor: Colors.surface
    property color surfaceHoverColor: Colors.surfaceHover
    property color borderColor: Colors.borderSubtle
    property color textColor: Colors.text
    property color textSecondaryColor: Colors.textSecondary
    property color accentColor: Colors.accent
    property color trackColor: Colors.sliderTrack

    signal moved(real v)
    signal expandClicked()

    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Text {
            text: root.iconText
            font.family: "Hack Nerd Font"
            font.pixelSize: 20
            color: root.textSecondaryColor
            Layout.preferredWidth: 24
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            from: 0
            to: 1
            value: root.value
            onMoved: root.moved(value)

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 6
                radius: 3
                color: root.trackColor

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: root.accentColor
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 20
                height: 20
                radius: 10
                color: root.textColor
                border.color: root.accentColor
                border.width: 3

                scale: slider.pressed ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }

        Rectangle {
            visible: root.showExpandButton
            Layout.preferredWidth: 36
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: trailingMouse.pressed ? root.surfaceHoverColor : root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: root.trailingIcon
                font.family: "Hack Nerd Font"
                font.pixelSize: 14
                color: root.textSecondaryColor
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
