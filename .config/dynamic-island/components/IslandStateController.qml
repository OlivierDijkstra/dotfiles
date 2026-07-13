import QtQuick

QtObject {
    id: root

    property var layouts: []
    property bool hovered: false
    readonly property var exclusiveLayout: exclusiveAvailableLayout()
    readonly property var activeLayout: exclusiveLayout ? exclusiveLayout : (hovered ? lastAvailableLayout() : firstAvailableLayout())

    function exclusiveAvailableLayout() {
        for (let index = 0; index < layouts.length; index += 1) {
            const layout = layouts[index]

            if (layout && layout.exclusive === true && layout.available !== false) {
                return layout
            }
        }

        return null
    }

    function firstAvailableLayout() {
        for (let index = 0; index < layouts.length; index += 1) {
            const layout = layouts[index]

            if (layout && layout.exclusive !== true && layout.available !== false) {
                return layout
            }
        }

        return layouts.length > 0 ? layouts[0] : null
    }

    function lastAvailableLayout() {
        for (let index = layouts.length - 1; index >= 0; index -= 1) {
            const layout = layouts[index]

            if (layout && layout.exclusive !== true && layout.available !== false) {
                return layout
            }
        }

        return firstAvailableLayout()
    }
}
