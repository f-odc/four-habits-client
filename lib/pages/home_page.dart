// home_page.dart
import 'package:flutter/material.dart';

import 'connect_four.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Four'),
      ),
      body: ConnectFour(),
    );
  }
}
