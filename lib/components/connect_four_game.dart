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

    // check if game is over
    // Check for a winner
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (_board[row][col] != 0 && _checkWin(row, col)) {
          _gameOver = true;
          _winnerMessage = 'Player ${_board[row][col]} wins!';
          return;
        }
      }
    }
    // Check for draw
    if (_isBoardFull()) {
      _gameOver = true;
      _winnerMessage = 'It\'s a draw!';
    }
  }

  void _resetBoard() {
    _board = List.generate(rows, (_) => List.filled(columns, 0));
    _currentPlayer = 1;
    _gameOver = false;
    _winnerMessage = '';
    // update challenge data
    widget.challenge.challengerID = _playerID;
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

        // Now update the UI
        setState(() {
          if (_checkWin(row, column)) {
            _gameOver = true;
            _winnerMessage = 'Player $_currentPlayer wins!';
          } else if (_isBoardFull() && !_gameOver) {
            _gameOver = true;
            _winnerMessage = 'It\'s a draw!';
          }

          widget.onMoveMade?.call();
        });

        // Prevent multiplay -> post after all changes are done
        // Post to server — OUTSIDE setState
        await WebSocketClient.post(widget.challenge.toJson());

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

  bool _isBoardFull() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (_board[row][col] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  Color _getColor(int player) {
    switch (player) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.black54;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* "YOUR COLOR" WIDGET*/
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Color: ',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColor(_currentPlayer),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentPlayer == 1 ? 'Orange' : 'Black',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getColor(_currentPlayer),
                ),
              ),
            ],
          ),
        ),
        /* BOARD */
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
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _winnerMessage,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getColor(widget.challenge.lastMoverID == _playerID
                          ? _currentPlayer
                          : (_currentPlayer == 1 ? 2 : 1))),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[100],
                    foregroundColor: Colors.orange, // Text color
                  ),
                  onPressed: () {
                    setState(() {
                      _resetBoard();
                    });
                  },
                  child: const Text('Reset Game',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
