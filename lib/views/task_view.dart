import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final fetchTasksProvider =
    FutureProvider.autoDispose.family<List<Map>, String>((ref, dagName) async {
  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: '/tasks/$dagName',
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>).cast<Map>();
});

class TaskView extends ConsumerWidget {
  final String dagName;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskView(this.dagName, {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(fetchTasksProvider(dagName));

    return CustomScrollView(slivers: [
      switch (userProvider) {
        // TODO: Handle this case.
        AsyncData(:final value) => SliverList.separated(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(value[index]["function_name"].toString());
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        AsyncError() => SliverList.list(
            children: const [Text('Oops, something unexpected happened')]),
        _ => SliverList.list(children: const [CircularProgressIndicator()]),
      }
    ]);
  }
}
