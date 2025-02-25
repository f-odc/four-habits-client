import 'package:flutter/material.dart';

class ConnectFourBoard extends StatelessWidget {
  final int rows = 6;
  final int columns = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(rows, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(columns, (colIndex) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
