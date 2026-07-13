pragma ComponentBehavior: Bound
import QtQuick
import "../Palette.js" as Palette

Item {
    id: root

    readonly property string iconBasePath: "../../assets/icons/lucide"
    property string layoutKey: "audio-route-box"
    property bool exclusive: true
    property int surfaceWidth: 420
    property int surfaceHeight: Math.max(176, Math.ceil(contentColumn.implicitHeight + (verticalPadding * 2)))
    property int surfaceRadius: 30
    property int horizontalPadding: 18
    property int verticalPadding: 16
    required property var audioRouteState
    readonly property bool available: !!audioRouteState && audioRouteState.pickerOpen
    readonly property bool showingInputs: !!audioRouteState && audioRouteState.activePanel === "input"
    readonly property var devices: audioRouteState ? audioRouteState.currentDevices : []
    readonly property string panelTitle: showingInputs ? "Input Device" : "Output Device"
    readonly property string panelDescription: showingInputs ? "Choose where your microphone comes from." : "Choose where playback is routed."

    visible: false

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        spacing: 12

        Row {
            width: parent.width
            height: Math.max(titleColumn.implicitHeight, closeButton.height)
            spacing: 12

            Column {
                id: titleColumn

                width: parent.width - closeButton.width - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    width: parent.width
                    color: Palette.foreground
                    text: root.panelTitle
                    font.family: "Geist"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    color: Palette.mutedForeground
                    text: root.panelDescription
                    font.family: "Geist"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
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
                    color: closeArea.containsMouse ? "#1a1a1b" : "#121214"
                }

                Image {
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
                    onClicked: root.audioRouteState.closePanel()
                }
            }
        }

        Row {
            width: parent.width
            spacing: 8

            Repeater {
                model: [
                    {
                        key: "output",
                        label: "Output",
                        enabled: root.audioRouteState && root.audioRouteState.sinks.length > 0,
                    },
                    {
                        key: "input",
                        label: "Input",
                        enabled: root.audioRouteState && root.audioRouteState.sources.length > 0,
                    },
                ]

                delegate: Item {
                    id: tabButton

                    required property var modelData

                    width: 84
                    height: 34
                    opacity: modelData.enabled ? 1 : 0.42
                    scale: tabArea.pressed ? 0.98 : 1

                    readonly property bool active: root.audioRouteState && root.audioRouteState.activePanel === tabButton.modelData.key

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 17
                        color: tabButton.active ? Palette.chipActiveBackground : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        color: tabButton.active ? Palette.chipActiveForeground : Palette.foreground
                        text: tabButton.modelData.label
                        font.family: "Geist"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: tabArea

                        anchors.fill: parent
                        enabled: tabButton.modelData.enabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.audioRouteState.openPanel(tabButton.modelData.key)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Text {
                width: parent.width
                visible: root.devices.length === 0
                color: Palette.mutedForeground
                text: root.showingInputs ? "No input devices available." : "No output devices available."
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Repeater {
                model: root.devices.length

                delegate: Item {
                    id: deviceRow

                    required property int index

                    readonly property var device: root.devices[index]

                    width: parent.width
                    height: 42
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
                        color: deviceRow.device.isDefault ? "#101013" : (deviceArea.containsMouse ? "#161618" : "transparent")
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Item {
                            width: parent.width - selectionIndicator.width - parent.spacing
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                color: deviceRow.device.isDefault ? Palette.foreground : Palette.mutedForeground
                                text: deviceRow.device.name
                                font.family: "Geist"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                        }

                        Item {
                            id: selectionIndicator

                            width: deviceRow.device.isDefault ? 18 : 0
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true

                            Image {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: `${root.iconBasePath}/check.svg`
                                sourceSize.width: width
                                sourceSize.height: height
                            }
                        }
                    }

                    MouseArea {
                        id: deviceArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.audioRouteState.selectDevice(deviceRow.device.id)
                    }
                }
            }
        }
    }
}
