// ignore_for_file: cast_nullable_to_non_nullable

/// A library to interface D-Bus MPRIS media players on linux systems.
library mpris;

import 'package:dbus/dbus.dart';

import 'generated/mediaplayer2.dart';
import 'generated/mediaplayer2_player.dart';

// ignore: public_member_api_docs
class MPRIS {
    final _client = DBusClient.session();

    /// Close the D-Bus MPRIS session
    Future close() async {
        await _client.close();
    }

    /// Gets all available MPRIS players in the D-Bus session
    Future<List<MPRISPlayer>> getPlayers() async => (await _client.listNames())
        .where((name) => name.startsWith('org.mpris.MediaPlayer2'))
        .map<MPRISPlayer>((name) => MPRISPlayer(_client, name))
        .toList();

    /// Get a player from it's name
    MPRISPlayer getPlayer(String name) => MPRISPlayer(_client, name);
}

// ignore: public_member_api_docs
class MPRISPlayer {
    // ignore: public_member_api_docs
    MPRISPlayer(
        DBusClient client,
        this.name,
    ): _servicePlayer = MediaPlayer2(client, name),
        _mediaPlayer = MediaPlayer2Player(client, name);

    /// Starts with `org.mpris.MediaPlayer2`
    final String name;
    final MediaPlayer2 _servicePlayer;
    final MediaPlayer2Player _mediaPlayer;

    /// A friendly name to identify the media player to users
    Future<String> getIdentity() => _servicePlayer.getIdentity();

    /// The basename of an installed .desktop file which complies with the <a href="http://standards.freedesktop.org/desktop-entry-spec/latest/">Desktop entry specification</a>, with the ".desktop" extension stripped
    Future<String> getDesktopEntry() => _servicePlayer.getDesktopEntry();

    /// The URI schemes supported by the media player
    Future<List<String>> getSupportedUriSchemes() => _servicePlayer.getSupportedUriSchemes();

    /// The mime-types supported by the media player
    Future<List<String>> getSupportedMimeTypes() => _servicePlayer.getSupportedMimeTypes();

    /// Indicates whether the media player has a track list available
    Future<bool> hasTrackList() => _servicePlayer.getHasTrackList();

    /// Whether the media player can bet set to occupy the fullscreen
    Future<bool> canSetFullscreen() => _servicePlayer.getCanSetFullscreen();

    /// Whether the media player is occupying the fullscreen
    Future<bool> isFullscreen() => _servicePlayer.getFullscreen();

    /// Set whether the media player should occupy the fullscreen
    Future setFullscreen(bool value) => _servicePlayer.setFullscreen(value);

    /// Whether the media player's user interface can be brought to the front using any appropriate mechanism available
    Future<bool> canRaise() => _servicePlayer.getCanRaise();

    /// Brings the media player's user interface to the front using any appropriate mechanism available
    Future raise() => _servicePlayer.callRaise();

    /// Whether the media player can be closed via [quit]
    Future<bool> canQuit() => _servicePlayer.getCanQuit();

    /// Causes the media player to stop running
    Future quit() => _servicePlayer.callQuit();

    /// Get the current loop / repeat status
    Future<LoopStatus> getLoopStatus() async {
        final status = await _mediaPlayer.getLoopStatus();
        switch (status) {
            case 'None':
                return LoopStatus.none;
            case 'Track':
                return LoopStatus.track;
            case 'Playlist':
                return LoopStatus.playlist;
            default:
                throw Exception("Unknown loop status '$status'");
        }
    }

    /// Set the current loop / repeat status
    Future setLoopStatus(LoopStatus status) async {
        String value;
        switch (status.index) {
            case 0:
                value = 'None';
                break;
            case 1:
                value = 'Track';
                break;
            case 2:
                value = 'Playlist';
                break;
            default:
                throw Exception("Unknown loop status '$status'");
        }
        await _mediaPlayer.setLoopStatus(value);
    }

    /// Get the current playback rate
    Future<double> getRate() => _mediaPlayer.getRate();

    /// Set the current playback rate
    Future setRate(double value) => _mediaPlayer.setRate(value);

    /// Get the current shuffle mode where `false` corresponds to linear playback and `true` corresponds to some other playback order
    Future<bool> getShuffle() => _mediaPlayer.getShuffle();

    /// Set the current shuffle mode. See [getShuffle]
    Future setShuffle(bool value) => _mediaPlayer.setShuffle(value);

    /// Get the metadata of the current element
    Future<Metadata> getMetadata() async => Metadata.fromMap(await _mediaPlayer.getMetadata());

    /// Get the playback status
    Future<PlaybackStatus> getPlaybackStatus() async {
        final status = await _mediaPlayer.getPlaybackStatus();
        switch (status) {
            case 'Playing':
                return PlaybackStatus.playing;
            case 'Paused':
                return PlaybackStatus.paused;
            case 'Stopped':
                return PlaybackStatus.stopped;
            default:
                throw Exception("Unknown playback status '$status'");
        }
    }

    /// Get the volume level
    Future<double> getVolume() => _mediaPlayer.getVolume();

    /// Set the volume level
    Future setVolume(double value) => _mediaPlayer.setVolume(value);

