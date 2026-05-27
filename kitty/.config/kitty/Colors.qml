pragma Singleton
import QtQuick

QtObject {
    // Backgrounds
    readonly property color background: "#181818"
    readonly property color surface: "#242424"
    readonly property color surfaceElevated: "#2e2e2e"
    readonly property color surfaceHover: "#353535"

    // Borders
    readonly property color border: "#3a3a3a"
    readonly property color borderSubtle: "#2a2a2a"

    // Text
    readonly property color text: "#e8e8e8"
    readonly property color textSecondary: "#9a9a9a"
    readonly property color textDim: "#6a6a6a"

    // Accents — adjust to taste; this matches the teal/mint in the screenshot
    readonly property color accent: "#94d2bd"
    readonly property color accentDim: "#5e8b7e"
    readonly property color accentText: "#1a1a1a"

    // States
    readonly property color danger: "#e76f51"
    readonly property color warning: "#f4a261"
    readonly property color success: "#94d2bd"

    // Specific
    readonly property color sliderTrack: "#3a3a3a"
    readonly property color sliderFill: accent
}
