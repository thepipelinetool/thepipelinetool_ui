import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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

final fetchDagsProvider = FutureProvider<List<String>>((ref) async {
  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: '/dags',
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>).cast<String>();
});
