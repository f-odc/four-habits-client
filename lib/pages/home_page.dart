// home_page.dart
import 'package:flutter/material.dart';

import 'connect_four.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Four'),
      ),
      body: const ConnectFour(),
    );
  }
}
