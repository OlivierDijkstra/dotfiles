import QtQuick
import "Palette.js" as Palette

Item {
    id: root

    property var layout: null

    width: layout ? layout.surfaceWidth : 0
    height: layout ? layout.surfaceHeight : 0

    Behavior on width {
        animation: IslandMorphAnimation {}
    }

    Behavior on height {
        animation: IslandMorphAnimation {}
    }

    Rectangle {
        anchors.fill: parent
        radius: root.layout ? root.layout.surfaceRadius : height / 2
        color: Palette.islandBackground

        Behavior on radius {
            animation: IslandMorphAnimation {}
        }
    }
}
