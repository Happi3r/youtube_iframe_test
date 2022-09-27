import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Playlist()),
      ],
      child: const MaterialApp(
        home: Youtube(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class Youtube extends StatefulWidget {
  const Youtube({Key? key}) : super(key: key);

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
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
  Widget build(BuildContext context) {
    return Consumer<Playlist>(
      builder: (context, playlist, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                YoutubePlayer(controller: playlist.controller),
                Wrap(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.queue_music),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        playlist.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.queue_music),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: const Player(),
        );
      },
    );
  }
}

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool asdf = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<Playlist>(
      builder: (context, playlist, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.center,
              height: asdf ? MediaQuery.of(context).size.height - 56 : 500,
              child: Column(
                children: [
                  YoutubePlayer(controller: playlist.controller),
                  Wrap(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => asdf = !asdf),
                        icon: const Icon(Icons.queue_music),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          playlist.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.skip_next),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.queue_music),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
              height: asdf ? 0 : 56,
              width: double.infinity,
              color: Colors.black,
            ),
          ],
        );
      },
    );
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

  YoutubePlayerController controller =
      YoutubePlayerController(initialVideoId: '');

  void add(Song s) {
    list.add(s);
    notifyListeners();
  }

  void prev() {
    _index = _index == 0 ? list.length - 1 : _index - 1;
    notifyListeners();
  }

  void next() {
    if (list.length < 2) {
      _index = _index == list.length - 1 ? 0 : _index + 1;
      controller.load(now!.id);
      notifyListeners();
    }
  }

  void clear() {
    _index = 0;
    list.clear();
    notifyListeners();
  }
}
