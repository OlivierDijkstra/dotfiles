pragma ComponentBehavior: Bound
import QtQuick
import "../Palette.js" as Palette

Item {
    id: root

    readonly property string iconBasePath: "../../assets/icons/lucide"
    property string layoutKey: "network-box"
    property bool exclusive: true
    property int surfaceWidth: 432
    property int surfaceHeight: Math.max(
        root.networkState && !root.networkState.wifiAvailable ? 140 : 226,
        Math.min(338, Math.ceil(contentColumn.implicitHeight + (verticalPadding * 2)))
    )
    property int surfaceRadius: 30
    property int horizontalPadding: 18
    property int verticalPadding: 16
    required property var networkState
    readonly property bool available: !!networkState && networkState.pickerOpen
    readonly property var networks: networkState ? networkState.wifiNetworks : []

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
            height: closeButton.height

            Item {
                width: parent.width - closeButton.width
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
                    onClicked: root.networkState.closePanel()
                }
            }
        }

        Row {
            id: statusCardRow

            width: parent.width
            spacing: 10

            Rectangle {
                id: wifiStatusCard

                width: Math.floor((parent.width - parent.spacing) / 2)
                height: 60
                radius: 20
                color: root.networkState.wifiConnected ? "#10141a" : "#101013"

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.topMargin: 11
                    anchors.bottomMargin: 11
                    spacing: 2

                    Text {
                        width: parent.width
                        color: Palette.mutedForeground
                        text: "Wi-Fi"
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        color: Palette.foreground
                        text: root.networkState.wifiSummary
                        font.family: "Geist"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                width: statusCardRow.width - wifiStatusCard.width - statusCardRow.spacing
                height: 60
                radius: 20
                color: root.networkState.ethernetConnected ? "#10141a" : "#101013"

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.topMargin: 11
                    anchors.bottomMargin: 11
                    spacing: 2

                    Text {
                        width: parent.width
                        color: Palette.mutedForeground
                        text: "Ethernet"
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Text {
                        width: parent.width
                        color: Palette.foreground
                        text: root.networkState.ethernetSummary
                        font.family: "Geist"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Row {
            id: actionRow

            width: parent.width
            visible: root.networkState.wifiAvailable
            spacing: 8

            Repeater {
                model: [
                    {
                        label: root.networkState.wifiEnabled ? "Turn Wi-Fi Off" : "Turn Wi-Fi On",
                        enabled: root.networkState.wifiAvailable && !root.networkState.busy,
                        active: root.networkState.wifiEnabled,
                        action: function () {
                            root.networkState.toggleWifi();
                        }
                    },
                    {
                        label: "Refresh",
                        enabled: !root.networkState.busy,
                        active: false,
                        action: function () {
                            root.networkState.refresh(true);
                        }
                    },
                    {
                        label: "Settings",
                        enabled: !root.networkState.busy,
                        active: false,
                        action: function () {
                            root.networkState.openSettings();
                        }
                    },
                ]

                delegate: Item {
                    id: actionButton

                    required property var modelData

                    width: Math.floor((actionRow.width - (actionRow.spacing * 2)) / 3)
                    height: 38
                    opacity: modelData.enabled ? 1 : 0.42
                    scale: actionArea.pressed ? 0.98 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 19
                        color: actionButton.modelData.active ? Palette.chipActiveBackground : "#101013"
                    }

                    Text {
                        anchors.centerIn: parent
                        color: actionButton.modelData.active ? Palette.chipActiveForeground : Palette.foreground
                        text: actionButton.modelData.label
                        font.family: "Geist"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: actionArea

                        anchors.fill: parent
                        enabled: actionButton.modelData.enabled
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: actionButton.modelData.action()
                    }
                }
            }
        }

        Column {
            visible: root.networkState.wifiAvailable
            width: parent.width
            spacing: 8

            Text {
                width: parent.width
                color: Palette.foreground
                text: "Nearby Wi-Fi"
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                visible: root.networkState.wifiAvailable && !root.networkState.wifiEnabled
                color: Palette.mutedForeground
                text: "Turn Wi-Fi on to scan for nearby networks."
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Text {
                width: parent.width
                visible: root.networkState.wifiAvailable && root.networkState.wifiEnabled && root.networks.length === 0
                color: Palette.mutedForeground
                text: "No networks found yet. Try refreshing or opening full settings."
                font.family: "Geist"
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Repeater {
                model: root.networks.length

                delegate: Item {
                    id: networkRow

                    required property int index

                    readonly property var network: root.networks[index]

                    width: parent.width
                    height: 46
                    scale: networkArea.pressed ? 0.99 : 1
                    opacity: root.networkState.busy && network.active !== true ? 0.64 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: networkRow.network.active ? "#101318" : (networkArea.containsMouse ? "#161618" : "transparent")
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        Item {
                            width: parent.width - stateLabel.implicitWidth - selectionIndicator.width - (parent.spacing * 2)
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                spacing: 2

                                Text {
                                    width: parent.width
                                    color: networkRow.network.active ? Palette.foreground : Palette.mutedForeground
                                    text: networkRow.network.ssid
                                    font.family: "Geist"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    color: Palette.mutedForeground
                                    text: `${networkRow.network.signal}% - ${networkRow.network.security || "Open"}`
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        Text {
                            id: stateLabel

                            anchors.verticalCenter: parent.verticalCenter
                            color: networkRow.network.active ? Palette.foreground : Palette.mutedForeground
                            text: networkRow.network.active ? "Connected" : "Join"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }

                        Item {
                            id: selectionIndicator

                            width: networkRow.network.active ? 16 : 0
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true

                            Image {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                source: `${root.iconBasePath}/check.svg`
                                sourceSize.width: width
                                sourceSize.height: height
                            }
                        }
                    }

                    MouseArea {
                        id: networkArea

                        anchors.fill: parent
                        enabled: !root.networkState.busy && networkRow.network.active !== true
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.networkState.connectWifiNetwork(networkRow.network)
                    }
                }
            }
        }

        Text {
            width: parent.width
            visible: root.networkState.noticeText.length > 0
            color: root.networkState.noticeIsError ? "#ff9b92" : Palette.mutedForeground
            text: root.networkState.noticeText
            font.family: "Geist"
            font.pixelSize: 12
            font.weight: Font.Medium
            wrapMode: Text.WordWrap
        }
    }
}
