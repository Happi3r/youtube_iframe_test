import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaval/player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  final _controller = YoutubePlayerController();
  final List<Song> ids = const [
    Song(
      id: 'DPEtmqvaKqY',
      artist: '고세구',
      image: '',
      title: '팬서비스',
    ),
    Song(
      id: 'JY-gJkMuJ94',
      artist: '이세계 아이돌',
      image: '',
      title: '겨울봄',
    ),
    Song(
      id: '6hEvgKL0ClA',
      artist: '릴파',
      image: '',
      title: 'Promise',
    ),
    Song(
      id: '08meo6qrhFc',
      artist: '우왁굳',
      image: '',
      title: '왁맥송',
    ),
    Song(
      id: 'rFxJjpSeXHI',
      artist: '주르르',
      image: '',
      title: 'SCIENTIST',
    ),
    Song(
      id: 'K-5WdjbCYnk',
      artist: '릴파, 뢴트게늄',
      image: '',
      title: '마지막 재회',
    ),
    Song(
      id: 'Empfi8q0aas',
      artist: '이세계 아이돌',
      image: '',
      title: '이세돌 싸이퍼',
    ),
    Song(
      id: 'Brf3LWwNVTk',
      artist: '이세계 아이돌',
      image: '',
      title: 'LOVE DIVE',
    ),
    Song(
      id: 'fgSXAKsq-Vo',
      artist: '이세계 아이돌',
      image: '',
      title: '리와인드',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.playVideo();
  }

  void wtf() {
    print(_controller.metadata.videoId); //i1
    if (Playlist().now?.id != _controller.metadata.videoId) {
      //i0
      Playlist().now == null
          ? _controller.stopVideo() //n1
          : _controller.loadVideoById(videoId: Playlist().now!.id); //n0
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Playlist()..addListener(wtf),
      child: MaterialApp(
        home: Consumer<Playlist>(
          builder: (context, playlist, _) => YoutubePlayerScaffold(
            controller: _controller,
            builder: (context, player) {
              return Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(playlist.now?.title ?? '없음'),
                          Text(_controller.metadata.title),
                          SizedBox(
                            width: 320,
                            height: 180,
                            child: player,
                          ),
                          Wrap(
                            children: ids
                                .map(
                                  (e) => TextButton(
                                    onPressed: () => playlist.add(e),
                                    child: Text(e.title),
                                  ),
                                )
                                .toList(),
                          ),
                          YoutubeValueBuilder(
                            builder: (context, value) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.skip_previous),
                                ),
                                IconButton(
                                  onPressed: playlist.prev,
                                  icon: const Icon(Icons.skip_previous),
                                ),
                                IconButton(
                                  onPressed:
                                      value.playerState == PlayerState.playing
                                          ? _controller.pauseVideo
                                          : _controller.playVideo,
                                  icon: Icon(
                                      value.playerState == PlayerState.playing
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                ),
                                IconButton(
                                  onPressed: playlist.next,
                                  icon: const Icon(Icons.skip_next),
                                ),
                                IconButton(
                                  onPressed: () {
                                    print(value.playerState);
                                    _controller.stopVideo();
                                    playlist.clear();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          const DurationProgressIndicator(
                            type: ProgressType.slider,
                          ),
                        ],
                      ),
                      const Player(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (num i = 0; i < 100; i++) {
      print('ASDFASDFADFSDFSDF0909090090');
      print('zzzzzz');
    }
    _controller.close();
    Playlist().removeListener(wtf);
    super.dispose();
  }
}

class Song {
  final String id;
  final String title;
  final String artist;
  final String image;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.image,
  });
}

class Playlist extends ChangeNotifier {
  static Playlist? _instance;
  Playlist._();
  factory Playlist() => _instance ??= Playlist._();

  List<Song> list = List.empty(growable: true);

  Song? get now => list.isEmpty ? null : list[_index];

  int _index = 0;
  int get index => _index;

  void add(Song s) {
    list.add(s);
    notifyListeners();
  }

  void prev() {
    _index = _index == 0 ? list.length - 1 : _index - 1;
    notifyListeners();
  }

  void next() {
    if (list.length != 1) {
      _index = _index == list.length - 1 ? 0 : _index + 1;
      notifyListeners();
    }
  }

  void clear() {
    _index = 0;
    list.clear();
    notifyListeners();
  }
}
