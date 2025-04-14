import 'package:flutter/material.dart';

import '../model/challenge.dart';
import '../services/shared_preferences_service.dart';
import '../websocket/websocket_client.dart';

class ConnectFourGame extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback? onMoveMade;

  const ConnectFourGame({
    super.key,
    required this.challenge,
    required this.onMoveMade,
  });

  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  static const int rows = 6;
  static const int columns = 7;

  late List<List<int>> _board;
  final pref = SharedPreferencesService();
  String _playerID = "";
  int _currentPlayer = 1; // 1 = Red, 2 = Yellow
  bool _gameOver = false;
  String _winnerMessage = '';

  @override
  void initState() {
    var profile = pref.getProfile();
    super.initState();
    _board = widget.challenge.board;
    _currentPlayer = widget.challenge.challengerID == profile.id
        ? 1
        : 2; // currentPlayer = 1 if challenger, else 2
    _playerID = profile.id;
  }

  void _resetBoard() {
    _board = List.generate(rows, (_) => List.filled(columns, 0));
    _currentPlayer = 1;
    _gameOver = false;
    _winnerMessage = '';
  }

  void _handleMove(int column) async {
    if (_gameOver) return;

    for (int row = rows - 1; row >= 0; row--) {
      if (_board[row][column] == 0) {
        // Update the challenge data first
        _board[row][column] = _currentPlayer;
        widget.challenge.lastMoverID = _playerID;
        widget.challenge.board = _board;
        pref.setChallengeBool(widget.challenge.id, false);

        // Save locally
        pref.updateChallenge(widget.challenge);

        // Post to server — OUTSIDE setState
        await WebSocketClient.post(widget.challenge.toJson());

        // Now update the UI
        setState(() {
          if (_checkWin(row, column)) {
            _gameOver = true;
            _winnerMessage = 'Player $_currentPlayer wins!';
          }

          widget.onMoveMade?.call();
        });
        break;
      }
    }
  }

  bool _checkWin(int row, int col) {
    int player = _board[row][col];
    if (player == 0) return false;

    int countInDirection(int dx, int dy) {
      int count = 0;
      int r = row + dy;
      int c = col + dx;
      while (r >= 0 &&
          r < rows &&
          c >= 0 &&
          c < columns &&
          _board[r][c] == player) {
        count++;
        r += dy;
        c += dx;
      }
      return count;
    }

    List<List<int>> directions = [
      [1, 0], // horizontal
      [0, 1], // vertical
      [1, 1], // diagonal down-right
      [1, -1], // diagonal up-right
    ];

    for (var dir in directions) {
      int count = 1 +
          countInDirection(dir[0], dir[1]) +
          countInDirection(-dir[0], -dir[1]);
      if (count >= 4) return true;
    }

    return false;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 7 / 6,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
            ),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              final row = index ~/ columns;
              final col = index % columns;
              return GestureDetector(
                onTap: () => _handleMove(col),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColor(_board[row][col]),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
              );
            },
          ),
        ),
        if (_gameOver)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _winnerMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _resetBoard();
            });
          },
          child: const Text('Reset Game'),
        ),
      ],
    );
  }
}
