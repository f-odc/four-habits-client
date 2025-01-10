import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 2.0,
      indent: 16.0,
      endIndent: 16.0,
      height: 1,
    );
  }
}