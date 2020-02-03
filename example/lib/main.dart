import 'package:flutter/material.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

RmxAudioPlayer rmxAudioPlayer = new RmxAudioPlayer();

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _seeking;
  double _position = 0;

  int _current = 0;
  int _total = 0;

  String _status = 'none';

  @override
  void initState() {
    super.initState();

    rmxAudioPlayer.initialize();

    rmxAudioPlayer.on('status', (eventName, {dynamic args}) {
      print(eventName + (args ?? "").toString());

      if ((args as OnStatusCallbackData).value != null) {
        setState(() {
          if ((args as OnStatusCallbackData).value['currentPosition'] != null) {
            _current =
                (args as OnStatusCallbackData).value['currentPosition'].toInt();
            _total = (((args as OnStatusCallbackData).value['duration']) ?? 0)
                .toInt();
            _status = (args as OnStatusCallbackData).value['status'];

            if (_current > 0 && _total > 0) {
              _position = _current / _total;
            } else if (!rmxAudioPlayer.isLoading && !rmxAudioPlayer.isSeeking) {
              _position = 0;
            }

            if (_seeking != null &&
                !rmxAudioPlayer.isSeeking &&
                !rmxAudioPlayer.isLoading) {
              _seeking = null;
            }
          }
        });
      }
    });
  }

  _prepare() async {
    await rmxAudioPlayer.setPlaylistItems([
      new AudioTrack(
          trackId: 'friend_bon_jovi',
          album: "Friends",
          artist: "Bon Jovi",
          assetUrl:
          "https://toislam.podster.fm/77/download/audio.mp3",
          title: "I'll be there for you"),
      new AudioTrack(
          album: "Friends",
          artist: "Ross",
          assetUrl:
          "http://files.alhadis.ru/audio/abu_yahya/aqida/kitabut_tauheed/kitabut_tauheed_084.mp3",
          title: "The Sound"),
      new AudioTrack(
          trackId: 'qq',
          album: "Friends",
          artist: "Friends",
          assetUrl: "asset://assets/kitabut_tauheed_141.mp3",
          title: "F.R.I.E.N.D.S"),
    ],options:
    new PlaylistItemOptions(
      startPaused: true));

//    await rmxAudioPlayer.setLoop(true);

    await _play();
  }

  _playFromId() async {
    await rmxAudioPlayer.playTrackById("friend_bon_jovi");
  }

  _addMore() async {
    await rmxAudioPlayer.addItem(
      new AudioTrack(
          album: "Friends",
          artist: "Friends",
          assetUrl:
              "asset://assets/kitabut_tauheed_141.mp3",
          title: "F.R.I.E.N.D.S"),
      index: 1,
    );
  }

  _play() async {
    setState(() {});

    await rmxAudioPlayer.play();
  }

  _pause() {
    rmxAudioPlayer.pause().then((_) {
      print(_);
      setState(() {});
    }).catchError(print);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Player Example'),
        ),
        body: Center(
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    if (_status == 'none' || _status == 'stopped') {
      return _actionPrepare();
    }

    return _player();
  }

  Widget _actionPrepare() {
    return RaisedButton(
      child: const Text("Prepare Playlist"),
      onPressed: _prepare,
    );
  }

  Widget _player() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(_format(_current)),
              new Text(_format(_total))
            ],
          ),
          Slider(
            value: _seeking ?? _position,
            onChangeEnd: (val) async {
              if (_total > 0) {
                await rmxAudioPlayer.seekTo(val * _total);
              }
            },
            onChanged: (val) {
              if (_total > 0) {
                setState(() {
                  _seeking = val;
                });
              }
            },
          ),
          Material(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: rmxAudioPlayer.skipBack,
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: _onPressed(),
                  icon: _icon(),
                ),
                IconButton(
                  onPressed: rmxAudioPlayer.skipForward,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: _playFromId,
                  child: Text("Play Opening"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _format(int secs) {
    int sec = secs;

    int min = 0;
    if (secs > 60) {
      min = (sec / 60).floor();
      sec = sec % 60;
    }

    return (min >= 10 ? min.toString() : '0' + min.toString()) +
        ":" +
        (sec >= 10 ? sec.toString() : '0' + sec.toString());
  }

  _onPressed() {
    if (rmxAudioPlayer.isLoading || rmxAudioPlayer.isSeeking) return null;

    if (rmxAudioPlayer.isPlaying) return _pause;

    return _play;
  }

  Widget _icon() {
    if (rmxAudioPlayer.isLoading || rmxAudioPlayer.isSeeking) {
      return const CircularProgressIndicator();
    }

    if (rmxAudioPlayer.isPlaying) {
      return const Icon(Icons.pause_circle_outline);
    }

    return const Icon(Icons.play_circle_outline);
  }
}
