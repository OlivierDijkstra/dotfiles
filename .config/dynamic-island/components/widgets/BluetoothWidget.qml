pragma ComponentBehavior: Bound
import QtQuick
import ".." as Theme

Item {
    id: root

    readonly property string iconBasePath: "../../assets/icons/lucide"
    property string layoutKey: "bluetooth-box"
    property bool exclusive: true
    property int surfaceWidth: 432
    readonly property int minimumSurfaceHeight: !root.bluetoothState || !root.bluetoothState.adapterAvailable
        ? 112
        : (root.devices.length === 0 ? 108 : 188)
    property int surfaceHeight: Math.max(
        root.minimumSurfaceHeight,
        Math.min(338, Math.ceil(contentColumn.implicitHeight + (verticalPadding * 2)))
    )
    property int surfaceRadius: 30
    property int horizontalPadding: 18
    property int verticalPadding: 16
    required property var bluetoothState
    readonly property bool available: !!bluetoothState && bluetoothState.pickerOpen
    readonly property var devices: bluetoothState ? bluetoothState.devices : []

    visible: false

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        spacing: 14

        Row {
            width: parent.width
            height: Math.max(bluetoothToggle.height, closeButton.height)
            spacing: 12

            Item {
                id: bluetoothToggle

                width: 44
                height: 28
                opacity: root.bluetoothState.adapterAvailable ? 1 : 0.42
                scale: toggleArea.pressed ? 0.98 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: root.bluetoothState.adapterEnabled ? Theme.Palette.accent : Theme.Palette.surface3

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    x: root.bluetoothState.adapterEnabled ? (parent.width - width - 3) : 3
                    y: 3
                    color: root.bluetoothState.adapterEnabled ? Theme.Palette.accentForeground : Theme.Palette.foreground

                    Behavior on x {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                MouseArea {
                    id: toggleArea

                    anchors.fill: parent
                    enabled: root.bluetoothState.adapterAvailable
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.bluetoothState.toggleAdapterEnabled()
                }
            }

            Item {
                width: parent.width - bluetoothToggle.width - closeButton.width - (parent.spacing * 2)
                height: 1
            }

            Item {
                id: closeButton

                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                scale: closeArea.pressed ? 0.96 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: closeArea.containsMouse ? Theme.Palette.hoverBackground : Theme.Palette.surface2
                }

                Theme.ThemedIcon {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    source: `${root.iconBasePath}/x.svg`
                    sourceSize.width: width
                    sourceSize.height: height
                    opacity: closeArea.containsMouse ? 1 : 0.82
                }

                MouseArea {
                    id: closeArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.bluetoothState.closePanel()
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Text {
                width: parent.width
                visible: !root.bluetoothState.adapterAvailable
                color: Theme.Palette.mutedForeground
                text: "No Bluetooth adapter was detected."
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Text {
                width: parent.width
                visible: root.bluetoothState.adapterAvailable && root.devices.length === 0
                color: Theme.Palette.mutedForeground
                text: root.bluetoothState.adapterEnabled
                    ? "No Bluetooth devices are available right now."
                    : "Turn Bluetooth on to see saved and nearby devices."
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: root.devices.length

                delegate: Item {
                    id: deviceRow

                    required property int index
                    readonly property var device: root.devices[index]

                    width: parent.width
                    height: 42
                    opacity: root.bluetoothState.canActivateDevice(deviceRow.device) || deviceRow.device.connected ? 1 : 0.5
                    scale: deviceArea.pressed ? 0.99 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: deviceRow.device.connected ? Theme.Palette.selectedBackground : (deviceArea.containsMouse ? Theme.Palette.hoverBackground : "transparent")
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Text {
                            width: parent.width - actionLabel.implicitWidth - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            color: deviceRow.device.connected ? Theme.Palette.foreground : Theme.Palette.mutedForeground
                            text: root.bluetoothState.displayName(deviceRow.device)
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            id: actionLabel

                            anchors.verticalCenter: parent.verticalCenter
                            color: deviceRow.device.connected ? Theme.Palette.foreground : Theme.Palette.mutedForeground
                            text: root.bluetoothState.deviceActionLabel(deviceRow.device)
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        id: deviceArea

                        anchors.fill: parent
                        enabled: root.bluetoothState.canActivateDevice(deviceRow.device)
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.bluetoothState.activateDevice(deviceRow.device)
                    }
                }
            }
        }
    }
}
