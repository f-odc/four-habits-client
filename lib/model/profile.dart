import 'dart:convert';

class Profile {
  String id;
  String name;

  Profile({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
    };
    return jsonEncode(map);
  }

  static Profile fromString(String profileString) {
    Map<String, dynamic> map = jsonDecode(profileString);

    return Profile(
      id: map['id'],
      name: map['name'],
    );
  }
}
