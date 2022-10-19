import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shaval/singleton.dart';
import 'package:shaval/task_handler.dart';

class ForegroundH extends StatelessWidget {
  const ForegroundH({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePage(),
      },
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  ReceivePort? _receivePort;
  Helper helper = Helper();
  double current = 0;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        buttons: [
          const NotificationButton(id: 'prev', text: 'PreviousVideo'),
          const NotificationButton(id: 'pause', text: 'Pause'),
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
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      helper.headlessWebView?.dispose();
      initWebView();
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
    helper.headlessWebView?.run();

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    helper.headlessWebView?.dispose();
    initWebView();
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
            case 'onNotificationPressed':
              Navigator.of(context).pushNamed('/');
              break;
            case 'play':
              helper.playVideo();
              break;
            case 'pause':
              helper.pauseVideo();
              break;
            case 'prev':
              // helper.pauseVideo();
              break;
            case 'next':
              // helper.pauseVideo();
              break;
          }
        } else if (message == null) {
          double a = (await helper.getCurrentTime()).toDouble();
          FlutterForegroundTask.saveData(key: 'time', value: a);
          setState(() => current = a);
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
    initWebView();
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

  void initWebView() {
    helper.headlessWebView = HeadlessInAppWebView(
      initialSize: const Size(100, 100),
      initialFile: 'assets/player.html',
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false,
        ),
      ),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'Ready',
          callback: (args) {
            helper.playVideo();
          },
        );
      },
      onCloseWindow: (controller) {
        log('웹뷰 꺼짐');
      },
      onConsoleMessage: (controller, consoleMessage) {
        log('Console Message: ${consoleMessage.message}');
      },
    );
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
      onForeground: () {
        helper.playVideo();
      },
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
          Text('${current.toStringAsFixed(2)}s'),
        ],
      ),
    );
  }
}
