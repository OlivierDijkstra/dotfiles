pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "Motion.js" as Motion

Item {
    id: root

    property var widgets: []
    property string layoutKey: ""
    property real contentOpacity: 0
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
            // Inactive widgets retain their own layout instead of relaying
            // every animation frame through all the hidden panels.
            widget.width = Qt.binding(function() {
                return widget.visible ? widgetContent.width : widget.surfaceWidth
            })
            widget.height = Qt.binding(function() {
                return widget.visible ? widgetContent.height : widget.surfaceHeight
            })
            widget.x = 0
            widget.y = 0
            widget.visible = Qt.binding(function() {
                return root.widgetVisible(widget, root.layoutKey)
            })
        }
    }

    function hideCurrent() {
        if (opacityAnimation.running && opacityAnimation.to === 0) {
            return
        }

        opacityAnimation.stop()

        if (!hasWidgetsForLayout(layoutKey) || contentOpacity === 0) {
            contentOpacity = 0
            hideFinished()
            return
        }

        opacityAnimation.to = 0
        opacityAnimation.start()
    }

    function revealCurrent() {
        opacityAnimation.stop()

        if (!hasWidgetsForLayout(layoutKey)) {
            contentOpacity = 0
            return
        }

        opacityAnimation.to = 1
        opacityAnimation.start()
    }

    NumberAnimation {
        id: opacityAnimation

        target: root
        property: "contentOpacity"
        duration: Motion.widgetTransitionDuration
        easing.type: Easing.OutCubic
        onFinished: {
            if (to === 0) {
                root.hideFinished()
            }
        }
    }

    Component.onCompleted: attachWidgets()
    onWidgetsChanged: attachWidgets()

    Item {
        id: widgetContent

        anchors.fill: parent
        clip: true
        visible: root.contentOpacity > 0
        enabled: root.contentOpacity === 1
        opacity: root.contentOpacity

        // A single temporary layer supplies the blur texture. Hidden and
        // settled content needs neither a texture capture nor a blur pass.
        layer.enabled: opacityAnimation.running && visible
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: (1 - root.contentOpacity) * Motion.widgetBlur
            blurMax: Motion.widgetBlurMax
            autoPaddingEnabled: false
        }
    }
}
