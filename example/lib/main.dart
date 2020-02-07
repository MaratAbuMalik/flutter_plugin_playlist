import 'package:flutter/material.dart';
import 'package:flutter_plugin_playlist/flutter_plugin_playlist.dart';

import 'audios.dart';

void main() => runApp(MaterialApp(
      title: 'Audio Sample App',
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Example'),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
                child: const Text("Качества успешного призывающего"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist1)),
                  );
                }),
            RaisedButton(
                child: const Text("Сабр — Вещи, помогающие проявлять терпение"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist2)),
                  );
                }),
            RaisedButton(
                child: const Text("Совершенство шариата"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist3)),
                  );
                }),
            RaisedButton(
                child: const Text("Понимание мольбы"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist4)),
                  );
                }),
            RaisedButton(
                child: const Text("Пользы зикра и его плоды"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist5)),
                  );
                }),
            RaisedButton(
                child: const Text(
                    "Некоторые пользы, извлекаемые из суры «аль-Фатиха»"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Playlist(playlist6)),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void initState() {
    super.initState();
  }
}

class Playlist extends StatefulWidget {
  List playlist;
  Playlist(this.playlist);

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  RmxAudioPlayer rmxAudioPlayer;
  String _status = 'none';
  double _seeking;
  double _position = 0;

  int _current = 0;
  int _total = 0;

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
  void dispose() {
    rmxAudioPlayer.clearAllItems();

//    rmxAudioPlayer.off('status', (eventName, {dynamic args}) {dispose();});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    rmxAudioPlayer = RmxAudioPlayer();
    rmxAudioPlayer.initialize();
    _prepare(widget.playlist);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Player Example'),
        ),
        body: Padding(
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
            ],
          ),
        ));
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

  _prepare(playlist) async {
    await rmxAudioPlayer.setPlaylistItems(playlist,
        options: new PlaylistItemOptions(startPaused: true));

//    await rmxAudioPlayer.setLoop(true);

//    await _play();
  }
}
