import QtQuick
import ".." as Theme

Row {
    id: root

    required property var keepAwakeState

    visible: !!keepAwakeState && keepAwakeState.active
    spacing: 4

    Theme.ThemedIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        source: "../../assets/icons/lucide/coffee.svg"
        sourceSize.width: width
        sourceSize.height: height
        color: Theme.Palette.mutedForeground
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: !!root.keepAwakeState && root.keepAwakeState.timed
        text: root.keepAwakeState ? root.keepAwakeState.remainingText : ""
        color: Theme.Palette.mutedForeground
        font.family: "Geist Mono"
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }
}
