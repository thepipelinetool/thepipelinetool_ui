import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/deserialize/dag_options.dart';

import 'views/task_view/table_cell.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'provider.g.dart';

// @riverpod
// class AsyncTodosNotifier extends _$AsyncTodosNotifier {
//   @override
//   Future<List<String>> build() async {
//     final json = await http.get('api/todos');

//     return [...json.map(Todo.fromJson)];
//   }

//   // ...
// }

// @riverpod
// Future<List<String>> activity(
//   // Ref ref,
//   // We can add arguments to the provider.
//   // The type of the parameter can be whatever you wish.
//   // String activityType,
// ) async {
//   // We can use the "activityType" argument to build the URL.
//   // This will point to "https://boredapi.com/api/activity?type=<activityType>"
//   final response = await http.get(
//     Uri(
//       scheme: 'http',
//       host: 'locahost:8000',
//       path: '/dags',
//       // No need to manually encode the query parameters, the "Uri" class does it for us.
//       // queryParameters: {'type': activityType},
//     ),
//   );
//   return jsonDecode(response.body) as List<String>;
// }



final fetchDagsOptionsProvider = FutureProvider.autoDispose<List<DagOptions>>((ref) async {
  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
    final client = ref.watch(clientProvider);

  final response = await client.get(
    Uri.parse('http://localhost:8000/dags'),
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    
  );

  return (jsonDecode(response.body) as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((e) => DagOptions.fromJson(e))
      .toList(growable: false);
});
