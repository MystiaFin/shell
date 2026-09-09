pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property string selectedPlayerName: ""

    readonly property var players: Mpris.players.values.filter(player =>
        player.playbackState !== MprisPlaybackState.Stopped
        && (player.trackTitle !== "" || player.trackArtist !== ""))
    readonly property var currentPlayer: {
        for (const player of players) {
            if (player.dbusName === selectedPlayerName)
                return player;
        }
        return null;
    }
    readonly property int currentIndex: {
        for (let index = 0; index < players.length; index++) {
            if (players[index].dbusName === selectedPlayerName)
                return index;
        }
        return -1;
    }
    readonly property int playerCount: players.length
    readonly property bool available: currentPlayer !== null
    readonly property string title: currentPlayer ? currentPlayer.trackTitle : ""
    readonly property string artist: currentPlayer ? currentPlayer.trackArtist : ""
    readonly property string album: currentPlayer ? currentPlayer.trackAlbum : ""
    readonly property string artUrl: currentPlayer ? currentPlayer.trackArtUrl : ""
    readonly property string playerName: currentPlayer ? currentPlayer.identity : ""
    readonly property bool playing: currentPlayer ? currentPlayer.isPlaying : false
    readonly property real positionSeconds: currentPlayer ? currentPlayer.position : 0
    readonly property real durationSeconds: currentPlayer ? currentPlayer.length : 0
    readonly property bool canGoPrevious: currentPlayer
        ? currentPlayer.canGoPrevious : false
    readonly property bool canTogglePlaying: currentPlayer
        ? currentPlayer.canTogglePlaying : false
    readonly property bool canGoNext: currentPlayer ? currentPlayer.canGoNext : false

    function ensureSelection(): void {
        if (currentPlayer || players.length === 0) {
            if (players.length === 0)
                selectedPlayerName = "";
            return;
        }

        const playingPlayer = players.find(player => player.isPlaying);
        selectedPlayerName = (playingPlayer || players[0]).dbusName;
    }

    function selectRelative(offset: int): void {
        if (players.length < 2)
            return;
        const index = currentIndex >= 0 ? currentIndex : 0;
        const nextIndex = (index + offset + players.length) % players.length;
        selectedPlayerName = players[nextIndex].dbusName;
    }

    function previous(): void {
        if (currentPlayer && currentPlayer.canGoPrevious)
            currentPlayer.previous();
    }

    function playPause(): void {
        if (currentPlayer && currentPlayer.canTogglePlaying)
            currentPlayer.togglePlaying();
    }

    function next(): void {
        if (currentPlayer && currentPlayer.canGoNext)
            currentPlayer.next();
    }

    onPlayersChanged: Qt.callLater(ensureSelection)

    Timer {
        interval: 1000
        running: root.currentPlayer && root.currentPlayer.isPlaying
        repeat: true
        onTriggered: root.currentPlayer.positionChanged()
    }

    Component.onCompleted: Qt.callLater(ensureSelection)
}
