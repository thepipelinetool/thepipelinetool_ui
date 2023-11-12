import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'multiplication_table.dart';
import 'table_cell.dart';

final fetchTasksProvider =
    FutureProvider.autoDispose.family<List<Map>, String>((ref, dagName) async {
  // final path = '/default_tasks/$dagName';
  final client = ref.watch(clientProvider);

  final response = await client.get(
    Uri.parse('http://localhost:8000/default_tasks/$dagName'),
  );

  return (await compute(jsonDecode, response.body) as List<dynamic>)
      .cast<Map>();
});

final fetchRunsWithTasksProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, dagName) async {
  final client = ref.watch(clientProvider);

  final response = await client.get(
    Uri.parse('http://localhost:8000/runs_with_tasks/$dagName'),
  );

  return await compute(jsonDecode, response.body) as Map<String, dynamic>;
});

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

final combinedProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, dagName) async {
  final taskProvider = await ref.watch(fetchTasksProvider(dagName).future);
  final runsProvider =
      await ref.watch(fetchRunsWithTasksProvider(dagName).future);
  return {
    'tasks': taskProvider,
    'runs': runsProvider,
  };
});

class TaskViewState extends ConsumerState<TaskView>
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
  // TaskViewState(this.dagName, {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(combinedProvider(widget.dagName));

    return switch (provider) {
      AsyncData(:final value) => FadeTransition(
          opacity: _animation,
          child: MultiplicationTable(
            tasks: value["tasks"],
            runs: value["runs"],
            dagName: widget.dagName,
            // scaffoldKey: widget.scaffoldKey,
          ),
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
