import QtQuick
import QtTest
import "../components/widgets" as Widgets

TestCase {
    id: testCase
    name: "AudioState"

    Component {
        id: audioComponent
        QtObject {
            property real volume: 0.45
            property bool muted: false
        }
    }

    Component {
        id: nodeComponent
        QtObject {
            property int id: 1
            property bool ready: false
            property bool isSink: true
            property bool isStream: false
            property string description: "Speakers"
            property string nickname: ""
            property string name: "test-output"
            property var audio: null
        }
    }

    Component {
        id: volumeComponent
        Widgets.VolumeState {}
    }

    Component {
        id: routeComponent
        Widgets.AudioRouteState {}
    }

    Component {
        id: pipewireComponent
        QtObject {
            property var nodes: QtObject { property var values: [] }
            property var defaultAudioSink: null
            property var defaultAudioSource: null
            property var preferredDefaultAudioSink: null
            property var preferredDefaultAudioSource: null
        }
    }

    property var audio
    property var sink
    property var volume

    function initTestCase() {
        failOnWarning(/.*/)
    }

    function init() {
        audio = createTemporaryObject(audioComponent, testCase)
        sink = createTemporaryObject(nodeComponent, testCase, { audio: audio })
        volume = createTemporaryObject(volumeComponent, testCase, { sink: sink })
        verify(volume !== null)
        sink.ready = true
        tryCompare(volume, "initialized", true)
    }

    function test_initialSyncDoesNotShowOsd() {
        compare(volume.volumeLevel, 0.45)
        verify(volume.hasVolumeControl)
        verify(!volume.osdVisible)
    }

    function test_externalVolumeAndMuteShowOsd() {
        audio.volume = 0.6
        tryCompare(volume, "osdActive", true)
        compare(volume.volumeLevel, 0.6)
        volume.osdActive = false
        audio.muted = true
        tryCompare(volume, "osdActive", true)
        compare(volume.volumeVisual, 0)
    }

    function test_localSliderWritesAndUnmutesWithoutPopup() {
        audio.muted = true
        wait(0)
        volume.osdActive = false
        volume.setVolumeLevel(0.736)
        compare(audio.volume, 0.74)
        verify(!audio.muted)
        wait(0)
        verify(!volume.osdActive)
        volume.toggleMute()
        verify(audio.muted)
        wait(0)
        verify(!volume.osdActive)
    }

    function test_volumeBoundsAndInvalidInput() {
        volume.setVolumeLevel(2)
        compare(audio.volume, 1)
        volume.setVolumeLevel(-1)
        compare(audio.volume, 0)
        volume.setVolumeLevel(NaN)
        compare(audio.volume, 0)
        audio.volume = 1.5
        compare(volume.volumeLevel, 1)
    }

    function test_sinkLossAndReplacementDoNotShowOsd() {
        audio.volume = 0.7
        tryCompare(volume, "osdActive", true)
        volume.sink = null
        tryCompare(volume, "initialized", false)
        verify(!volume.hasVolumeControl)
        verify(!volume.osdVisible)
        volume.setVolumeLevel(0.2)
        compare(audio.volume, 0.7)
        const replacementAudio = createTemporaryObject(audioComponent, testCase, { volume: 0.2 })
        const replacement = createTemporaryObject(nodeComponent, testCase, { audio: replacementAudio })
        volume.sink = replacement
        wait(0)
        verify(!volume.initialized)
        replacement.ready = true
        tryCompare(volume, "initialized", true)
        compare(volume.volumeLevel, 0.2)
        verify(!volume.osdActive)
        replacementAudio.volume = 0.3
        tryCompare(volume, "osdActive", true)
    }

    function test_deviceListHotplugDefaultsAndSelection() {
        const pipewire = createTemporaryObject(pipewireComponent, testCase)
        const routes = createTemporaryObject(routeComponent, testCase, { pipewire: pipewire })
        const microphone = createTemporaryObject(nodeComponent, testCase, { id: 2, audio: audio, isSink: false, description: "Mic" })
        const stream = createTemporaryObject(nodeComponent, testCase, { id: 3, audio: audio, isStream: true })
        pipewire.nodes.values = [sink, microphone, stream]
        pipewire.defaultAudioSink = sink
        pipewire.defaultAudioSource = microphone
        compare(routes.sinks.length, 1)
        compare(routes.sources.length, 1)
        compare(routes.sources[0].name, "Mic")
        verify(routes.sinks[0].isDefault)
        routes.openPanel("input")
        routes.selectDevice(2)
        compare(pipewire.preferredDefaultAudioSource, microphone)
        verify(!routes.pickerOpen)
        routes.openPanel("output")
        routes.selectDevice(1)
        compare(pipewire.preferredDefaultAudioSink, sink)
        pipewire.nodes.values = [microphone]
        tryCompare(routes, "activePanel", "input")
        compare(routes.sinks.length, 0)
        routes.openPanel("input")
        routes.selectDevice(1)
        verify(routes.pickerOpen)
        pipewire.defaultAudioSource = null
        verify(!routes.sources[0].isDefault)
    }
}
