import QtQuick
import "Motion.js" as Motion

Item {
    id: root

    required property var controller
    property var widgets: []
    property int topMargin: 8
    property var displayedLayout: null
    property var pendingLayout: null
    property string widgetLayoutKey: ""
    readonly property alias surfaceItem: surface

    implicitWidth: surface.width
    implicitHeight: topMargin + surface.height

    function requestLayoutTransition() {
        const nextLayout = controller ? controller.activeLayout : null

        if (!nextLayout) {
            return
        }

        pendingLayout = nextLayout

        if (!displayedLayout) {
            displayedLayout = nextLayout
            widgetLayoutKey = nextLayout.layoutKey
            widgetHost.revealCurrent()
            return
        }

        if (!layoutMorphTimer.running && pendingLayout.layoutKey === displayedLayout.layoutKey) {
            if (widgetLayoutKey !== displayedLayout.layoutKey) {
                widgetLayoutKey = displayedLayout.layoutKey
                widgetHost.revealCurrent()
            }
            return
        }

        if (layoutMorphTimer.running) {
            return
        }

        widgetHost.hideCurrent()
    }

    Component.onCompleted: requestLayoutTransition()

    onControllerChanged: {
        if (controller) {
            controller.hovered = hoverHandler.hovered
        }

        requestLayoutTransition()
    }

    Item {
        x: Math.round((parent.width - width) / 2)
        y: root.topMargin
        width: surface.width
        height: surface.height

        IslandSurface {
            id: surface

            x: 0
            y: 0

            layout: root.displayedLayout
        }

        HoverHandler {
            id: hoverHandler

            target: null
            onHoveredChanged: {
                if (root.controller) {
                    root.controller.hovered = hovered
                }
            }

            Component.onCompleted: {
                if (root.controller) {
                    root.controller.hovered = hovered
                }
            }
        }

        IslandWidgetHost {
            id: widgetHost

            anchors.fill: surface

            widgets: root.widgets
            layoutKey: root.widgetLayoutKey
            onHideFinished: {
                if (!root.pendingLayout) {
                    return
                }

                root.displayedLayout = root.pendingLayout
                layoutMorphTimer.restart()
            }
        }

        Timer {
            id: layoutMorphTimer

            interval: Motion.morphDuration
            onTriggered: {
                if (root.pendingLayout && root.pendingLayout.layoutKey !== root.displayedLayout.layoutKey) {
                    root.displayedLayout = root.pendingLayout
                    restart()
                    return
                }

                root.widgetLayoutKey = root.displayedLayout ? root.displayedLayout.layoutKey : ""
                widgetHost.revealCurrent()
            }
        }
    }

    Connections {
        target: root.controller

        function onActiveLayoutChanged() {
            root.requestLayoutTransition()
        }
    }
}
