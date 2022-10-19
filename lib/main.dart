import 'package:flutter/material.dart';
import 'package:shaval/foreground_headless.dart';
import 'package:shaval/foreground_inapp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Foreground());
}
