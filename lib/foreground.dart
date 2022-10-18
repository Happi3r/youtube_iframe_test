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
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    double time = await FlutterForegroundTask.getData(key: 'time');
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'currentTime: ${time.toStringAsFixed(2)}',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
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
    if (id == 'testButton') {
      _sendPort?.send('playVideo');
    } else if (id == 'sendButton') {
      _sendPort?.send('pauseVideo');
    }
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
    log('notipress');
  }
}

class Foreground extends StatelessWidget {
  const Foreground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePage(),
        '/resume-route': (context) => const ResumeRoutePage(),
      },
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePage> {
  ReceivePort? _receivePort;
  // Helper helper = Helper();

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
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
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
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');
    log('tlqkf');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      // helper.headlessWebView?.dispose();
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
    // helper.headlessWebView?.run();
    // log('${++h.index} ${hh.index}');

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    // helper.headlessWebView?.dispose();
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
              Navigator.of(context).pushNamed('/resume-route');
              break;
            case 'playVideo':
              // helper.playVideo();
              controller?.evaluateJavascript(source: 'player.playVideo();');
              break;
            case 'pauseVideo':
              // helper.pauseVideo();
              controller?.evaluateJavascript(source: 'player.pauseVideo();');
              setState(() => temp = "PAUSED");
              break;
            case 'onForeground':
              // helper.playVideo();
              controller?.evaluateJavascript(source: 'player.playVideo();');
              break;
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });
      log('whyreg');
      return true;
    }
    log('ynotreg');
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
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        log('hahahaa');
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
      log('wahaa');
      _startForegroundTask();
    });
    initWebView();
    log('twice?');
  }

  void initWebView() {
    // helper.headlessWebView = HeadlessInAppWebView(
    //   initialFile: 'assets/player.html',
    //   initialOptions: InAppWebViewGroupOptions(
    //     crossPlatform: InAppWebViewOptions(
    //       mediaPlaybackRequiresUserGesture: false,
    //     ),
    //   ),
    //   onWebViewCreated: (controller) {
    //     controller.addJavaScriptHandler(
    //       handlerName: 'Ready',
    //       callback: (args) {
    //         helper.playVideo();
    //       },
    //     );
    //   },
    //   onCloseWindow: (controller) {
    //     log('closed webview');
    //   },
    //   onConsoleMessage: (controller, consoleMessage) {
    //     log('Console Message: ${consoleMessage.message}');
    //   },
    // );
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  String temp = "TEST";
  InAppWebViewController? controller;

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
          buttonBuilder('index', onPressed: () async {
            double a = await controller?.evaluateJavascript(
                source: 'player.getCurrentTime();');
            FlutterForegroundTask.saveData(key: 'time', value: a);
          }),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: InAppWebView(
              initialFile: 'assets/player.html',
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),
              onWebViewCreated: (c) {
                controller = c;
                controller?.addJavaScriptHandler(
                  handlerName: 'Ready',
                  callback: (args) {
                    // helper.playVideo();
                    controller?.evaluateJavascript(
                      source: 'player.playVideo()',
                    );
                  },
                );
              },
              onCloseWindow: (c) {
                log('closed webview');
              },
              onConsoleMessage: (c, consoleMessage) {
                log('Console Message: ${consoleMessage.message}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
