import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var activePlayer: root.selectActivePlayer()
    readonly property bool hasActivePlayer: activePlayer !== null

    function selectActivePlayer() {
        const candidates = players || []

        for (let index = 0; index < candidates.length; index += 1) {
            const candidate = candidates[index]

            if (candidate && candidate.isPlaying) {
                return candidate
            }
        }

        for (let index = 0; index < candidates.length; index += 1) {
            const candidate = candidates[index]

            if (candidate) {
                return candidate
            }
        }

        return null
    }
}
