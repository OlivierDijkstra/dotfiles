import QtQuick
import QtTest
import "../components" as UI

TestCase {
    id: testCase

    name: "IslandTransitions"
    when: windowShown
    visible: true
    width: 640
    height: 400

    Component {
        id: sceneComponent

        Item {
            id: scene

            width: 640
            height: 400
            property alias scaffold: scaffold
            property alias controller: controller
            property alias pill: pill
            property alias box: box
            property alias other: other

            QtObject {
                id: controller
                property var activeLayout: pill
                property bool hovered: false
            }

            Item {
                id: pill
                property string layoutKey: "pill"
                property real surfaceWidth: 200
                property real surfaceHeight: 36
                property real surfaceRadius: 18
                property bool available: true
                Rectangle { anchors.fill: parent; anchors.margins: 10; color: "white" }
            }

            Item {
                id: box
                property string layoutKey: "box"
                property real surfaceWidth: 380
                property real surfaceHeight: 220
                property real surfaceRadius: 28
                property bool available: true
                Rectangle { anchors.fill: parent; anchors.margins: 30; color: "white" }
            }

            Item {
                id: other
                property string layoutKey: "other"
                property real surfaceWidth: 200
                property real surfaceHeight: 36
                property real surfaceRadius: 18
                property bool available: true
            }

            UI.IslandScaffold {
                id: scaffold
                x: (parent.width - width) / 2
                controller: controller
                widgets: [pill, box, other]
                topMargin: 0
            }
        }
    }

    property var scene

    function initTestCase() {
        failOnWarning(/.*/)
    }

    function init() {
        scene = createTemporaryObject(sceneComponent, testCase)
        verify(scene !== null)
        tryCompare(scene.pill.parent, "opacity", 1)
    }

    function settle(layout) {
        tryCompare(scene.scaffold, "transitionPhase", "idle")
        compare(scene.scaffold.widgetLayoutKey, layout.layoutKey)
        tryCompare(layout.parent, "opacity", 1)
        compare(scene.scaffold.surfaceItem.contentWidth, layout.surfaceWidth)
        compare(scene.scaffold.surfaceItem.height, layout.surfaceHeight)
        verify(!layout.parent.layer.enabled)
    }

    function test_initialGeometry() {
        verify(!scene.scaffold.surfaceItem.morphRunning)
        settle(scene.pill)
    }

    function test_hideBeforeMorphAndRevealAfter() {
        scene.controller.activeLayout = scene.box
        compare(scene.scaffold.transitionPhase, "hiding")
        compare(scene.scaffold.surfaceItem.contentWidth, scene.pill.surfaceWidth)
        tryCompare(scene.scaffold, "transitionPhase", "morphing")
        compare(scene.pill.parent.opacity, 0)
        verify(!scene.pill.parent.visible)
        verify(!scene.pill.parent.layer.enabled)
        compare(scene.scaffold.widgetLayoutKey, "pill")
        compare(scene.box.width, scene.box.surfaceWidth)
        compare(scene.other.width, scene.other.surfaceWidth)
        settle(scene.box)
    }

    function test_reverseWhileHiding() {
        scene.controller.activeLayout = scene.box
        wait(40)
        verify(scene.pill.parent.opacity < 1)
        scene.controller.activeLayout = scene.pill
        compare(scene.scaffold.transitionPhase, "idle")
        settle(scene.pill)
        wait(250)
        compare(scene.scaffold.widgetLayoutKey, "pill")
    }

    function test_reverseWhileMorphing() {
        scene.controller.activeLayout = scene.box
        tryCompare(scene.scaffold, "transitionPhase", "morphing")
        wait(60)
        scene.controller.activeLayout = scene.pill
        settle(scene.pill)
    }

    function test_reverseWhileRevealing() {
        scene.controller.activeLayout = scene.box
        tryCompare(scene.scaffold, "widgetLayoutKey", "box")
        verify(scene.box.parent.opacity < 1)
        scene.controller.activeLayout = scene.pill
        settle(scene.pill)
    }

    function test_sameGeometryDifferentContent() {
        scene.controller.activeLayout = scene.other
        settle(scene.other)
    }

    function test_outgoingWidgetBecomesUnavailable() {
        scene.pill.available = false
        scene.controller.activeLayout = scene.box
        settle(scene.box)
    }

    function test_dimensionsChangeDuringMorph() {
        scene.controller.activeLayout = scene.box
        tryCompare(scene.scaffold, "transitionPhase", "morphing")
        wait(60)
        scene.box.surfaceHeight = 280
        scene.box.surfaceWidth = 420
        settle(scene.box)
    }

    function test_liveDimensionsStayInsideSurface() {
        scene.pill.surfaceWidth = 320
        wait(40)
        const surface = scene.scaffold.surfaceItem
        verify(surface.contentWidth > 200 && surface.contentWidth < 320)
        for (let frame = 0; frame < 15; frame++) {
            fuzzyCompare(surface.width, surface.contentWidth + 2 * surface.shoulderRadius, 0.001)
            fuzzyCompare(scene.pill.width, surface.contentWidth, 0.001)
            compare(scene.box.width, scene.box.surfaceWidth)
            verify(surface.contentWidth <= 320)
            wait(16)
        }
        settle(scene.pill)
    }

    function test_renderedContentSurvivesLayerHandoff() {
        // Sample the white content over the black surface before, during,
        // and after the temporary blur layer. A missing source turns it black.
        const initial = grabImage(scene)
        compare(initial.red(320, 18), 255)
        scene.controller.activeLayout = scene.box
        wait(30)
        verify(scene.pill.parent.layer.enabled)
        const fading = grabImage(scene)
        verify(fading.red(320, 18) > 0)
        verify(fading.red(320, 18) < 255)
        settle(scene.box)
        const expanded = grabImage(scene)
        compare(expanded.red(320, 110), 255)
        compare(expanded.red(320, 10), 0)
    }

    function test_rapidRequestsConverge() {
        const layouts = [scene.box, scene.other, scene.pill, scene.box]
        for (let index = 0; index < 16; index++) {
            scene.controller.activeLayout = layouts[index % layouts.length]
            wait(30)
        }
        scene.controller.activeLayout = scene.other
        settle(scene.other)
    }
}
