import QtQuick
import QtQuick.Shapes
import "." as Theme

Item {
    id: root

    property var layout: null
    property real cornerRadius: layout ? layout.surfaceRadius : height / 2
    readonly property real shoulderRadius: Math.min(12, height / 3, cornerRadius)
    readonly property real contentWidth: layout ? layout.surfaceWidth : 0

    width: contentWidth + (shoulderRadius * 2)
    height: layout ? layout.surfaceHeight : 0

    Behavior on width {
        animation: IslandMorphAnimation {}
    }

    Behavior on height {
        animation: IslandMorphAnimation {}
    }

    Behavior on cornerRadius {
        animation: IslandMorphAnimation {}
    }

    Shape {
        anchors.fill: parent

        ShapePath {
            id: surfacePath

            readonly property real curve: 0.55228475
            readonly property real left: root.shoulderRadius
            readonly property real right: root.width - root.shoulderRadius

            fillColor: Theme.Palette.islandBackground
            strokeColor: "transparent"
            startX: 0
            startY: 0

            PathLine {
                x: root.width
                y: 0
            }
            PathCubic {
                control1X: root.width - (root.shoulderRadius * surfacePath.curve)
                control1Y: 0
                control2X: surfacePath.right
                control2Y: root.shoulderRadius * (1 - surfacePath.curve)
                x: surfacePath.right
                y: root.shoulderRadius
            }
            PathLine {
                x: surfacePath.right
                y: root.height - root.cornerRadius
            }
            PathCubic {
                control1X: surfacePath.right
                control1Y: root.height - root.cornerRadius + (root.cornerRadius * surfacePath.curve)
                control2X: surfacePath.right - root.cornerRadius + (root.cornerRadius * surfacePath.curve)
                control2Y: root.height
                x: surfacePath.right - root.cornerRadius
                y: root.height
            }
            PathLine {
                x: surfacePath.left + root.cornerRadius
                y: root.height
            }
            PathCubic {
                control1X: surfacePath.left + root.cornerRadius - (root.cornerRadius * surfacePath.curve)
                control1Y: root.height
                control2X: surfacePath.left
                control2Y: root.height - root.cornerRadius + (root.cornerRadius * surfacePath.curve)
                x: surfacePath.left
                y: root.height - root.cornerRadius
            }
            PathLine {
                x: surfacePath.left
                y: root.shoulderRadius
            }
            PathCubic {
                control1X: surfacePath.left
                control1Y: root.shoulderRadius * (1 - surfacePath.curve)
                control2X: root.shoulderRadius * surfacePath.curve
                control2Y: 0
                x: 0
                y: 0
            }
        }
    }
}
