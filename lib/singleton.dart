import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Helper {
  static final Helper instance = Helper._();
  factory Helper() {
    return instance;
  }
  Helper._() {
    log('this is singleton');
  }

  HeadlessInAppWebView? headlessWebView;
  // HeadlessInAppWebView? get headlessWebView => _headlessWebView;
  // set headlessWebView(v) => _headlessWebView = v;
  int index = 0;
  // int get index => _index;
  // set index(i) => _index = index;

  void playVideo() {
    log('helper plays ${headlessWebView == null ? 'null' : 'webview'}');
    headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.playVideo();',
    );
  }

  void pauseVideo() {
    log('helper pauses ${headlessWebView == null ? 'null' : 'webview'}');
    headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.pauseVideo();',
    );
  }
}
