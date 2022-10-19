import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shaval/singleton.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandlerH());
}

class MyTaskHandlerH extends TaskHandler {
  SendPort? _sendPort;
  // int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final data = await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $data');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    double time = await FlutterForegroundTask.getData(key: 'time');
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'currentTime: ${time.toStringAsFixed(2)}',
    );

    // Send data to the main isolate.
    // sendPort?.send(_eventCount++);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
    if (id == 'play') {
      _sendPort?.send('playVideo');
    } else if (id == 'pause') {
      _sendPort?.send('pauseVideo');
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
    _sendPort?.send('onNotificationPressed');
    log('Noti Pressed');
  }
}

class ForegroundH extends StatelessWidget {
  const ForegroundH({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePageH(),
      },
    );
  }
}

class ExamplePageH extends StatefulWidget {
  const ExamplePageH({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePageH> {
  ReceivePort? _receivePort;
  Helper helper = Helper();

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
          const NotificationButton(id: 'pause', text: 'Pause'),
          const NotificationButton(id: 'play', text: 'Play'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
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
      _receivePort?.listen((message) {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          log(message);
          switch (message) {
            case 'onNotificationPressed':
              Navigator.of(context).pushNamed('/');
              break;
            case 'playVideo':
              helper.playVideo();
              break;
            case 'pauseVideo':
              helper.pauseVideo();
              break;
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
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
          buttonBuilder('시간 업데이트', onPressed: () async {
            double a = await helper.getCurrentTime();
            FlutterForegroundTask.saveData(key: 'time', value: a);
          }),
        ],
      ),
    );
  }
}
