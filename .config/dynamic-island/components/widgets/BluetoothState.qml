import QtQuick
import Quickshell.Bluetooth

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool pickerOpen: false
    property int deviceRevision: 0

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool adapterAvailable: !!adapter
    readonly property bool adapterEnabled: !!adapter && adapter.enabled
    readonly property var adapterDevices: adapter && adapter.devices ? adapter.devices.values : []
    readonly property var devices: root.devicesForView(adapterDevices, deviceRevision)
    readonly property int connectedDeviceCount: root.countConnectedDevices(devices)

    function openPanel() {
        pickerOpen = true;
    }

    function closePanel() {
        pickerOpen = false;
    }

    function devicesForView(sourceDevices, revision) {
        return root.filteredDevices(sourceDevices);
    }

    function filteredDevices(sourceDevices) {
        const nextDevices = [];

        for (let index = 0; index < (sourceDevices || []).length; index += 1) {
            const device = sourceDevices[index];

            if (!device || device.blocked) {
                continue;
            }

            nextDevices.push(device);
        }

        nextDevices.sort((left, right) => {
            if (!!left.connected !== !!right.connected) {
                return left.connected ? -1 : 1;
            }

            const leftSaved = !!left.paired || !!left.bonded || !!left.trusted;
            const rightSaved = !!right.paired || !!right.bonded || !!right.trusted;

            if (leftSaved !== rightSaved) {
                return leftSaved ? -1 : 1;
            }

            return root.displayName(left).localeCompare(root.displayName(right));
        });

        return nextDevices;
    }

    function countConnectedDevices(sourceDevices) {
        let count = 0;

        for (let index = 0; index < (sourceDevices || []).length; index += 1) {
            if (sourceDevices[index] && sourceDevices[index].connected) {
                count += 1;
            }
        }

        return count;
    }

    function displayName(device) {
        if (!device) {
            return "";
        }

        return device.deviceName || device.name || device.address || "Unknown device";
    }

    function deviceActionLabel(device) {
        if (!device) {
            return "";
        }

        if (device.pairing) {
            return "Pairing";
        }

        if (device.connected) {
            return "Disconnect";
        }

        if (!adapterAvailable) {
            return "Unavailable";
        }

        if (!adapterEnabled) {
            return "Off";
        }

        if (device.paired || device.bonded || device.trusted) {
            return "Connect";
        }

        return "Pair";
    }

    function canActivateDevice(device) {
        if (!device || device.pairing || !adapterAvailable) {
            return false;
        }

        return adapterEnabled || device.connected;
    }

    function toggleAdapterEnabled() {
        if (!adapter) {
            return;
        }

        adapter.enabled = !adapter.enabled;
    }

    function activateDevice(device) {
        if (!root.canActivateDevice(device)) {
            return;
        }

        if (device.connected) {
            device.disconnect();
            return;
        }

        if (device.paired || device.bonded || device.trusted) {
            device.connect();
            return;
        }

        device.pair();
    }

    Repeater {
        model: root.adapterDevices

        delegate: Item {
            required property var modelData

            visible: false
            width: 0
            height: 0

            Connections {
                target: modelData

                function onBlockedChanged() {
                    root.deviceRevision += 1;
                }

                function onBondedChanged() {
                    root.deviceRevision += 1;
                }

                function onConnectedChanged() {
                    root.deviceRevision += 1;
                }

                function onDeviceNameChanged() {
                    root.deviceRevision += 1;
                }

                function onNameChanged() {
                    root.deviceRevision += 1;
                }

                function onPairedChanged() {
                    root.deviceRevision += 1;
                }

                function onPairingChanged() {
                    root.deviceRevision += 1;
                }

                function onTrustedChanged() {
                    root.deviceRevision += 1;
                }
            }
        }
    }
}
