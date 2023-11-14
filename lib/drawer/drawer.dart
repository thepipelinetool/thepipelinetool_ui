import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/details_page_state.dart';
import 'package:thepipelinetool/views/task_view/constants.dart';
import 'package:thepipelinetool/views/task_view/table_cell.dart';

JsonEncoder encoder = const JsonEncoder.withIndent('  ');
String prettyprint = encoder.convert(json);
final selectedTaskProvider =
    StateNotifierProvider<SelectedTaskStateNotifier, SelectedTask?>((ref) {
  return SelectedTaskStateNotifier();
});

final fetchTaskProvider =
    FutureProvider.autoDispose<(Map<String, dynamic>, TaskStatus)>((ref) async {
  final selectedTask = ref.watch(selectedTaskProvider)!;

  var path =
      '/task/${selectedTask.dagName}/${selectedTask.runId}/${selectedTask.taskId}';

  // print(selectedTask.taskId);
  if (selectedTask.runId == "default") {
    path = '/default_task/${selectedTask.dagName}/${selectedTask.taskId}';
  }
  final client = ref.watch(clientProvider);

  final response = await client.get(Uri.parse('http://localhost:8000$path'));

  final map = jsonDecode(response.body) as Map<String, dynamic>;

  path =
      '/task_result/${selectedTask.dagName}/${selectedTask.runId}/${selectedTask.taskId}';
  var map2 = {};

  TaskStatus taskStatus;

  // print(selectedTask.taskId);
  if (selectedTask.runId != "default") {
    taskStatus = await ref.watch(fetchTaskStatusProvider((
      selectedTask.dagName,
      selectedTask.runId,
      int.parse(selectedTask.taskId),
      true
    )).future);
    if (!{TaskStatus.Pending, TaskStatus.Running, TaskStatus.Retrying}
        .contains(taskStatus)) {
      final response2 =
          await client.get(Uri.parse('http://localhost:8000$path'));

      map2 = jsonDecode(response2.body) as Map<String, dynamic>;
      // map2["template_args"] = jsonDecode(map2["template_args_str"]);
      map2["resolved_args"] = jsonDecode(map2["resolved_args_str"]);

      map2.remove("resolved_args_str");
      map2.remove("template_args_str");

      map["results"] = map2;


      // print(map2);
    }
  } else {
    taskStatus = TaskStatus.None;
  }

  // if (selectedTask.runId != "default" &&
  //     {"Pending", "Running", "Retrying"}.contains(taskStatus['status'])) {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     // print('refresh');
  //     ref.invalidateSelf();
  //   });
  // }

  // print(map);
  // map["status"] = taskStatus;

  return (map, taskStatus);
});

class SelectedTaskStateNotifier extends StateNotifier<SelectedTask?> {
  SelectedTaskStateNotifier() : super(null);
  void updateData(SelectedTask newData) {
    state = newData;
  }
  // void updateData(String newData) {
  //   state = state.copyWith(data: newData);
  // }
}

class SelectedTask {
  final String dagName;
  final String runId;
  final String taskId;

  SelectedTask(
      {required this.runId, required this.taskId, required this.dagName});
}

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  MyDrawerState createState() => MyDrawerState();
}

class MyDrawerState extends ConsumerState<MyDrawer>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );
  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final appState = ref.watch(selectedTaskProvider);

    final task = ref.watch(fetchTaskProvider);

    return switch (task) {
      AsyncData(:final value) => FadeTransition(
          // key: const Key('key'),
          opacity: _animation,
          child: () {
            final status = value.$2;
            final v = value.$1;
            print('');
            print(v);
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  Row(children: [
                    Container(
                        key: Key("${v["function_name"]}_${v["id"]}"),
                        height: 50,
                        child: Text("${v["function_name"]}_${v["id"]}")),
                    const Spacer(),
                    Container(height: 50, child: Text(status.toString())),
                  ]),
                  Expanded(
                      child:
                  SingleChildScrollView(child: ExpansionPanelList.radio(
                    // materialGapSize: 0,
                    // dividerColor: Colors.transparent,
                    elevation: 0,
                    children: [
                    ExpansionPanelRadio(
                      // backgroundColor: Colors.transparent,
                      canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            // tileColor: Theme.of(context).primaryColor,
                            
                            // style: ListTileStyle.list,
                            title: Text('Args'),
                          );
                        },
                        // body: v["template_args"] == null ? Container() : Container(width: 400, child: jsonView(v["template_args"], false)),
                                                  body: 
                          Align(alignment: Alignment.topLeft, child: Container(
                                                          padding: EdgeInsets.only(left: kHorizontalPadding, right: kHorizontalPadding, bottom: kHorizontalPadding),
                            child: Text(encoder.convert(v["template_args"])),
                          )),
                        
                        
                        value: 'Args'),
                    if (v.containsKey("results"))
                      ExpansionPanelRadio(
                                              // backgroundColor: Colors.transparent,

                                              canTapOnHeader: true,

                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return const ListTile(
                              title: Text('Attempts'),
                            );
                          },
                          body: 
                            Align(alignment: Alignment.topLeft, child: Container(
                                                          padding: EdgeInsets.only(left: kHorizontalPadding, right: kHorizontalPadding, bottom: kHorizontalPadding),

                              child: Text(encoder.convert(v["results"])),
                            ))
                          ,
                          value: 'Attempts')
                  ]),
                  // Text(encoder.convert(v))
                  ))
                ]));

            // print(value);
            // return Text(value.toString());
          }(),
        ),
      // ),
      (_) => Container(
          // color: Colors.red,
        )
    };

    // return Text(appState);
    // return Text("test");
  }
}


  Widget jsonView(Object o, bool inner) {
    var items = <Widget>[];
    if (o is List) {
      items = o.map((e) => Text(e.toString())).toList();
      print(1);
    } else if (o is Map) {
      items = [
        Container(
            // decoration: BoxDecoration(
            //     // border: Border.all()
            //     ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(),
                                    left: BorderSide(),
                                    bottom: BorderSide(),
                                    right: inner ? BorderSide.none : BorderSide()
                                  ),
                                ),
            child: Table(
                children:
                    // TableRow(children: o.keys.map((e) => Text(e.toString())).toList()),
                    // TableRow(children: o.values.map((e) => jsonView(e)).toList())
                    o.entries
                        .map((e) => TableRow(
                                children: [
                                  Text("${e.key}:"),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: jsonView(e.value, true))
                                ]))
                        .toList()))
      ];
      print(2);
    } else {
      items = [Text(o.toString())];
      print(3);
    }
    print(items);

    // return ListView.builder(
    //   itemCount: items.length,
    //   itemBuilder: (ctx, index) {
    //     return items[index];
    //   });
    return Wrap(
        // color: Colors.blue,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: items)
        ]);
  }
