import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: mprisService
    
    property bool hasPlayers: Mpris.players.values.length > 0
    property var activePlayer: getActivePlayer()
    property string artist: activePlayer ? (activePlayer.trackArtist || "") : ""
    property string title: activePlayer ? (activePlayer.trackTitle || "") : ""
    property string fullText: artist && title ? artist + " - " + title : title
    
    function getActivePlayer() {
        var players = Mpris.players.values;
        var playingPlayer = null;
        var pausedPlayer = null;
        
        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === Mpris.Playing) {
                playingPlayer = players[i];
                break;
            } else if (!pausedPlayer && players[i].playbackState === Mpris.Paused) {
                pausedPlayer = players[i];
            }
        }
        
        return playingPlayer || pausedPlayer || (players.length > 0 ? players[0] : null);
    }
    
    property var playerWatcher: Connections {
        target: Mpris.players
        function onValuesChanged() {
            mprisService.activePlayer = mprisService.getActivePlayer();
        }
    }
}
