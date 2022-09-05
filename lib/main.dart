import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaval/player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ViewModel()),
      ],
      child: const Main(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  ViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ViewModel>(context);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [],
          ),
        ),
        bottomNavigationBar: const Player(),
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {}
