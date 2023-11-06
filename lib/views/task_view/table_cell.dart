import 'package:flutter/material.dart';

const double cellHeight = 20;
const double firstCellWidth = 100;

class MultiplicationTableCell extends StatelessWidget {
  final String runId;
  final Map value;
  // final Color color;

  MultiplicationTableCell({
    required this.value, required this.runId,
    // required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
      onTap: () {
        print(runId);
        print(value);
      },
      child:
    Container(
      width: cellHeight,
      height: cellHeight,
      decoration: BoxDecoration(
        color: Colors.red,
        border: Border.all(
          color: Colors.black12,
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(padding: EdgeInsets.all(2),child: Container(color: Colors.green)),
      // Text(
      //   '${value ?? ''}',
      //   style: TextStyle(fontSize: 16.0),
      // ),
    ),);
  }
}
