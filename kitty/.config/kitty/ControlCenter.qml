import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "widgets" as W

// Main control center panel. Anchors to the top-right of the active screen.
// Toggle via IPC: `qs ipc call controlCenter toggle`

PanelWindow {
    id: root

    // ---- State ----
    property bool isOpen: false
    property real volume: 0.5
    property real micVolume: 0.5
    property real brightness: 0.8
    property string wifiName: "AirFiber"
    property string notifMode: "Noisy"
    property bool isRecording: true
    property bool soundOutputExpanded: false

    // ---- IPC ----
    IpcHandler {
        target: "controlCenter"
        function toggle(): void { root.isOpen = !root.isOpen }
        function show(): void { root.isOpen = true }
        function hide(): void { root.isOpen = false }
    }

    // ---- Panel layout ----
    visible: root.isOpen
    color: "transparent"

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: 36       // sits below your bar; tweak to match your bar height
        right: 12
        bottom: 12
    }

    implicitWidth: 360
    exclusionMode: ExclusionMode.Normal

    // Close on click outside (covers area to left of panel)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // ---- Visual root ----
    Rectangle {
        anchors.fill: parent
        color: Colors.background
        radius: 14
        border.color: Colors.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Row 1: WiFi + Notification mode (side by side)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                W.ToggleButton {
                    Layout.fillWidth: true
                    iconText: ""      // wifi
                    label: root.wifiName
                    onClicked: networkProcess.running = true
                }

                W.ToggleButton {
                    Layout.fillWidth: true
                    iconText: ""      // bell
                    label: root.notifMode
                    onClicked: {
                        // Cycle through modes: Noisy → Quiet → DND → Noisy
                        if (root.notifMode === "Noisy") root.notifMode = "Quiet"
                        else if (root.notifMode === "Quiet") root.notifMode = "DND"
                        else root.notifMode = "Noisy"
                    }
                }
            }

            // Row 2: Recording status
            W.ToggleButton {
                Layout.fillWidth: true
                label: root.isRecording ? "Recording" : "Not Recording"
                showStatusDot: true
                statusDotColor: root.isRecording ? Colors.danger : Colors.textDim
                showChevron: true
                onClicked: {
                    // Toggle screen recording — placeholder
                    root.isRecording = !root.isRecording
                }
            }

            // Row 3: Volume slider + expand
            W.SliderRow {
                Layout.fillWidth: true
                iconText: ""              // speaker
                value: root.volume
                showExpandButton: true
                trailingIcon: root.soundOutputExpanded ? "" : ""
                onValueChanged: (v) => {
                    root.volume = v
                    setVolumeProcess.command = [
                        "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v.toFixed(2)
                    ]
                    setVolumeProcess.running = true
                }
                onExpandClicked: root.soundOutputExpanded = !root.soundOutputExpanded
            }

            // Row 4: Sound Output card (collapsible)
            W.SoundOutput {
                Layout.fillWidth: true
                visible: root.soundOutputExpanded
                onOpenSettings: Qt.callLater(() => {
                    pavucontrolProcess.running = true
                })
            }

            // Row 5: Mic slider
            W.SliderRow {
                Layout.fillWidth: true
                iconText: ""              // microphone
                value: root.micVolume
                showExpandButton: true
                trailingIcon: ""
                onValueChanged: (v) => {
                    root.micVolume = v
                    setMicProcess.command = [
                        "wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", v.toFixed(2)
                    ]
                    setMicProcess.running = true
                }
            }

            // Row 6: Brightness slider
            W.SliderRow {
                Layout.fillWidth: true
                iconText: ""              // brightness/sun
                value: root.brightness
                onValueChanged: (v) => {
                    root.brightness = v
                    setBrightnessProcess.command = [
                        "brightnessctl", "set", Math.round(v * 100) + "%"
                    ]
                    setBrightnessProcess.running = true
                }
            }

            // Row 7: User card
            W.UserCard {
                Layout.fillWidth: true
                onSettingsClicked: settingsProcess.running = true
                onPowerClicked: {
                    // Use wlogout if installed, otherwise direct poweroff
                    powerProcess.running = true
                }
            }

            // Row 8: Notifications (fills remaining space)
            W.NotificationsList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 8
                count: 0  // TODO: wire to real notification server
                onClearAll: console.log("Clear all notifications")
            }
        }
    }

    // ---- Backend processes ----
    Process {
        id: setVolumeProcess
        command: ["true"]
    }

    Process {
        id: setMicProcess
        command: ["true"]
    }

    Process {
        id: setBrightnessProcess
        command: ["true"]
    }

    Process {
        id: pavucontrolProcess
        command: ["pavucontrol"]
    }

    Process {
        id: settingsProcess
        command: ["systemsettings"]   // KDE settings; swap for your preferred app
    }

    Process {
        id: powerProcess
        command: ["wlogout"]
    }

    Process {
        id: networkProcess
        command: ["nm-connection-editor"]
    }

    // ---- Initialize state on startup ----
    Component.onCompleted: {
        getVolumeProcess.running = true
        getMicProcess.running = true
        getBrightnessProcess.running = true
        getWifiProcess.running = true
    }

    Process {
        id: getVolumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim())
                if (!isNaN(v)) root.volume = v
            }
        }
    }

    Process {
        id: getMicProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim())
                if (!isNaN(v)) root.micVolume = v
            }
        }
    }

    Process {
        id: getBrightnessProcess
        command: ["sh", "-c", "echo $(brightnessctl get) / $(brightnessctl max) | bc -l"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.trim())
                if (!isNaN(v)) root.brightness = v
            }
        }
    }

    Process {
        id: getWifiProcess
        command: ["sh", "-c", "nmcli -t -f NAME connection show --active | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t !== "") root.wifiName = t
            }
        }
    }
}
