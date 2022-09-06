import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shaval/main.dart';

class FuckinWebView extends StatelessWidget {
  const FuckinWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Datum datum = Datum(YoutubeViewModel().ids.first.id);
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: datum.html),
      // initialOptions: ,
      initialUserScripts: UnmodifiableListView([]),
    );
  }
}

class Datum {
  late String html;

  Datum(String id) {
    html =
        """<html><iframe id="player" src="https://www.youtube.com/embed/$id" frameborder=0></iframe></html>""";
  }
}
