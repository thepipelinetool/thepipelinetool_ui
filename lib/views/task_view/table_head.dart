import 'package:flutter/material.dart';

import 'table_cell.dart';

class TableHead extends StatelessWidget {
  final Map<String, dynamic> runs;
  // final ScrollController scrollController;
  final List<Map<dynamic, dynamic>> tasks;

  const TableHead(
      {super.key,
      // required this.scrollController,
      required this.runs,
      required this.tasks});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: cellHeight ,child: ListView(
      // controller: scrollController,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: List.generate(runs.length, (index) {
        return Container(
          width: cellHeight,
          height: cellHeight,

          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(4.5),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // print(runId);
                  // print(value);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green, // TODO
                    borderRadius: BorderRadius.circular(50),
                    // border: Border.all(
                    //   color: Colors.black12,
                    //   width: 1.0,
                    // ),
                  ),
                ),
              ),
            ),
          ),
          // Text(
          //   '${value ?? ''}',
          //   style: TextStyle(fontSize: 16.0),
          // ),
        );
      }),
    ));
  }
}
