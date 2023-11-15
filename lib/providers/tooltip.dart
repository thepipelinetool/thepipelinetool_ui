import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/classes/task_status.dart';

import '../classes/selected_task.dart';
import '../views/task_view/http_client_provider.dart';
import 'drawer/selected_task.dart';

final hoveredTooltipProvider = StateProvider<SelectedTask?>((ref) => null);

final fetchTooltip = FutureProvider.autoDispose.family<String, TaskStatus>((ref, status) async {
  final client = ref.watch(clientProvider);
  final hovered = ref.watch(hoveredTooltipProvider);

  if (hovered == null) {
    return '';
  }

  var res = 'Status: ${status.toString()}\n';

  if (!{TaskStatus.Pending, TaskStatus.Running, TaskStatus.Retrying, TaskStatus.None}.contains(status)) {
    final response3 = await client.get(
      Uri.parse(
          // TODO use task result info? we dont use the actual result here, only info
          'http://localhost:8000/task_result/${hovered.runId}/${hovered.taskId}'),
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    );
    final result = jsonDecode(response3.body);
//     {attempt: 1, elapsed: 0, ended: 2023-11-13T01:42:17.206218+00:00, function_name: hi, is_branch: false, max_attempts: 1, premature_failure: false,
// premature_failure_error_str: , resolved_args_str: 0, result: {hello: world}, started: 2023-11-13T01:42:17.203640+00:00, stderr: , stdout: 0
// , success: true, task_id: 0, template_args_str: 0}
    res += 'Started: ${result["started"]}\n';
    res += 'Ended: ${result["ended"]}\n';
    res += 'Elapsed: ${result["elapsed"]}\n';
    res += 'Success: ${result["success"]}';
  }

  return res;
});
