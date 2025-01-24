import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Column(
        children: [
          AppBar(
            iconTheme: const IconThemeData(color: Colors.orange), // Set back button color to orange
            title: Text(
              title,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            centerTitle: true, // Center the title
            elevation: 0, // Add a small shadow
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}