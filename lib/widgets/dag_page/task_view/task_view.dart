import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/providers/task_view/task_grid.dart';
import 'package:thepipelinetool/widgets/dag_page/task_view/table_cell.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../../classes/selected_task.dart';
import '../../../providers/drawer/selected_task.dart';
// import 'multiplication_table.dart';

class TaskView extends ConsumerStatefulWidget {
  // final Widget Function(BuildContext context) bottomBar;
  final String dagName;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskView(this.dagName,
      //  this.scaffoldKey,
      {Key? key})
      : super(key: key);
  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends ConsumerState<TaskView> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );
  final _verticalController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _verticalController.dispose();
    super.dispose();
  }
  // TaskViewState(this.dagName, {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(taskGridProvider(widget.dagName));

    return switch (provider) {
      AsyncData(:final value) => FadeTransition(
          opacity: _animation,
          child: TableView.builder(
            verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
            cellBuilder: (BuildContext context, TableVicinity vicinity) {
              if (vicinity.column == 0 && vicinity.row == 0) {
                return Container();
              }

              if (vicinity.column == 0) {
                final task = value["tasks"][vicinity.row - 1];

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // ref.invalidate(fetchTaskProvider(widget.dagName));
                      // ref
                      //     .read(defaultTaskProvider.notifier)
                      //     .updateData(widget.tasks[index]);
                      ref.read(selectedTaskProvider.notifier).state =
                          SelectedTask(runId: "default", taskId: task["id"].toString(), dagName: widget.dagName);

                      Scaffold.of(context).openEndDrawer();

                      // ref.invalidate(provider)
                    },
                    child: Text("${task["function_name"]}_${task["id"]}"),
                  ),
                );
              }

              var keys = value["runs"].keys.toList();

              if (vicinity.row == 0) {
                return Container(
                  width: outerCellHeight,
                  height: outerCellHeight,

                  alignment: Alignment.center,
                  // child: Padding(
                  // padding: const EdgeInsets.all(3.8),
                  child:
                      // MouseRegion(
                      //   cursor: SystemMouseCursors.click,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       // print(runId);
                      //       // print(value);
                      //     },
                      //     child:
                      Tooltip(
                    message:
                        "Run Id: ${keys[vicinity.column - 1]}\nDate: ${value["runs"][keys[vicinity.column - 1]]["date"]}",
                    preferBelow: false,
                    verticalOffset: outerCellHeight,
                    showDuration: Duration.zero,
                    child: Container(
                      width: cellWidth,
                      height: cellWidth,
                      decoration: BoxDecoration(
                        color: Colors.green, // TODO
                        borderRadius: BorderRadius.circular(50),
                        // border: Border.all(
                        //   color: Colors.black12,
                        //   width: 1.0,
                        // ),
                      ),
                      // ),
                    ),
                    // ),
                    // ),
                  ),
                  // Text(
                  //   '${value ?? ''}',
                  //   style: TextStyle(fontSize: 16.0),
                  // ),
                );
              }

              // final run = value["runs"][vicinity.column - 1];

              // return Text("${run["date"]}");

              final task = value["tasks"][vicinity.row - 1];
              final key = '${task["function_name"]}_${task["id"]}';
              var runId = keys[vicinity.column - 1];
              final containsFunction = value["runs"][runId]["tasks"].containsKey(key);

              // print("dagName: ${widget.dagName} runId: $runId value: ${widget.runs[runId][key]}");

              if (containsFunction) {
                return MultiplicationTableCell(
                  dagName: widget.dagName,
                  runId: runId,
                  value: value["runs"][runId]["tasks"][key],
                  // scaffoldKey: widget.scaffoldKey,
                  // color: Colors.red,
                );
              }

              return Container();
            },
            pinnedColumnCount: 1,
            columnCount: value["runs"].length + 1,
            columnBuilder: (int index) {
              // if (index == 0) {
              //   return TableSpan(
              //   foregroundDecoration: const TableSpanDecoration(
              //     border: TableSpanBorder(
              //       // trailing: BorderSide(),
              //     ),
              //   ),
              //   extent: FixedTableSpanExtent(index == 0 ? 50 : cellWidth),
              //   onEnter: (_) => print('Entered column $index'),
              //   cursor: SystemMouseCursors.contextMenu,
              // );
              // }

              // index--;

              return TableSpan(
                foregroundDecoration: const TableSpanDecoration(
                  border: TableSpanBorder(
                      // trailing: BorderSide(),
                      ),
                ),
                extent: FixedTableSpanExtent(index == 0 ? 200 : outerCellHeight),
                // onEnter: (_) => print('Entered column $index'),
                // cursor: index ==  SystemMouseCursors.contextMenu,
              );
            },
            pinnedRowCount: 1,
            rowCount: value["tasks"].length + 1,
            rowBuilder: (int index) {
              return const TableSpan(
                backgroundDecoration: TableSpanDecoration(
                    // border: const TableSpanBorder(
                    //   trailing: BorderSide(
                    //     width: 1,
                    //   ),
                    // ),
                    ),
                extent: FixedTableSpanExtent(outerCellHeight),
                // cursor: SystemMouseCursors.click,
              );
            },
          )
          // MultiplicationTable(
          //   tasks: value["tasks"],
          //   runs: value["runs"],
          //   dagName: widget.dagName,
          //   // scaffoldKey: widget.scaffoldKey,
          // ),
          ),
      // CustomScrollView(slivers: [
      //     SliverList.separated(
      //       itemCount: value.length,
      //       itemBuilder: (BuildContext context, int index) {
      //         return Text(value[index]["function_name"].toString());
      //       },
      //       separatorBuilder: (BuildContext context, int index) =>
      //           const Divider(),
      //     )
      //   ]),
      AsyncError() => const Text('Oops, something unexpected happened'),
      _ => Container(),
      // const Center(child: CircularProgressIndicator()),
    };
  }
}
