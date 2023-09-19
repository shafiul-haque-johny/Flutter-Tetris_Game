import 'package:flutter/material.dart';
import 'package:tetris_game/board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "TETRIS GAME",
      debugShowCheckedModeBanner: false,
      home: GameBoard(),
    );
  }
}
