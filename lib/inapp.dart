import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InApp extends StatefulWidget {
  const InApp({super.key});

  @override
  State<InApp> createState() => _InAppState();
}

class _InAppState extends State<InApp> {
  late final InAppWebViewController con;
  final List<String> list = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('zzzxcv')),
      body: Column(
        children: [
          SizedBox(
            width: 320,
            height: 180,
            child: InAppWebView(
              initialFile: 'assets/player.html',
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),
              onWebViewCreated: (controller) {
                con = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'Ready',
                  callback: (args) {
                    log(args.toString());
                  },
                );
                controller.addJavaScriptHandler(
                  handlerName: 'PlayerError',
                  callback: (args) {
                    log(args.toString());
                  },
                );
              },
              onConsoleMessage: (controller, consoleMessage) {
                setState(() {
                  list.add(consoleMessage.message);
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              log('누름');
              con.evaluateJavascript(source: "player.playVideo();");
            },
            child: const Text('테스트'),
          ),
          Expanded(
            child: ListView(
              children: list.map((e) => Text(e)).toList(),
            ),
          )
        ],
      ),
    );
  }
}
