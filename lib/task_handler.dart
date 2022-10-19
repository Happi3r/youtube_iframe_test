import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
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
    double time = (await FlutterForegroundTask.getData(key: 'time')) ?? 0;
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: '${time.toStringAsFixed(2)}s',
    );

    // Send data to the main isolate.
    sendPort?.send(null);
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
    _sendPort?.send(id);
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
    _sendPort?.send('onNotificationPressed');
    log('Noti Pressed');
  }
}
