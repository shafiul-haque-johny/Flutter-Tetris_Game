//grid dimensions
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int rowLength = 10, colLength = 11;

enum Direction { left, right, down }

enum Tetromino { L, J, I, O, S, Z, T }

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Color(0xFF068D8D),
  Tetromino.J: Color(0xFF228B22),
  Tetromino.I: Color.fromARGB(255, 0, 102, 255),
  Tetromino.O: Color(0xFF800020),
  Tetromino.S: Color(0xFFC24C0C),
  Tetromino.Z: Color(0xFFAAFF00),
  Tetromino.T: Color(0xFF6D08D2),
};
