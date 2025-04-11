import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/challenge.dart';
import '../model/move.dart';
import '../websocket/websocket_client.dart';

class ConnectFourGame extends StatefulWidget {
  final Challenge? challenge;
  final Move? challengeMove;

  const ConnectFourGame(
      {super.key, required this.challenge, required this.challengeMove});

  @override
  _ConnectFourGameState createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  late Challenge _challenge;
  late Move _challengeMove;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge!;
    _challengeMove = widget.challengeMove!;
  }

  void _handleMove(int column) async {
    // don't allow moves if the challenge is already completed
    if (!widget.challengeMove!.isMovePossible()) return;

    var board = _challenge.board;
    var currentPlayer = _challenge.challengerID;

    for (int row = 5; row >= 0; row--) {
      if (board[row][column] == 0) {
        setState(() {
          board[row][column] = currentPlayer;
          if (_checkWin(row, column)) {
            print('Player $currentPlayer wins!');
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

    // Update the challenge
    await WebSocketClient.post(_challenge.toJson());

    // do no allow another move
    setState(() {
      widget.challengeMove!.resetMovePossibility();
    });
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> challenges = prefs.getStringList('challenges') ?? [];

    // Find the index of the challenge to update
    int index = challenges.indexWhere((challengeString) {
      Challenge challenge = Challenge.fromString(challengeString);
      return challenge.habitId == _challenge.habitId;
    });

    if (index != -1) {
      // Update the challenge
      challenges[index] = _challenge.toString();
      // Save the updated list back to SharedPreferences
      prefs.setStringList('challenges', challenges);
    }

    // Handle the move
    _challengeMove.resetMovePossibility();
    List<String> moves = prefs.getStringList('moves') ?? [];

    // Find the index of the move to update
    int moveIndex = moves.indexWhere((moveString) {
      Move move = Move.fromString(moveString);
      return move.challengeID == _challengeMove.challengeID;
    });

    if (moveIndex != -1) {
      // Update the move
      moves[moveIndex] = _challengeMove.toString();
      // Save the updated list back to SharedPreferences
      prefs.setStringList('moves', moves);
    }
  }

  bool _checkWin(int row, int column) {
    // Check for a win. This can be done in several ways, but one approach is to
    // check for four in a row horizontally, vertically, and in both diagonals.
    // This is left as an exercise for the reader.
    return false;
  }

  Future<void> _resetGame() async {
    // Reset the game state
    //var board = List.generate(6, (_) => List.generate(7, (_) => 0));

    // Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
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
                    margin: const EdgeInsets.all(2.0),
                    width: 20,
                    height: 20,
                    color: _getColor(_challenge.board[row][column]),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Reset Game'),
            ),
          ],
        ),
        if (!widget.challengeMove!.isMovePossible())
          Positioned.fill(
            child: Container(
              color: Colors.grey.withOpacity(0.7),
              child: const Center(
                child: Text(
                  'You cannot play currently',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
      ],
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
