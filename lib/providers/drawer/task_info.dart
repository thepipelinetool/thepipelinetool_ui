import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/providers/drawer/selected_task.dart';

import '../http_client.dart';

final taskInfoProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final selectedTask = ref.watch(selectedTaskProvider)!;

  var path = '/task/${selectedTask.runId}/${selectedTask.taskId}';

  // print(selectedTask.taskId);
  if (selectedTask.runId == "default") {
    path = '/default_task/${selectedTask.dagName}/${selectedTask.taskId}';
  }
  final client = ref.watch(clientProvider);

  final response = await client.get(Uri.parse('http://localhost:8000$path'));

  // final map = ;

  return jsonDecode(response.body) as Map<String, dynamic>;
});
