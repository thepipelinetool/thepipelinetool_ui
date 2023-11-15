import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/providers/drawer/selected_task.dart';

import '../http_client.dart';

final taskResultsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final selectedTask = ref.watch(selectedTaskProvider)!;

  final path = '/task_results/${selectedTask.runId}/${selectedTask.taskId}';

  final client = ref.watch(clientProvider);

  final response = await client.get(Uri.parse('http://localhost:8000$path'));

  return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
});
