// connect_four.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../NotificationService.dart';

class ConnectFour extends StatefulWidget {
  const ConnectFour({super.key});

  @override
  _ConnectFourState createState() => _ConnectFourState();
}

class _ConnectFourState extends State<ConnectFour> {
  late List<List<int>> board =
      List.generate(6, (_) => List.generate(7, (_) => 0));
  late int currentPlayer = 1;
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _resetGame() async {
    // Reset the game state
    board = List.generate(6, (_) => List.generate(7, (_) => 0));
    currentPlayer = 1;

    // Clear the saved game state from shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('board');
    prefs.remove('currentPlayer');

    // Update the UI
    setState(() {});
  }

  void _handleMove(int column) {
    for (int row = 5; row >= 0; row--) {
      if (board[row][column] == 0) {
        setState(() {
          board[row][column] = currentPlayer;
          if (_checkWin(row, column)) {
            print('Player $currentPlayer wins!');
            _resetGame();
          } else {
            currentPlayer = 3 - currentPlayer;
          }
        });
        _saveGameState();
        // TODO: rework notifications
        /*Future.delayed(Duration(seconds: 30), () {
          notificationService.showNotification();
        });*/
        break;
      }
    }
  }

  bool _checkWin(int row, int column) {
    // Check for a win. This can be done in several ways, but one approach is to
    // check for four in a row horizontally, vertically, and in both diagonals.
    // This is left as an exercise for the reader.
    return false;
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('board', jsonEncode(board));
    prefs.setInt('currentPlayer', currentPlayer);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBoard = prefs.getString('board');
    final savedCurrentPlayer = prefs.getInt('currentPlayer');

    if (savedBoard != null && savedCurrentPlayer != null) {
      setState(() {
        board = List<List<int>>.from(
            jsonDecode(savedBoard).map((x) => List<int>.from(x.map((x) => x))));
        currentPlayer = savedCurrentPlayer;
      });
    } else {
      _resetGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          final row = index ~/ 7;
          final column = index % 7;
          return GestureDetector(
            onTap: () => _handleMove(column),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              color: _getColor(board[row][column]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Color _getColor(int player) {
    switch (player) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }
}
