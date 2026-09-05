import QtQuick

Item {
    id: root

    required property var controller
    property var widgets: []
    property int topMargin: 8
    property var displayedLayout: null
    property var pendingLayout: null
    property string widgetLayoutKey: ""
    property string transitionPhase: "idle"
    property bool initialized: false
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

        if (transitionPhase === "hiding") {
            if (pendingLayout === displayedLayout) {
                transitionPhase = "idle"
                widgetHost.revealCurrent()
            }
            return
        }

        if (transitionPhase === "morphing") {
            displayedLayout = pendingLayout
            return
        }

        if (pendingLayout === displayedLayout) {
            return
        }

        transitionPhase = "hiding"
        widgetHost.hideCurrent()
    }

    function finishLayoutTransition() {
        if (transitionPhase !== "morphing" || surface.morphRunning) {
            return
        }

        widgetLayoutKey = displayedLayout.layoutKey
        transitionPhase = "idle"
        widgetHost.revealCurrent()
    }

    Component.onCompleted: {
        requestLayoutTransition()
        initialized = true
    }

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
            animate: root.initialized
            onMorphFinished: root.finishLayoutTransition()
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

            x: surface.shoulderRadius
            width: surface.contentWidth
            height: surface.height

            widgets: root.widgets
            layoutKey: root.widgetLayoutKey
            onHideFinished: {
                if (root.transitionPhase !== "hiding" || !root.pendingLayout) {
                    return
                }

                root.transitionPhase = "morphing"
                root.displayedLayout = root.pendingLayout
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
