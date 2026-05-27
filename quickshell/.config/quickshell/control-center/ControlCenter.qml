import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "widgets" as W

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
    property bool soundInputExpanded: false
    property string currentSinkName: "Loading..."
    property string currentSourceName: "Loading..."

    // ---- Theme ----
    // Pass `theme: ts.theme` from shell.qml to sync with theme switcher.
    // If null, falls back to Colors singleton.
    property var theme: null

    // Resolved colors: use theme if provided, else Colors fallback.
    // Variants for hover/elevated/border are computed from the base palette.
    readonly property color bgColor:           theme ? theme.bgBase : Colors.background
    readonly property color surfaceColor:      theme ? theme.bgSurface : Colors.surface
    readonly property color surfaceElevatedColor: theme ? Qt.lighter(theme.bgSurface, 1.25) : Colors.surfaceElevated
    readonly property color surfaceHoverColor: theme ? Qt.lighter(theme.bgSurface, 1.1)  : Colors.surfaceHover
    readonly property color borderColor:       theme ? Qt.lighter(theme.bgSurface, 1.4)  : Colors.border
    readonly property color borderSubtleColor: theme ? theme.bgSurface : Colors.borderSubtle
    readonly property color textColor:         theme ? theme.textPrimary : Colors.text
    readonly property color textSecondaryColor: theme ? theme.textSecondary : Colors.textSecondary
    readonly property color textDimColor:      theme ? theme.textMuted : Colors.textDim
    readonly property color accentColor:       theme ? theme.accentPrimary : Colors.accent
    readonly property color dangerColor:       theme ? theme.accentRed : Colors.danger
    readonly property color successColor:      theme ? theme.accentGreen : Colors.success
    readonly property color sliderTrackColor:  theme ? Qt.lighter(theme.bgSurface, 1.3) : Colors.sliderTrack

    // ---- IPC ----
    IpcHandler {
        target: "controlCenter"
        function toggle() { root.isOpen = !root.isOpen }
        function show() { root.isOpen = true }
        function hide() { root.isOpen = false }
    }

    // ---- Window ----
    visible: root.isOpen
    color: "transparent"
    anchors { top: true; right: true; bottom: true; left: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay

	// Click OUTSIDE the panel to close
	MouseArea {
	    anchors.fill: parent
	    onClicked: (mouse) => {
		// Close only if click is outside the panel rectangle
		const inPanel = mouse.x >= panelContent.x &&
				mouse.x <= panelContent.x + panelContent.width &&
				mouse.y >= panelContent.y &&
				mouse.y <= panelContent.y + panelContent.height
		if (!inPanel) root.isOpen = false
	    }
	}

    // Panel
    Rectangle {
        width: 380
        id: panelContent
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 36
        anchors.rightMargin: 12
        anchors.bottomMargin: 12

        color: root.bgColor
        radius: 14
        border.color: root.borderColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Row 1: WiFi + Notif mode
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                W.ToggleButton {
                    Layout.fillWidth: true
                    iconText: "\uf1eb"
                    label: root.wifiName
                    surfaceColor: root.surfaceColor
                    surfaceHoverColor: root.surfaceHoverColor
                    surfaceElevatedColor: root.surfaceElevatedColor
                    borderColor: root.borderSubtleColor
                    textColor: root.textColor
                    textSecondaryColor: root.textSecondaryColor
                    onClicked: { networkProcess.running = true; root.isOpen = false }
                }

                W.ToggleButton {
                    Layout.fillWidth: true
                    iconText: "\uf0f3"
                    label: root.notifMode
                    surfaceColor: root.surfaceColor
                    surfaceHoverColor: root.surfaceHoverColor
                    surfaceElevatedColor: root.surfaceElevatedColor
                    borderColor: root.borderSubtleColor
                    textColor: root.textColor
                    textSecondaryColor: root.textSecondaryColor
                    onClicked: {
                        if (root.notifMode === "Noisy") root.notifMode = "Quiet"
                        else if (root.notifMode === "Quiet") root.notifMode = "DND"
                        else root.notifMode = "Noisy"
                    }
                }
            }

            // Row 2: Recording
            W.ToggleButton {
                Layout.fillWidth: true
                label: root.isRecording ? "Recording" : "Not Recording"
                showStatusDot: true
                statusDotColor: root.isRecording ? root.dangerColor : root.textDimColor
                showChevron: true
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                surfaceElevatedColor: root.surfaceElevatedColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                textSecondaryColor: root.textSecondaryColor
                onClicked: {
                    if (root.isRecording) {
                        stopRecordingProcess.running = true
                        root.isRecording = false
                    } else {
                        stopRecordingProcess.running = true
                        root.isRecording = true
                    }
                }
            }




            // Row 3: Volume
            W.SliderRow {
                Layout.fillWidth: true
                iconText: "\uf028"
                value: root.volume
                showExpandButton: true
                trailingIcon: root.soundOutputExpanded ? "\uf077" : "\uf078"
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                textSecondaryColor: root.textSecondaryColor
                accentColor: root.accentColor
                trackColor: root.sliderTrackColor
                onMoved: (v) => {
                    root.volume = v
                    setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v.toFixed(2)]
                    setVolumeProcess.running = true
                }
                onExpandClicked: root.soundOutputExpanded = !root.soundOutputExpanded
            }

            // Row 4: Sound Output card
            W.SoundOutput {
                Layout.fillWidth: true
                visible: root.soundOutputExpanded
                surfaceColor: root.surfaceColor
                surfaceElevatedColor: root.surfaceElevatedColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                onOpenSettings: { pavucontrolProcess.running = true; root.isOpen = false }
            }

            // Row 5: Mic
            W.SliderRow {
                Layout.fillWidth: true
                iconText: "\uf130"
                value: root.micVolume
                showExpandButton: true
                trailingIcon: root.soundInputExpanded ? "\uf077" : "\uf078"
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                textSecondaryColor: root.textSecondaryColor
                accentColor: root.accentColor
                trackColor: root.sliderTrackColor
                onMoved: (v) => {
                    root.micVolume = v
                    setMicProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", v.toFixed(2)]
                    setMicProcess.running = true
                }
                onExpandClicked: root.soundInputExpanded = !root.soundInputExpanded
            }

	    W.SoundInput {
		    Layout.fillWidth: true
		    visible: root.soundInputExpanded
		    surfaceColor: root.surfaceColor
		    surfaceElevatedColor: root.surfaceElevatedColor
		    surfaceHoverColor: root.surfaceHoverColor
		    borderColor: root.borderSubtleColor
		    textColor: root.textColor
		    onOpenSettings: { pavucontrolProcess.running = true; root.isOpen = false }
		}

            // Row 6: Brightness
            W.SliderRow {
                Layout.fillWidth: true
                iconText: "\uf185"
                value: root.brightness
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                textSecondaryColor: root.textSecondaryColor
                accentColor: root.accentColor
                trackColor: root.sliderTrackColor
                onMoved: (v) => {
                    root.brightness = v
		    setBrightnessProcess.command = [
			    "ddcutil", "setvcp", "10", Math.round(v * 100).toString()
			]
                    setBrightnessProcess.running = true
                }
            }

            // Row 7: User
            W.UserCard {
                Layout.fillWidth: true
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                textColor: root.textColor
                textSecondaryColor: root.textSecondaryColor
                accentColor: root.accentColor
                dangerColor: root.dangerColor
                onSettingsClicked: { settingsProcess.running = true; root.isOpen = false }
                onPowerClicked:    { powerProcess.running = true;    root.isOpen = false }
            }

            // Row 8: Notifications
            W.NotificationsList {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 8
                count: 0
                surfaceColor: root.surfaceColor
                surfaceHoverColor: root.surfaceHoverColor
                borderColor: root.borderSubtleColor
                    textColor: root.textColor
                    textDimColor: root.textDimColor
                dangerColor: root.dangerColor
                bgColor: root.bgColor
                onClearAll: console.log("Clear all notifications")
            }
        }
    }

    // ---- Processes ----
    Process { id: setVolumeProcess;     command: ["true"] }
    Process { id: setMicProcess;        command: ["true"] }
    Process { id: setBrightnessProcess; command: ["true"] }
    Process { id: pavucontrolProcess;   command: ["pavucontrol"] }
    Process { id: settingsProcess;      command: ["systemsettings"] }
    Process { id: powerProcess;         command: ["wlogout"] }
    Process { id: networkProcess;       command: ["nm-connection-editor"] }
    Process {
        id: startRecordingProcess
        command: ["sh", "-c",
            "mkdir -p ~/Videos && nohup wf-recorder -f ~/Videos/rec-$(date +%Y-%m-%d_%H-%M-%S).mp4 > /dev/null 2>&1 &"]
    }

    Process {
        id: stopRecordingProcess
        command: ["pkill", "-INT", "wf-recorder"]
    }

    Process {
        id: checkRecordingProcess
        command: ["sh", "-c", "pgrep wf-recorder > /dev/null && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: { root.isRecording = text.trim() === "yes" }
        }
    }

    Process {
        id: getSinkNameProcess
        command: ["sh", "-c",
            "pactl list sinks 2>/dev/null | grep -A 1 \"Name: $(pactl get-default-sink)\" | tail -1 | sed 's/.*Description: //'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t !== "") root.currentSinkName = t
            }
        }
    }

    Process {
        id: getSourceNameProcess
        command: ["sh", "-c",
            "pactl list sources 2>/dev/null | grep -A 1 \"Name: $(pactl get-default-source)\" | tail -1 | sed 's/.*Description: //'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t !== "") root.currentSourceName = t
            }
        }
    }


    Component.onCompleted: {
        getVolumeProcess.running = true
        getMicProcess.running = true
        getBrightnessProcess.running = true
        getWifiProcess.running = true
        checkRecordingProcess.running = true
        getSinkNameProcess.running = true
        getSourceNameProcess.running = true
    }

    Process {
        id: getVolumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: { const v = parseFloat(text.trim()); if (!isNaN(v)) root.volume = v }
        }
    }

    Process {
        id: getMicProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: { const v = parseFloat(text.trim()); if (!isNaN(v)) root.micVolume = v }
        }
    }

    Process {
        id: getBrightnessProcess
    	command: ["sh", "-c", "ddcutil getvcp 10 --terse 2>/dev/null | awk '{print $4/$5}'"]
        stdout: StdioCollector {
            onStreamFinished: { const v = parseFloat(text.trim()); if (!isNaN(v)) root.brightness = v }
        }
    }

    Process {
        id: getWifiProcess
        command: ["sh", "-c", "nmcli -t -f NAME connection show --active | head -1"]
        stdout: StdioCollector {
            onStreamFinished: { const t = text.trim(); if (t !== "") root.wifiName = t }
        }
    }
}
