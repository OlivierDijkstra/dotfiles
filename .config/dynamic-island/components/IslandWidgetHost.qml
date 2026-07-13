pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "Motion.js" as Motion

Item {
    id: root

    property var widgets: []
    property string layoutKey: ""
    property real contentOpacity: 0
    property real contentBlur: 0
    readonly property bool effectActive: root.contentBlur > 0.001
    signal hideFinished

    function widgetVisible(widget, layoutKey) {
        return widget && widget.layoutKey === layoutKey && widget.available !== false
    }

    function hasWidgetsForLayout(layoutKey) {
        for (let index = 0; index < widgets.length; index += 1) {
            if (widgetVisible(widgets[index], layoutKey)) {
                return true
            }
        }

        return false
    }

    function attachWidgets() {
        for (let index = 0; index < widgets.length; index += 1) {
            const widget = widgets[index]

            if (!widget) {
                continue
            }

            widget.parent = widgetContent
            widget.width = Qt.binding(function() {
                return widgetContent.width
            })
            widget.height = Qt.binding(function() {
                return widgetContent.height
            })
            widget.x = 0
            widget.y = 0
            widget.visible = Qt.binding(function() {
                return root.widgetVisible(widget, root.layoutKey)
            })
        }
    }

    function hideCurrent() {
        revealTimer.stop()

        if (!hasWidgetsForLayout(layoutKey)) {
            contentOpacity = 0
            contentBlur = 0
            hideFinished()
            return
        }

        if (hideTimer.running) {
            return
        }

        contentOpacity = 0
        contentBlur = Motion.widgetBlur
        hideTimer.restart()
    }

    function revealCurrent() {
        hideTimer.stop()

        if (!hasWidgetsForLayout(layoutKey)) {
            contentOpacity = 0
            contentBlur = 0
            return
        }

        contentOpacity = 0
        contentBlur = Motion.widgetBlur
        revealTimer.restart()
    }

    Behavior on contentOpacity {
        NumberAnimation {
            duration: Motion.widgetTransitionDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on contentBlur {
        NumberAnimation {
            duration: Motion.widgetTransitionDuration
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: hideTimer

        interval: Motion.widgetTransitionDuration
        onTriggered: root.hideFinished()
    }

    Timer {
        id: revealTimer

        interval: 0
        onTriggered: {
            root.contentOpacity = 1
            root.contentBlur = 0
        }
    }

    Component.onCompleted: attachWidgets()
    onWidgetsChanged: attachWidgets()

    Item {
        id: widgetContent

        anchors.fill: parent
        clip: true
        opacity: root.effectActive ? 1 : root.contentOpacity
    }

    Loader {
        anchors.fill: widgetContent
        active: root.effectActive

        sourceComponent: Component {
            Item {
                anchors.fill: parent

                ShaderEffectSource {
                    id: widgetSource

                    anchors.fill: parent
                    sourceItem: widgetContent
                    live: true
                    hideSource: true
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent
                    opacity: root.contentOpacity
                    source: widgetSource
                    blurEnabled: root.contentBlur > 0
                    blur: root.contentBlur
                    blurMax: Motion.widgetBlurMax
                    autoPaddingEnabled: false
                }
            }
        }
    }
}
