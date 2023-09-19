import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';

/*
GAME BOARD
This is a 2x2 grid with null representing an empty space.
A non empty space will have the color to represent the landed pieces
 */

//create game board
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.J);

  //current score
  int currentScore = 0;

  //game over status
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    //start game when app starts
    startGame();
  }

  void startGame() {
    currentPiece.initilizePiece();
    //frame refresh rate
    Duration frameRate = const Duration(milliseconds: 1000);
    gameLoop(frameRate);
  }

  //game loop
  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //clear lines
        clearLines();

        //check landing
        checkLanding();

        // check if game is over
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        //move current piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  // game over message
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child:
              // Stroked text as border.
              Text(
            "Game Over!",
            style: TextStyle(
              fontSize: 25,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = Colors.red[700]!,
            ),
          ),
        ),
        content: Text(
          "Your Score is: $currentScore",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () {
                // reset the game
                resetGame();
                Navigator.pop(context);
              },
              style:
                  TextButton.styleFrom(backgroundColor: Colors.blueGrey[300]),
              child: Text(
                "Play Again",
                style: TextStyle(
                    color: Colors.blue[900], fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  // reset game
  void resetGame() {
    //clear the game board
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );

    // new game
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();

    // start the game
    startGame();
  }

  //check for collision in a future position
  //return true -> there is collision
  //return false -> there is no collision
  bool checkCollision(Direction direction) {
    //loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate the row & column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      //adjust the row & col based the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      //check if the piece is out of bounds (either too low or too far to the left or right.
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      // check if the below cell is already occupied
      else if (col > 0 && row > 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if no collision is detected, return false
    return false;
  }

  //check landing
  void checkLanding() {
    //if going down is occupied or landed on the other pieces
    if (checkCollision(Direction.down)) {
      //make position as occupied on the game board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //once landed, create the next piece
      createNewPiece();
    }
  }

  //create new piece
  void createNewPiece() {
    //create a random object to generate random tetromino types
    Random rand = Random();

    //create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initilizePiece();

    /*
    Since our game over condition is if there is a piece at the top level,
    you wanna check if the game is over when you create a new piece
    instead of checking every frame, because new pieces are allowed to go
    through the top level but if there is already a piece in the top level
    when the new piece is created, then game is over
     */

    if (isGameOver()) {
      gameOver = true;
    }
  }

  //move left
  void moveLeft() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  //move right
  void moveRight() {
    //make sure the move is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  //rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  //clear lines
  void clearLines() {
    // step 1: loop through each row of the game board from bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      // step 2: initialize a variable to track if the row is full
      bool rowIsFull = true;

      // step 3: check if the row is full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there is an empty col, set rowIsFull & break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: if the row is full, clear the row & shift rows down
      if (rowIsFull) {
        // step 5: move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          //copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        //step 6: set the top row to empty
        gameBoard[0] = List.generate(row, (index) => null);

        // step 7: increase the score!
        currentScore += 10;
      }
    }
  }

  //GAME OVER METHOD
  bool isGameOver() {
    //check if any columns in the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    // if the top row is empty, the game is not over
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          //GAME BOARD
          Expanded(
            child: GridView.builder(
                itemCount: rowLength * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLength),
                itemBuilder: (context, index) {
                  //get row & col each index
                  int row = (index / rowLength).floor();
                  int col = (index % rowLength);

                  //current piece
                  if (currentPiece.position.contains(index)) {
                    return Pixel(color: currentPiece.color);
                  }

                  //landed pieces
                  else if (gameBoard[row][col] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][col];
                    return Pixel(
                      color: tetrominoColors[tetrominoType],
                    );
                  }

                  //blank pixel
                  else {
                    return Pixel(
                      color: Colors.grey[900],
                    );
                  }
                }),
          ),

          //SCORE
          Text("Score : $currentScore",
              style: TextStyle(
                  color: Colors.yellow[700], fontWeight: FontWeight.bold)),

          //GAME CONTROLS
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, top: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //left
                IconButton(
                    onPressed: moveLeft,
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back_ios_new)),

                //rotate
                IconButton(
                    onPressed: rotatePiece,
                    color: Colors.white,
                    icon: const Icon(Icons.rotate_right)),

                //right
                IconButton(
                    onPressed: moveRight,
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
