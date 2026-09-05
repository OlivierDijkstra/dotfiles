import QtQuick
import "Motion.js" as Motion

NumberAnimation {
    duration: Motion.morphDuration
    easing.type: Easing.InOutCubic
}
