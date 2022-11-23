import 'dart:developer';
import 'dart:isolate';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shaval/task_handler.dart';

class Foreground extends StatelessWidget {
  const Foreground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const _ExamplePage(),
      },
    );
  }
}

class _ExamplePage extends StatefulWidget {
  const _ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  ReceivePort? _receivePort;
  InAppWebViewController? controller;
  bool serviceRunning = false;
  bool playing = false;
  double current = 0;
  double duration = 0;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        buttons: [
          // 앱 삭제 후 다시 깔아야 id 바뀜
          const NotificationButton(id: 'prev', text: 'PreviousVideo'),
          const NotificationButton(id: 'play', text: 'Play'),
          const NotificationButton(id: 'next', text: 'NextVideo'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 200,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        return false;
      }
    }

    // await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Waktaverse Music',
        notificationText: 'init',
        callback: startCallback,
      );
    }
    setState(() => serviceRunning = true);

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    setState(() => serviceRunning = false);
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) async {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          log(message);
          switch (message) {
            case 'play':
              controller?.evaluateJavascript(
                source: 'player.${playing ? 'pause' : 'play'}Video();',
              );
              break;
          }
        } else if (message == null) {
          num a = await controller?.evaluateJavascript(
                source: 'player.getCurrentTime();',
              ) ??
              0;
          num d = await controller?.evaluateJavascript(
                source: 'player.getDuration();',
              ) ??
              0;
          FlutterForegroundTask.saveData(key: 'playing', value: playing);
          FlutterForegroundTask.saveData(key: 'time', value: a.toDouble());
          FlutterForegroundTask.saveData(key: 'duration', value: d.toDouble());
          setState(() {
            current = a.toDouble();
            duration = d.toDouble();
          });
        }
      });
      return true;
    }
    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      if (await FlutterForegroundTask.isRunningService) {
        log('Restart');
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
      log('Start');
      // _startForegroundTask();
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buttonBuilder('start', onPressed: () {
            _startForegroundTask();
          }),
          buttonBuilder('stop', onPressed: () {
            _stopForegroundTask();
          }),
          if (serviceRunning)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: InAppWebView(
                initialFile: 'assets/player.html',
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onWebViewCreated: (c) {
                  controller = c;
                  c.addJavaScriptHandler(
                    handlerName: 'Ready',
                    callback: (args) {
                      controller?.evaluateJavascript(
                        source: 'player.playVideo()',
                      );
                    },
                  );
                  c.addJavaScriptHandler(
                    handlerName: 'StateChange',
                    callback: (args) {
                      setState(() => playing = args[0] == 1);
                    },
                  );
                },
                onCloseWindow: (c) {
                  log('웹뷰 닫힘');
                },
                onConsoleMessage: (c, consoleMessage) {
                  log('Console Message: ${consoleMessage.message}');
                },
              ),
            )
          else
            const SizedBox(),
          Text('${current.toStringAsFixed(2)}s'),
        ],
      ),
    );
  }
}