    /// Get the current track position
    Future<Duration> getPosition() async => Duration(microseconds: await _mediaPlayer.getPosition());

    /// Get the minimum value which the `rate` can take
    Future<double> getMinimumRate() => _mediaPlayer.getMinimumRate();

    /// Get the maximum value which the `rate` can take
    Future<double> getMaximumRate() => _mediaPlayer.getMaximumRate();

    /// Whether the client can call the [next] method and expect the current track to change
    Future<bool> canGoNext() => _mediaPlayer.getCanGoNext();

    /// Whether the client can call the [previous] method and expect the current track to change
    Future<bool> canGoPrevious() => _mediaPlayer.getCanGoPrevious();

    /// Whether playback can be started using [play] or [toggle]
    Future<bool> canPlay() => _mediaPlayer.getCanPlay();

    /// Whether playback can be paused using [pause] or [toggle]
    Future<bool> canPause() => _mediaPlayer.getCanPause();

    /// Whether the client can control the playback position using [seek] or [setPosition]
    Future<bool> canSeek() => _mediaPlayer.getCanSeek();

    /// Whether the media player may be controlled
    Future<bool> canControl() => _mediaPlayer.getCanControl();

    /// Skips to the next track in the tracklist
    Future next() => _mediaPlayer.callNext();

    /// Skips to the previous track in the tracklist
    Future previous() => _mediaPlayer.callPrevious();

    /// Pauses playback
    Future pause() => _mediaPlayer.callPause();

    /// Toggles the playback
    Future toggle() => _mediaPlayer.callPlayPause();

    /// Stops playback
    Future stop() => _mediaPlayer.callStop();

    /// Starts or resumes playback
    Future play() => _mediaPlayer.callPlay();

    /// Seeks forward in the current track by the specified offset
    Future seek(Duration offset) => _mediaPlayer.callSeek(offset.inMicroseconds);

    /// Sets the current track position
    Future setPosition(String track, Duration position) => _mediaPlayer.callSetPosition(DBusObjectPath(track), position.inMicroseconds);

    /// Uri of the track to load (This is used to tell the media player which track to play)
    Future openUri(String uri) => _mediaPlayer.callOpenUri(uri);

/*
  This doesn't work
  Stream<MediaPlayer2PlayerSeeked> subscribeSeeked() =>
      _mediaPlayer.subscribeSeeked();
   */
}

/// The current loop / repeat status
enum LoopStatus {
    /// If the playback will stop when there are no more tracks to play
    none,

    /// If the current track will start again from the beginning once it has finished playing
    track,

    /// If the playback loops through a list of tracks
    playlist,
}

enum PlaybackStatus {
    /// If the track is playing
    playing,

    // If the track is paused
    paused,

    /// If the track was stopped
    stopped,
}

// ignore: public_member_api_docs
class Metadata {
    // ignore: public_member_api_docs
    Metadata(
        this.trackId,
        this.trackTitle,
        this.trackArtists,
        this.trackNumber,
        this.trackUrl,
        this.trackLength,
        this.trackArtUrl,
        this.albumName,
        this.albumArtists,
        this.discNumber,
    );

    // ignore: public_member_api_docs
    factory Metadata.fromMap(Map<String, DBusValue> map) {
        final artists = ((map['xesam:artist'] as DBusArray).children).map((e) => (e as DBusString).value).toList();

        final trackNumberValue = map['xesam:trackNumber'];
        final trackNumber = trackNumberValue is DBusInt32
            ? trackNumberValue.value
            : trackNumberValue is DBusUint32
                ? trackNumberValue.value
                : 0; 

        final discNumberValue = map['xesam:discNumber'];
        final discNumber = discNumberValue is DBusInt32
            ? discNumberValue.value
            : discNumberValue is DBusUint32
                ? discNumberValue.value
                : 0;

        final albumArtist = (map['xesam:albumArtist'] is DBusArray)
            ? ((map['xesam:albumArtist'] as DBusArray).children).map((e) => (e as DBusString).value).toList()
            : ["?none?"];
        final data = Metadata(
            (map['mpris:trackid'] as DBusString).value,
            (map['xesam:title'] as DBusString).value,
            artists,
            trackNumber,
            (map['xesam:url'] as DBusString).value,
            Duration(
                microseconds: map['mpris:length'] is DBusUint64
                    ? (map['mpris:length'] as DBusUint64).value
                    : (map['mpris:length'] as DBusInt64).value,
            ),
            (map['mpris:artUrl'] as DBusString).value,
            (map['xesam:album'] as DBusString).value,
            albumArtist,
            discNumber,
        );

        return data;
    }

    // ignore: public_member_api_docs
    final String trackId;

    // ignore: public_member_api_docs
    final String trackTitle;

    // ignore: public_member_api_docs
    final List<String> trackArtists;

    // ignore: public_member_api_docs
    final int trackNumber;

    // ignore: public_member_api_docs
    final String trackUrl;

    // ignore: public_member_api_docs
    final Duration trackLength;

    // ignore: public_member_api_docs
    final String trackArtUrl;

    // ignore: public_member_api_docs
    final String albumName;

    // ignore: public_member_api_docs
    final List<String> albumArtists;

    // ignore: public_member_api_docs
    final int discNumber;
}
