import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? cardColor;
  final String cardText;
  final Color? cardTextColor;
  final String? trailingText;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final bool? centerText;

  const CustomCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.cardText,
    required this.cardTextColor,
    this.trailingText,
    this.trailingIcon,
    this.trailingIconColor,
    this.centerText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          textAlign: centerText! ? TextAlign.center : TextAlign.start,
          cardText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: cardTextColor,
          ),
        ),
        trailing: trailingText != null || trailingIcon != null
            ? Row(
                // include only if tailing parameters are set
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (trailingText != null)
                    Text(
                      trailingText!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  if (trailingIcon != null)
                    Icon(trailingIcon, color: trailingIconColor),
                ],
              )
            : null,
      ),
    );
  }
}
