import QtQuick
import Quickshell.Wayland

Item {
    id: root

    visible: false
    width: 0
    height: 0

    required property var window
    readonly property int stepSeconds: 30 * 60

    property bool active: false
    // 0 keeps the system awake until turned off; otherwise a Date.now() deadline.
    property real endsAt: 0
    property int remainingSeconds: 0
    readonly property bool timed: active && endsAt > 0
    readonly property string remainingText: {
        const minutes = Math.ceil(remainingSeconds / 60);
        const hours = Math.floor(minutes / 60);

        if (hours === 0) {
            return `${minutes}m`;
        }

        return minutes % 60 ? `${hours}h ${minutes % 60}m` : `${hours}h`;
    }

    function toggle() {
        active = !active;
        endsAt = 0;
    }

    // Scrolling sets a timer in 30-minute steps, snapped to the step grid.
    // Scrolling down past zero turns it off; scrolling down while indefinite does nothing.
    function adjust(steps) {
        if (active && !timed && steps < 0) {
            return;
        }

        const seconds = (Math.ceil((timed ? remainingSeconds : 0) / stepSeconds) + steps) * stepSeconds;

        if (seconds <= 0) {
            active = false;
            endsAt = 0;
            return;
        }

        active = true;
        endsAt = Date.now() + seconds * 1000;
        remainingSeconds = seconds;
    }

    // Hypridle honours Wayland idle inhibitors, pausing its lock, DPMS, and suspend listeners.
    IdleInhibitor {
        window: root.window
        enabled: root.active
    }

    Timer {
        interval: 1000
        running: root.timed
        repeat: true
        onTriggered: {
            root.remainingSeconds = Math.max(0, Math.round((root.endsAt - Date.now()) / 1000));

            if (root.remainingSeconds === 0) {
                root.active = false;
                root.endsAt = 0;
            }
        }
    }
}
