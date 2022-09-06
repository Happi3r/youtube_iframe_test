import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:shaval/player.dart';
import 'package:shaval/webview.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => YoutubeViewModel()),
        ChangeNotifierProvider(create: (_) => Playlist()),
      ],
      child: const Youtube(),
    ),
  );
}

class Youtube extends StatelessWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    YoutubeViewModel viewModel = Provider.of<YoutubeViewModel>(context);
    return MaterialApp(
      home: Consumer<Playlist>(
        builder: (context, playlist, _) => YoutubePlayerScaffold(
          controller: viewModel.controller,
          builder: (context, player) {
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(playlist.now?.title ?? '없음'),
                        Text(viewModel.controller.metadata.title),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: playlist.ani ? 100 : 0,
                            height: playlist.ani ? 100 : 0,
                            child: const FuckinWebView(),
                          ),
                        ),
                        Wrap(
                          children: viewModel.ids
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
                                onPressed: playlist.update,
                                icon: const Icon(Icons.update),
                              ),
                              IconButton(
                                onPressed: playlist.prev,
                                icon: const Icon(Icons.skip_previous),
                              ),
                              IconButton(
                                onPressed:
                                    value.playerState == PlayerState.playing
                                        ? viewModel.controller.pauseVideo
                                        : viewModel.controller.playVideo,
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
                                  viewModel.controller.stopVideo();
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
    );
  }
}

class YoutubeViewModel extends ChangeNotifier {
  late YoutubePlayerController controller;
  late Playlist playlist;

  YoutubeViewModel() {
    controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
      ),
    );
    playlist = Playlist();
    playlist.addListener(wtf);
  }

  @override
  void dispose() {
    playlist.removeListener(wtf);
    controller.close();
    super.dispose();
  }

  void wtf() {
    print(controller.metadata.videoId); //i1
    if (playlist.now?.id != controller.metadata.videoId) {
      //i0
      playlist.now == null
          ? controller.stopVideo() //n1
          : controller.loadVideoById(videoId: playlist.now!.id); //n0
    }
  }

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
      id: '1UbyyaDc8x0',
      artist: '릴파',
      image: '',
      title: '세사빠',
    ),
    Song(
      id: 'fgSXAKsq-Vo',
      artist: '이세계 아이돌',
      image: '',
      title: '리와인드',
    ),
  ];
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

  bool ani = false;
  void update() {
    ani = !ani;
    notifyListeners();
  }

  void add(Song s) {
    list.add(s);
    notifyListeners();
  }

  void prev() {
    _index = _index == 0 ? list.length - 1 : _index - 1;
    notifyListeners();
  }

  void next() {
    _index = _index == list.length - 1 ? 0 : _index + 1;
    notifyListeners();
  }

  void clear() {
    _index = 0;
    list.clear();
    notifyListeners();
  }
}
