import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  // Expanded(
                  //     child:
                  ExpansionPanelList.radio(children: [
                    ExpansionPanelRadio(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return const ListTile(
                            title: Text('Args'),
                          );
                        },
                        body: Column(children: [
                          Container(
                            child: Text(encoder.convert(v["template_args"])),
                          )
                        ]),
                        value: 'Args'),
                    if (v.containsKey("results"))
                      ExpansionPanelRadio(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return const ListTile(
                              title: Text('Attempts'),
                            );
                          },
                          body: Column(children: [
                            Container(
                              child: Text(encoder.convert(v["results"])),
                            )
                          ]),
                          value: 'Attempts')
                  ]),
                  Text(encoder.convert(v))
                  // )
                ]));

            // print(value);
            // return Text(value.toString());
          }(),
        ),
      // ),
      (_) => Container(
          color: Colors.red,
        )
    };

    // return Text(appState);
    // return Text("test");
  }
}