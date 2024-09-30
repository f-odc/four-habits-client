import 'dart:convert';

class Challenge {
  final String habitId;
  String habitName;
  String habitOccurrenceType;
  String habitOccurrenceNum;
  List<List<int>> board;
  int challengerID;

  Challenge({
    required this.habitId,
    required this.habitName,
    required this.habitOccurrenceType,
    required this.habitOccurrenceNum,
    required this.board,
    required this.challengerID,
  });

  // Convert a Habit object into a String.
  String toString() {
    Map<String, dynamic> map = {
      'id': habitId,
      'name': habitName,
      'occurrence': habitOccurrenceNum,
      'occurrenceType': habitOccurrenceType,
      'board': board,
      'currentPlayer': challengerID,
    };
    return jsonEncode(map);
  }

  // Convert a Challenge object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': habitId,
      'name': habitName,
      'occurrence': habitOccurrenceType,
      'num': habitOccurrenceNum,
      'board': board,
      'challenger': challengerID,
      'score': 0,
    };
  }

  // Convert a String into a Challenge object.
  static Challenge fromString(String challengeString) {
    Map<String, dynamic> map = jsonDecode(challengeString);
    List<List<int>> board = List<List<int>>.from(
        map['board'].map((x) => List<int>.from(x.map((x) => x))));
    return Challenge(
      habitId: map['id'],
      habitName: map['name'],
      habitOccurrenceNum: map['occurrence'],
      habitOccurrenceType: map['occurrenceType'],
      board: board,
      challengerID: map['currentPlayer'],
    );
  }

  // Method to handle a move in the Connect Four game
  void handleMove(int column) {
    for (int row = board.length - 1; row >= 0; row--) {
      if (board[row][column] == 0) {
        board[row][column] = challengerID;
        challengerID = 3 - challengerID;
        break;
      }
    }
  }

  // Method to check for a win in the Connect Four game
  bool checkWin(int row, int column) {
    // Check for a win. This can be done in several ways, but one approach is to
    // check for four in a row horizontally, vertically, and in both diagonals.
    // This is left as an exercise for the reader.
    return false;
  }

}
