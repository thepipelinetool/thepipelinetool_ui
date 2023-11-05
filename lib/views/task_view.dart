import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:thepipelinetool/views/graph_view.dart';

final fetchTasksProvider = FutureProvider.autoDispose
    .family<List<Map>, String>((ref, dagName) async {
    final path = '/default_tasks/$dagName';

  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: path,
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>).cast<Map>();
});

class TaskView extends ConsumerWidget {
  final String dagName;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskView(this.dagName,
      {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(fetchTasksProvider((dagName)));
    ref.watch(fetchRunsProvider(dagName));

    return switch (userProvider) {
      AsyncData(:final value) => CustomScrollView(slivers: [
          SliverList.separated(
            itemCount: value.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(value[index]["function_name"].toString());
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          )
        ]),
      AsyncError() => const Text('Oops, something unexpected happened'),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
