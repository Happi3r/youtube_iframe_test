import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:shaval/youtube.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final ytCtrl = context.ytController;
    Playlist playlist = Provider.of<Playlist>(context);
    return Miniplayer(
      minHeight: 62,
      maxHeight: 240,
      builder: (height, percent) => playlist.now != null
          ? Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.white,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.queue_music,
                        size: 28,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(playlist.now!.title,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w700,
                                )),
                            Text(playlist.now!.artist,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: playlist.prev,
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 30,
                        ),
                      ),
                      YoutubeValueBuilder(
                        builder: (context, value) => IconButton(
                          onPressed: value.playerState == PlayerState.playing
                              ? ytCtrl.pauseVideo
                              : ytCtrl.playVideo,
                          icon: Icon(
                            value.playerState == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 30,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: playlist.next,
                        icon: const Icon(
                          Icons.skip_next,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const DurationProgressIndicator(
                  type: ProgressType.mini,
                ),
              ],
            )
          : Container(),
    );
  }
}

enum ProgressType { mini, slider }

class DurationProgressIndicator extends StatefulWidget {
  const DurationProgressIndicator({Key? key, required this.type})
      : super(key: key);
  final ProgressType type;

  @override
  State<DurationProgressIndicator> createState() =>
      _DurationProgressIndicatorState();
}

class _DurationProgressIndicatorState extends State<DurationProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final ytCtrl = context.ytController;
    bool isUpdating = false;
    double value = 0;
    return Consumer<Playlist>(
      builder: (context, playlist, _) => StreamBuilder<Duration>(
        stream: ytCtrl.getCurrentPositionStream(),
        initialData: Duration.zero,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('sibalalaaal ${snapshot.error}');
          }
          num position = snapshot.data?.inMilliseconds ?? 0;
          final duration = ytCtrl.metadata.duration.inMilliseconds;
          switch (widget.type) {
            case ProgressType.mini:
              if (position != 0 &&
                  position == duration &&
                  playlist.list.length != 1) {
                playlist.next();
              }
              return LinearProgressIndicator(
                value: duration == 0 ? 0 : position / duration,
                minHeight: 2,
                backgroundColor: Colors.transparent,
              );
            case ProgressType.slider:
              if (position != 0 &&
                  position == duration &&
                  playlist.list.length != 1) {
                playlist.next();
              }
              value = position.toDouble();
              print('$value ||| $position ||| $duration ||| $isUpdating');
              return Slider(
                max: duration.toDouble(),
                value: duration == 0 ? 0 : value,
                onChanged: (v) => setState(() {
                  print('$v <<<<<');
                  value = v;
                }),
                onChangeEnd: (v) => setState(() {
                  ytCtrl.seekTo(
                    seconds: v / 1000,
                    allowSeekAhead: true,
                  );
                }),
              );
          }
        },
      ),
    );
  }
}
