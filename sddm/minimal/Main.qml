import QtQuick

Rectangle {
    id: root

    // Designed against the desktop's logical 1800px height (4K at scale 1.2).
    readonly property real s: height / 1800

    readonly property color fieldColor: "#000000"
    readonly property color border: "#333333"
    readonly property color borderStrong: "#484848"
    readonly property color foreground: "#F5F5F5"
    readonly property color disabled: "#737373"
    readonly property color danger: "#E57373"

    property string userName: userModel.lastUser
    property int sessionIndex: sessionModel.lastIndex
    property bool busy: false
    property bool failed: false

    function login() {
        if (busy || !userName)
            return
        busy = true
        failed = false
        sddm.login(userName, password.text, sessionIndex)
    }

    color: "#292929"

    Repeater {
        model: userModel
        Item {
            Component.onCompleted: {
                if (index === 0 && !root.userName)
                    root.userName = model.name
            }
        }
    }

    Repeater {
        model: sessionModel
        Item {
            Component.onCompleted: {
                if (config.session && String(model.file).endsWith("/" + config.session))
                    root.sessionIndex = index
            }
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.busy = false
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
            shake.restart()
        }
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Rectangle {
        id: field

        property real offset: 0

        x: Math.round((root.width - width) / 2 + offset)
        y: Math.round((root.height - height) / 2)
        width: 280 * root.s
        height: 40 * root.s
        radius: height / 2
        color: root.fieldColor
        border.width: Math.max(1, Math.round(root.s))
        border.color: root.failed ? root.danger : root.border

        Behavior on border.color { ColorAnimation { duration: 120 } }

        SequentialAnimation {
            id: shake

            NumberAnimation { target: field; property: "offset"; to: -10 * root.s; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: field; property: "offset"; to: 8 * root.s; duration: 70; easing.type: Easing.InOutQuad }
            NumberAnimation { target: field; property: "offset"; to: -5 * root.s; duration: 60; easing.type: Easing.InOutQuad }
            NumberAnimation { target: field; property: "offset"; to: 0; duration: 60; easing.type: Easing.OutQuad }
        }

        Text {
            anchors.fill: password
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            visible: !password.text
            color: root.failed ? root.danger : root.disabled
            text: root.failed ? "wrong password"
                : keyboard.capsLock ? "caps lock is on"
                : "password"
            font: password.font
        }

        TextInput {
            id: password

            anchors.fill: parent
            anchors.leftMargin: 18 * root.s
            anchors.rightMargin: 18 * root.s
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: TextInput.Password
            passwordCharacter: "•"
            passwordMaskDelay: 0
            color: root.foreground
            selectionColor: root.borderStrong
            selectedTextColor: root.foreground
            cursorDelegate: Item {}
            readOnly: root.busy
            clip: true
            focus: true
            font.family: "Geist"
            font.pixelSize: 14 * root.s
            font.weight: Font.Medium
            font.letterSpacing: text ? 2 * root.s : 0

            onTextChanged: if (text) root.failed = false
            onAccepted: root.login()
            Keys.onEscapePressed: text = ""
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
