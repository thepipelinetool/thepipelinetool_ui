// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'table_cell.dart';
import 'constants.dart';
import 'table_head.dart';

class TableBody extends StatefulWidget {
  final String dagName;
  final List<Map<dynamic, dynamic>> tasks;
  final Map<String, dynamic> runs;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  // final ScrollController scrollController;

  const TableBody({
    super.key,
    // required this.scrollController,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        // // constraints: BoxConstraints.tight(),
        // // fit: BoxFit.contain,
        // // alignment: Alignment.bottomLeft,
        // width: firstCellWidth,
        // child:
        // ListView.builder(
        Column(children: [
          Container(
            height: outerCellHeight,
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _firstColumnController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // itemCount: widget.tasks.length,
                // itemBuilder: (ctx, index) {
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      widget.tasks.length,
                      (index) {
                        return Container(
                          //   padding: EdgeInsets.only(top: 2),
                          height: outerCellHeight,
                          // width: firstCellWidth,
                          child:
                              // SizedBox.shrink(
                              //   // color: Colors.green,
                              //   height: cellHeight,
                              // child:
                              //   FittedBox(
                              // fit: BoxFit.fitHeight,
                              // child:
                              Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${widget.tasks[index]["function_name"]}_${widget.tasks[index]["id"]}"),
                          ),
                        );
                      },
                    )
                  ],
                  // ),
                  // })),
                ),
              ),
            ),
          ),
        ]),
        // ),
        Expanded(
            child:
                // SingleChildScrollView(
                // controller: widget.scrollController,
                // scrollDirection: Axis.horizontal,
                //   physics: const BouncingScrollPhysics(),
                //   child: SizedBox(
                //     width: (widget.runs.length) * cellHeight,
                //     child:
                Column(children: [
          TableHead(
            // scrollController: _headController,
            runs: widget.runs,
            tasks: widget.tasks,
          ),
          Expanded(
              child: ListView.builder(
                  controller: _restColumnsController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: widget.tasks.length,
                  itemBuilder: (ctx, y) {
                    // final runIds = widget.runs.keys.toList(growable: false);

                    return Row(
                      children: widget.runs.keys.map((runId) {
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

                        // return MultiplicationTableCell(
                        //   dagName: widget.dagName,
                        //   runId: '',
                        //   value: const {},
                        //   // scaffoldKey: widget.scaffoldKey,
                        //   // color: Colors.red,
                        // );
                        return Container(
                            width: outerCellHeight, height: outerCellHeight);
                      }).toList(growable: false),
                    );
                  })),
        ])),
      ],
      // ),
    );
  }
}
