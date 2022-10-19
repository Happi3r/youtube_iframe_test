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

  Future<double> getCurrentTime() async {
    double? res = await headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.getCurrentTime();',
    );
    return res ?? 0;
  }

  void setPlaybackQuality(String s) {
    headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.setPlaybackQuality("$s");',
    );
  }

  Future<List<dynamic>> getAvailableQualityLevels() async {
    List<dynamic>? res =
        (await headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.getAvailableQualityLevels();',
    ));
    return res ?? ['Failed'];
  }

  Future<String> getPlaybackQuality() async {
    String? res = (await headlessWebView?.webViewController.evaluateJavascript(
      source: 'player.getPlaybackQuality();',
    )) as String?;
    return res ?? 'Failed';
  }
}
