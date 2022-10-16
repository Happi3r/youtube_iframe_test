import 'package:flutter/material.dart';
import 'package:shaval/background.dart';
import 'package:shaval/headless.dart';
import 'package:shaval/inapp.dart';
import 'package:shaval/youtube.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initializeService();

  runApp(const Background());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Headless(),
    );
  }
}
