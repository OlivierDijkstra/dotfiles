pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property color surface1: "#171717"
    readonly property color surface2: "#1E1E1E"
    readonly property color surface3: "#252525"
    readonly property color surface4: "#2C2C2C"
    readonly property color surface5: "#333333"
    readonly property color surface6: "#3A3A3A"
    readonly property color surface7: "#414141"
    readonly property color surface8: "#484848"
    readonly property color foreground: "#F5F5F5"
    readonly property color secondaryForeground: "#D4D4D4"
    readonly property color mutedForeground: "#A3A3A3"
    readonly property color disabledForeground: "#737373"
    readonly property color border: "#333333"
    readonly property color borderStrong: "#484848"
    readonly property color hoverBackground: "#2C2C2C"
    readonly property color selectedBackground: "#414141"
    readonly property color accent: "#F5F5F5"
    readonly property color accentForeground: "#171717"
    readonly property color danger: "#E57373"

    readonly property color islandBackground: "#000000"
    readonly property color debugPanelBackground: root.surface2
    readonly property color debugPanelBorder: root.border
    readonly property color chipBackground: root.surface3
    readonly property color chipBorder: root.borderStrong
    readonly property color chipActiveBackground: root.selectedBackground
    readonly property color chipActiveForeground: root.foreground
    readonly property color outline: root.border
    readonly property color trackBackground: root.surface4
    readonly property color trackFill: root.accent

}
