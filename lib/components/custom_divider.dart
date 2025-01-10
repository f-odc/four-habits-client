import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double? height;
  const CustomDivider({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 2.0,
      indent: 16.0,
      endIndent: 16.0,
      height: height,
    );
  }
}
