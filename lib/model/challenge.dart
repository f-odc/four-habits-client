import 'dart:convert';

class Challenge {
  // challenge
  String id;
  String challenger;
  String challengerID;
  String lastMoverID;
  List<List<int>> board;
  bool canPerformMove;
  // habit
  final String habitId;
  String habitName;
  String habitOccurrenceType;
  String habitOccurrenceNum;

  Challenge({
    required this.id,
    required this.challenger,
    required this.challengerID,
    required this.lastMoverID,
    required this.board,
    required this.canPerformMove,
    required this.habitId,
    required this.habitName,
    required this.habitOccurrenceType,
    required this.habitOccurrenceNum,
  });

  // Convert a Habit object into a String.
  String toString() {
    Map<String, dynamic> map = {
      'id': id,
      'challenger': challenger,
      'challengerID': challengerID,
      'lastMoverID': lastMoverID,
      'board': board,
      'canPerformMove': canPerformMove,
      'habitId': habitId,
      'habitName': habitName,
      'habitOccurrence': habitOccurrenceNum,
      'habitOccurrenceType': habitOccurrenceType,
    };
    return jsonEncode(map);
  }

  // Convert a Challenge object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenger': challenger,
      'challengerID': challengerID,
      'lastMoverID': lastMoverID,
      'board': board,
      'canPerformMove': canPerformMove,
      'habitId': habitId,
      'habitName': habitName,
      'habitOccurrence': habitOccurrenceNum,
      'habitOccurrenceType': habitOccurrenceType,
    };
  }

  // Convert a String into a Challenge object. For SharedPreferences
  static Challenge fromString(String challengeString) {
    print("Challenge fromString: $challengeString");
    Map<String, dynamic> map = jsonDecode(challengeString);
    List<List<int>> board = List<List<int>>.from(
        map['board'].map((x) => List<int>.from(x.map((x) => x))));
    return Challenge(
      id: map['id'],
      challenger: map['challenger'],
      challengerID: map['challengerID'],
      lastMoverID: map['lastMoverID'],
      board: board,
      canPerformMove: map['canPerformMove'],
      habitId: map['habitId'],
      habitName: map['habitName'],
      habitOccurrenceNum: map['habitOccurrence'],
      habitOccurrenceType: map['habitOccurrenceType'],
    );
  }

  // Convert a JSON map into a Challenge object. For API Calls
  static Challenge fromJson(Map<String, dynamic> json) {
    List<dynamic> rawBoard = jsonDecode(json['board']);
    List<List<int>> board =
        rawBoard.map<List<int>>((row) => List<int>.from(row)).toList();
    bool canPerformMove = json['canPerformMove'] == 'true';
    String habitOccurrence =
        json['habitOccurrenceNum'] == null ? '0' : json['habitOccurrenceNum'];
    return Challenge(
      id: json['id'],
      challenger: json['challenger'],
      challengerID: json['challengerID'],
      lastMoverID: json['lastMoverID'],
      board: board,
      canPerformMove: canPerformMove,
      habitId: json['habitId'],
      habitName: json['habitName'],
      habitOccurrenceNum: habitOccurrence,
      habitOccurrenceType: json['habitOccurrenceType'],
    );
  }

  // Method to handle a move in the Connect Four game
  void handleMove(int column) {
    // TODO: if callengerID != ownID -> player = 1
    for (int row = board.length - 1; row >= 0; row--) {
      if (board[row][column] == 0) {
        board[row][column] = 0;
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
