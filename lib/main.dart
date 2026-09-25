import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/chocolate_game.dart';
import 'ui/game_hud.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );
  final game = ChocolateGame();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      body: GameWidget<ChocolateGame>(
        game: game,
        overlayBuilderMap: {
          'hud': (_, g) => GameHud(game: g),
        },
        initialActiveOverlays: const ['hud'],
      ),
    ),
  ));
}
