import 'package:flutter/material.dart';

import 'table_cell.dart';
import 'constants.dart';

class TableHead extends StatelessWidget {
  final Map<String, dynamic> runs;
  final ScrollController scrollController;

  TableHead({
    required this.scrollController,
    required this.runs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cellHeight,
      child: Row(
        children: [
          // MultiplicationTableCell(
          //   color: Colors.yellow.withOpacity(0.3),
          //   value: 1,
          // ),
          Container(
            width: firstCellWidth,
            height: cellHeight,
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                color: Colors.black12,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: List.generate(runs.length, (index) {
                return Container(
                  width: cellHeight,
                  height: cellHeight,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Container(color: Colors.green)),
                  // Text(
                  //   '${value ?? ''}',
                  //   style: TextStyle(fontSize: 16.0),
                  // ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
