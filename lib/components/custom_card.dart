import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? cardColor;
  final String cardText;
  final Color? cardTextColor;

  const CustomCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.cardText,
    required this.cardTextColor,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          cardText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: cardTextColor,
          ),
        ),
      ),
    );
  }
}