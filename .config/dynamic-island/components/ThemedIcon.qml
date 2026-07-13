pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "." as Theme

Image {
    id: root

    property color color: Theme.Palette.foreground

    layer.enabled: true
    layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: root.color
    }
}
