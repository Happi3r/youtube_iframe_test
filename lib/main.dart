import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:shaval/foreground.dart';
import 'package:shaval/audio2/audio_service2.dart';
import 'package:shaval/audio_service.dart';
import 'package:shaval/background.dart';
import 'package:shaval/foreground.dart';
import 'package:shaval/headless.dart';
import 'package:shaval/inapp.dart';
import 'package:shaval/singleton.dart';
import 'package:shaval/youtube.dart';

// late AudioHandler audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // log('twice???');
  runApp(const Foreground());
}

// await initializeService();
// _audioHandler = await AudioService.init(
//   builder: () => AudioPlayerHandler(),
//   config: const AudioServiceConfig(
//     androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
//     androidNotificationChannelName: 'Audio playback',
//     androidNotificationOngoing: true,
//   ),
// );
// zzz();
// audioHandler = await AudioService.init(
//   builder: () => AudioPlayerHandler(),
//   config: const AudioServiceConfig(
//     androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
//     androidNotificationChannelName: 'Audio playback',
//     androidNotificationOngoing: true,
//   ),
// );
// runApp(const Foreground());

// class Azdio extends StatelessWidget {
//   const Azdio({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio Service Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: MainScreen(audioHandler: audioHandler),
//     );
//   }
// }

// class Main extends StatelessWidget {
//   const Main({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const Headless(),
//     );
//   }
// }
