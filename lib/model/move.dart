import 'dart:convert';

class Move {
  String challengeID;
  bool isPossible;

  Move({
    required this.challengeID,
    this.isPossible = false,
  });

  // Convert a Move object into a String.
  @override
  String toString() {
    Map<String, dynamic> map = {
      'isPossible': isPossible,
      'challengeID': challengeID,
    };
    return jsonEncode(map);
  }

  // Convert a String into a Move object.
  static Move fromString(String moveString) {
    Map<String, dynamic> map = jsonDecode(moveString);
    return Move(
      isPossible: map['isPossible'],
      challengeID: map['challengeID'],
    );
  }

  // Method to check if a move is possible
  bool isMovePossible() {
    return isPossible;
  }

  allowMove() {
    isPossible = true;
  }

  resetMovePossibility() {
    isPossible = false;
  }



}

