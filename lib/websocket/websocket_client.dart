import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebSocketClient {
  final String url;

  WebSocketClient({required this.url});

  static Future<void> post(String url, Map<String, dynamic> data) async {
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['id'] = data['id']
      ..fields['name'] = data['name']
      ..fields['occurrence'] = data['occurrence']
      ..fields['num'] = data['num']
      ..fields['board'] = jsonEncode(data['board'])
      ..fields['challenger'] = data['challenger'].toString()
      ..fields['score'] = data['score'].toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Response: ${await response.stream.bytesToString()}');
    } else {
      print('Failed to post data');
    }
  }

  static Future<void> get(String url, String message) async {
    final response = await http.get(Uri.parse('$url?message=$message'));
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Failed to load data');
    }
  }
}