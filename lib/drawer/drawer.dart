import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final selectedTaskProvider =
    StateNotifierProvider<SelectedTaskStateNotifier, SelectedTask>((ref) {
  return SelectedTaskStateNotifier();
});

final fetchTaskProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, dagName) async {
  final selectedTask = ref.watch(selectedTaskProvider);

  var path = '/task/$dagName/${selectedTask.runId}/${selectedTask.taskId}';

  print(selectedTask.taskId);
  if (selectedTask.taskId == "default") {
    path = '/task/$dagName/${selectedTask.runId}/${selectedTask.taskId}';
  }

  final response = await http.get(Uri.parse('http://localhost:8000$path'));

  final map = jsonDecode(response.body) as Map<String, dynamic>;

  // if (runId != "default" &&
  //     map.any(
  //         (m) => {"Pending", "Running", "Retrying"}.contains(m['status']))) {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     // print('refresh');
  //     ref.invalidateSelf();
  //   });
  // }

  print(map);

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
      AsyncData(:final value) =>
        FadeTransition(
          opacity: _animation,
          child:
        () {
          print(value);
          return Text(value.toString());
        }(),
      ),
      // ),
      (_) => Container()
    };

    // return Text(appState);
    // return Text("test");
  }
}
