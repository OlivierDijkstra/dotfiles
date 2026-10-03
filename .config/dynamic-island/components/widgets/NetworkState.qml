import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    readonly property string statusScript: "/home/oli/dotfiles/scripts/network-status"
    readonly property string settingsScript: "/home/oli/dotfiles/scripts/network-settings"

    property bool pickerOpen: false
    property bool wifiAvailable: false
    property bool wifiEnabled: false
    property bool wifiConnected: false
    property string wifiDevice: ""
    property string wifiState: ""
    property string wifiSsid: ""
    property int wifiSignal: 0
    property bool ethernetAvailable: false
    property bool ethernetConnected: false
    property string ethernetDevice: ""
    property string ethernetState: ""
    property string ethernetConnection: ""
    property int ethernetSpeed: 0
    property int ethernetMaxSpeed: 0
    property bool dnsFailing: false
    property string tailscaleState: ""
    property var wifiNetworks: []
    property string statusError: ""
    property string actionMessage: ""
    property bool actionMessageIsError: false
    property bool pendingScanRefresh: false
    property bool pendingToggleEnabled: false
    property bool pendingTailscaleEnabled: false
    property string pendingWifiTargetSsid: ""
    property bool toggleCommandActive: false
    property bool tailscaleCommandActive: false
    property bool connectCommandActive: false
    property bool settingsCommandActive: false

    readonly property bool busy: wifiToggleProcess.running || tailscaleToggleProcess.running || wifiConnectProcess.running || settingsProcess.running
    readonly property bool tailscaleConnected: tailscaleState === "Running"
    readonly property bool tailscaleToggleable: tailscaleConnected || tailscaleState === "Stopped"
    readonly property string tailscaleSummary: tailscaleConnected
        ? "online"
        : (tailscaleState === "" ? "unavailable" : (tailscaleState === "Stopped" ? "off" : "logged out"))
    readonly property bool ethernetSlow: ethernetConnected && ethernetSpeed > 0 && ethernetSpeed < ethernetMaxSpeed
    readonly property string ethernetSummary: !ethernetConnected
        ? (ethernetAvailable ? "offline" : "unavailable")
        : (ethernetSpeed <= 0 ? "online" : (ethernetSlow
            ? `${ethernetSpeed / 1000}/${ethernetMaxSpeed / 1000} Gbit/s`
            : (ethernetSpeed >= 1000 ? `${ethernetSpeed / 1000} Gbit/s` : `${ethernetSpeed} Mbit/s`)))
    readonly property string ethernetDetail: ethernetConnected
        ? (ethernetConnection || ethernetDevice || "wired connected")
        : (ethernetAvailable ? "No active wired connection" : "No ethernet adapter detected")
    readonly property string wifiSummary: wifiConnected
        ? (wifiSsid || "connected")
        : (!wifiAvailable ? "unavailable" : (!wifiEnabled ? "off" : "not connected"))
    readonly property string wifiDetail: wifiConnected
        ? (wifiSignal > 0 ? `Signal ${wifiSignal}%` : "Wireless connected")
        : (!wifiAvailable ? "No Wi-Fi adapter detected" : (!wifiEnabled ? "Wireless is turned off" : "Choose a network"))
    readonly property string noticeText: actionMessage.length > 0 ? actionMessage : statusError
    readonly property bool noticeIsError: actionMessage.length > 0 ? actionMessageIsError : statusError.length > 0

    function setNotice(message, isError) {
        actionMessage = message || "";
        actionMessageIsError = isError === true;

        if (actionMessage.length > 0) {
            noticeTimer.restart();
        } else {
            noticeTimer.stop();
        }
    }

    function summarizeProcessOutput(text, fallback) {
        const lines = (text || "").split(/\r?\n/).map(line => line.trim()).filter(line => line.length > 0);
        const summary = lines.length > 0 ? lines[lines.length - 1].replace(/^Error:\s*/i, "") : "";

        return summary.length > 0 ? summary : fallback;
    }

    function refresh(includeScan) {
        pendingScanRefresh = pendingScanRefresh || includeScan === true;

        if (statusProcess.running) {
            return;
        }

        const shouldScan = pickerOpen || pendingScanRefresh;
        pendingScanRefresh = false;
        statusProcess.exec([statusScript, shouldScan ? "--scan" : "--summary"]);
    }

    function openPanel() {
        pickerOpen = true;
        refresh(true);
    }

    function closePanel() {
        pickerOpen = false;
    }

    function applyStatus(rawStatus) {
        let payload = null;

        try {
            payload = JSON.parse((rawStatus || "").trim() || "{}");
        } catch (error) {
            statusError = `Unable to parse network status: ${error}`;
            return;
        }

        const wifi = payload.wifi || {};
        const ethernet = payload.ethernet || {};

        wifiAvailable = wifi.available === true;
        wifiEnabled = wifi.enabled === true;
        wifiConnected = wifi.connected === true;
        wifiDevice = wifi.device || "";
        wifiState = wifi.state || "";
        wifiSsid = wifi.ssid || "";
        wifiSignal = isFinite(Number(wifi.signal)) ? Number(wifi.signal) : 0;

        ethernetAvailable = ethernet.available === true;
        ethernetConnected = ethernet.connected === true;
        ethernetDevice = ethernet.device || "";
        ethernetState = ethernet.state || "";
        ethernetConnection = ethernet.connection || "";
        ethernetSpeed = isFinite(Number(ethernet.speed)) ? Number(ethernet.speed) : 0;
        ethernetMaxSpeed = isFinite(Number(ethernet.maxSpeed)) ? Number(ethernet.maxSpeed) : 0;
        dnsFailing = payload.dnsFailing === true;
        tailscaleState = (payload.tailscale || {}).state || "";

        wifiNetworks = Array.isArray(payload.networks) ? payload.networks : [];
        statusError = payload.error || "";
    }

    function toggleWifi() {
        if (!wifiAvailable || wifiToggleProcess.running) {
            return;
        }

        pendingToggleEnabled = !wifiEnabled;
        setNotice(pendingToggleEnabled ? "Turning Wi-Fi on..." : "Turning Wi-Fi off...", false);
        wifiToggleProcess.exec(["nmcli", "radio", "wifi", pendingToggleEnabled ? "on" : "off"]);
        delayedRefreshTimer.restart();
    }

    function toggleTailscale() {
        if (!tailscaleToggleable || tailscaleToggleProcess.running) {
            return;
        }

        pendingTailscaleEnabled = !tailscaleConnected;
        setNotice(pendingTailscaleEnabled ? "Connecting Tailscale..." : "Disconnecting Tailscale...", false);
        tailscaleToggleProcess.exec(["tailscale", pendingTailscaleEnabled ? "up" : "down"]);
    }

    function connectWifiNetwork(network) {
        if (!network || !network.ssid || !wifiEnabled || wifiConnectProcess.running) {
            return;
        }

        if (network.active === true) {
            setNotice(`${network.ssid} is already connected.`, false);
            return;
        }

        const command = ["nmcli", "device", "wifi", "connect", network.ssid];

        if (network.bssid) {
            command.push("bssid", network.bssid);
        }

        if (wifiDevice) {
            command.push("ifname", wifiDevice);
        }

        pendingWifiTargetSsid = network.ssid;
        setNotice(`Connecting to ${network.ssid}...`, false);
        wifiConnectProcess.exec(command);
        delayedRefreshTimer.restart();
    }

    function openSettings() {
        if (settingsProcess.running) {
            return;
        }

        setNotice("Opening network settings...", false);
        settingsProcess.running = true;
    }

    Component.onCompleted: refresh(false)

    onPickerOpenChanged: {
        if (pickerOpen) {
            refresh(true);
        }
    }

    Timer {
        id: statusPollTimer

        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh(false)
    }

    Timer {
        id: panelPollTimer

        interval: 7000
        running: root.pickerOpen
        repeat: true
        onTriggered: root.refresh(true)
    }

    Timer {
        id: delayedRefreshTimer

        interval: 700
        repeat: false
        onTriggered: root.refresh(root.pickerOpen)
    }

    Timer {
        id: noticeTimer

        interval: 4000
        repeat: false
        onTriggered: {
            if (!root.busy) {
                root.actionMessage = "";
                root.actionMessageIsError = false;
            }
        }
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }

        onRunningChanged: {
            if (!running && root.pendingScanRefresh) {
                root.refresh(root.pendingScanRefresh);
            }
        }
    }

    Process {
        id: wifiToggleProcess

        stderr: StdioCollector {
            id: wifiToggleError
        }

        onStarted: root.toggleCommandActive = true

        onRunningChanged: {
            if (running || !root.toggleCommandActive) {
                return;
            }

            root.toggleCommandActive = false;
            delayedRefreshTimer.restart();

            if ((wifiToggleError.text || "").trim().length === 0) {
                root.setNotice(root.pendingToggleEnabled ? "Wi-Fi turned on." : "Wi-Fi turned off.", false);
                return;
            }

            root.setNotice(root.summarizeProcessOutput(wifiToggleError.text, "Unable to change the Wi-Fi radio state."), true);
        }
    }

    Process {
        id: tailscaleToggleProcess

        stderr: StdioCollector {
            id: tailscaleToggleError
        }

        onStarted: root.tailscaleCommandActive = true

        onRunningChanged: {
            if (running || !root.tailscaleCommandActive) {
                return;
            }

            root.tailscaleCommandActive = false;
            delayedRefreshTimer.restart();

            if ((tailscaleToggleError.text || "").trim().length === 0) {
                root.setNotice(root.pendingTailscaleEnabled ? "Tailscale connected." : "Tailscale disconnected.", false);
                return;
            }

            root.setNotice(root.summarizeProcessOutput(tailscaleToggleError.text, "Unable to change the Tailscale connection."), true);
        }
    }

    Process {
        id: wifiConnectProcess

        stderr: StdioCollector {
            id: wifiConnectError
        }

        onStarted: root.connectCommandActive = true

        onRunningChanged: {
            if (running || !root.connectCommandActive) {
                return;
            }

            root.connectCommandActive = false;
            delayedRefreshTimer.restart();

            if ((wifiConnectError.text || "").trim().length === 0) {
                root.setNotice(`Connected to ${root.pendingWifiTargetSsid}.`, false);
                return;
            }

            root.setNotice(root.summarizeProcessOutput(wifiConnectError.text, "Unable to join that Wi-Fi network from the island."), true);
        }
    }

    Process {
        id: settingsProcess

        command: [root.settingsScript]

        stderr: StdioCollector {
            id: settingsError
        }

        onStarted: root.settingsCommandActive = true

        onRunningChanged: {
            if (running || !root.settingsCommandActive) {
                return;
            }

            root.settingsCommandActive = false;

            if ((settingsError.text || "").trim().length === 0) {
                root.setNotice("Opened network settings.", false);
                return;
            }

            root.setNotice(root.summarizeProcessOutput(settingsError.text, "No supported network settings application was found."), true);
        }
    }
}
