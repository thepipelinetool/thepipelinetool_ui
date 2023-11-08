import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:thepipelinetool/views/task_view/table_cell.dart';
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(json);
final selectedTaskProvider =
    StateNotifierProvider<SelectedTaskStateNotifier, SelectedTask>((ref) {
  return SelectedTaskStateNotifier();
});

final fetchTaskProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, dagName) async {
  final selectedTask = ref.watch(selectedTaskProvider);
  final taskStatus = await ref.watch(fetchTaskStatusProvider(
      (dagName, selectedTask.runId, int.parse(selectedTask.taskId), false)).future);

  var path = '/task/$dagName/${selectedTask.runId}/${selectedTask.taskId}';

  // print(selectedTask.taskId);
  if (selectedTask.taskId == "default") {
    path = '/task/$dagName/${selectedTask.runId}/${selectedTask.taskId}';
  }

  final response = await http.get(Uri.parse('http://localhost:8000$path'));

  final map = jsonDecode(response.body) as Map<String, dynamic>;

  path = '/task_result/$dagName/${selectedTask.runId}/${selectedTask.taskId}';

  // print(selectedTask.taskId);
  if (selectedTask.taskId == "default") {
    path = '/task_result/$dagName/${selectedTask.runId}/${selectedTask.taskId}';
  }

  var map2 = {};

  if (!{"Pending", "Running", "Retrying"}.contains(taskStatus['status'])) {
    final response2 = await http.get(Uri.parse('http://localhost:8000$path'));

    map2 = jsonDecode(response2.body) as Map<String, dynamic>;
    map["results"] = map2;

  }

  // if (selectedTask.runId != "default" &&
  //     {"Pending", "Running", "Retrying"}.contains(taskStatus['status'])) {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     // print('refresh');
  //     ref.invalidateSelf();
  //   });
  // }

  // print(map);
  map["status"] = taskStatus["status"];

  return map;
});

class SelectedTaskStateNotifier extends StateNotifier<SelectedTask> {
  SelectedTaskStateNotifier() : super(SelectedTask(runId: '', taskId: ''));
  void updateData(SelectedTask newData) {
    state = newData;
  }
  // void updateData(String newData) {
  //   state = state.copyWith(data: newData);
  // }
}

class SelectedTask {
  final String runId;
  final String taskId;

  SelectedTask({required this.runId, required this.taskId});
}

class MyDrawer extends ConsumerStatefulWidget {
  final String dagName;

  const MyDrawer({required this.dagName, super.key});

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

    final task = ref.watch(fetchTaskProvider(widget.dagName));

    return switch (task) {
      AsyncData(:final value) => FadeTransition(
        // key: const Key('key'),
          opacity: _animation,
          child: () {
            return 
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  Row(children: [
                    Container(
                        height: 50,
                        child:
                            Text("${value["function_name"]}_${value["id"]}")),
  const Spacer(),
                            Container(
                        height: 50,
                        child:
                            Text("${value["status"]}")),
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
                            child: Text(encoder.convert(value["template_args"])),
                          )
                        ]),
                        value: 'Args'),
                        if (value.containsKey("results")) ExpansionPanelRadio(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return const ListTile(
                            title: Text('Attempts'),
                          );
                        },
                        body: Column(children: [
                          Container(
                            child: Text(encoder.convert(value["results"])),
                          )
                        ]),
                        value: 'Attempts')
                  ]),
                  Text(encoder.convert(value))
                  // )
                ]));

            // print(value);
            // return Text(value.toString());
          }(),
        ),
      // ),
      (_) => Container()
    };

    // return Text(appState);
    // return Text("test");
  }
}
