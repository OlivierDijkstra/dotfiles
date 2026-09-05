import QtQuick

Item {
    id: root

    required property var pipewire
    property bool pickerOpen: false
    property string activePanel: "output"
    readonly property var devices: pipewire.nodes.values.filter(node => node.audio && !node.isStream)
    readonly property var sinks: devicesForPanel(false)
    readonly property var sources: devicesForPanel(true)
    readonly property var currentDevices: activePanel === "input" ? sources : sinks

    visible: false

    function devicesForPanel(input) {
        const defaultNode = input ? pipewire.defaultAudioSource : pipewire.defaultAudioSink;
        return devices.filter(node => node.isSink !== input).map(node => ({
            id: node.id,
            name: node.description || node.nickname || node.name,
            isDefault: node === defaultNode,
        }));
    }

    function ensureAvailablePanel() {
        if (activePanel === "output" && sinks.length === 0 && sources.length > 0) {
            activePanel = "input";
        } else if (activePanel === "input" && sources.length === 0 && sinks.length > 0) {
            activePanel = "output";
        }
    }

    function openPanel(panel) {
        activePanel = panel === "input" ? "input" : "output";
        ensureAvailablePanel();
        pickerOpen = true;
    }

    function closePanel() {
        pickerOpen = false;
    }

    function selectDevice(deviceId) {
        const device = devices.find(node => node.id === deviceId && node.isSink === (activePanel === "output"));
        if (!device) {
            return;
        }

        if (activePanel === "input") {
            pipewire.preferredDefaultAudioSource = device;
        } else {
            pipewire.preferredDefaultAudioSink = device;
        }
        closePanel();
    }

    onSinksChanged: Qt.callLater(ensureAvailablePanel)
    onSourcesChanged: Qt.callLater(ensureAvailablePanel)
}
