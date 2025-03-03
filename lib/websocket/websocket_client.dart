import 'dart:convert';

import 'package:http/http.dart' as http;

class WebSocketClient {
  static String url = 'http://192.168.0.152:8080';
  static String token = '187';

  WebSocketClient();

  // TODO: use json request
  static Future<void> post(Map<String, dynamic> data) async {
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['id'] = data['id']
      ..fields['challenger'] = data['challenger']
      ..fields['challengerID'] = data['challengerID']
      ..fields['lastMoverID'] = data['lastMoverID']
      ..fields['board'] = jsonEncode(data['board'])
      ..fields['canPerformMove'] = data['canPerformMove'].toString()
      ..fields['habitId'] = data['habitId']
      ..fields['habitName'] = data['habitName']
      ..fields['habitOccurrence'] = data['habitOccurrence']
      ..fields['habitOccurrenceType'] = data['habitOccurrenceType'];

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Response: ${await response.stream.bytesToString()}');
    } else {
      print('Failed to post data');
    }
  }

  static Future<void> get(String message) async {
    final response = await http.get(
      Uri.parse('$url?message=$message'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Failed to load data');
    }
  }
}
