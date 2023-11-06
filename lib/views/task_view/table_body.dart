// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'table_cell.dart';
import 'constants.dart';

class TableBody extends StatefulWidget {
  final String dagName;
  final List<Map<dynamic, dynamic>> tasks;
  final Map<String, dynamic> runs;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  final ScrollController scrollController;

  const TableBody({
    super.key,
    required this.scrollController,
    required this.tasks,
    required this.runs,
    required this.dagName,
    // required this.scaffoldKey,
  });

  @override
  TableBodyState createState() => TableBodyState();
}

class TableBodyState extends State<TableBody> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _firstColumnController;
  late ScrollController _restColumnsController;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // RefreshIndicator(
        //   notificationPredicate: (ScrollNotification notification) {
        //     return notification.depth == 0 || notification.depth == 1;
        //   },
        //   onRefresh: () async {
        //     await Future.delayed(
        //       Duration(seconds: 2),
        //     );
        //   },
        //   child:
        Row(
      children: [
        SizedBox(
          width: firstCellWidth,
          child: ListView(
            controller: _firstColumnController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: List.generate(widget.tasks.length, (index) {
              return 
              // Container(
              //   padding: EdgeInsets.only(top: 2),
              //   child: 
              Container(
                // color: Colors.green,
                height: cellHeight,
                width: firstCellWidth,
                child: FittedBox(
        fit: BoxFit.fitHeight, 
        child:Text(
                    "${widget.tasks[index]["function_name"]}_${widget.tasks[index]["id"]}"),
              ));
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: (widget.runs.length) * cellHeight,
              child: ListView(
                controller: _restColumnsController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: List.generate(widget.tasks.length, (y) {
                  final runIds = widget.runs.keys.toList(growable: false);

                  return Row(
                    children: runIds.map((runId) {
                      // final run = widget.runs[x];
                      final task = widget.tasks[y];
                      final key = '${task["function_name"]}_${task["id"]}';
                      final containsFunction =
                          widget.runs[runId].containsKey(key);

                      // print("dagName: ${widget.dagName} runId: $runId value: ${widget.runs[runId][key]}");

                      if (containsFunction) {
                        return MultiplicationTableCell(
                          dagName: widget.dagName,
                          runId: runId,
                          value: widget.runs[runId][key],
                          // scaffoldKey: widget.scaffoldKey,
                          // color: Colors.red,
                        );
                      }
                      // print(widget.runs[runId]);
                      // print(widget.tasks[y]);

                      return MultiplicationTableCell(
                        dagName: widget.dagName,
                        runId: '',
                        value: const {},
                        // scaffoldKey: widget.scaffoldKey,
                        // color: Colors.red,
                      );
                    }).toList(growable: false),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
      // ),
    );
  }
}
