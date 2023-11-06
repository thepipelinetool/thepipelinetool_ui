import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../task_view/table_cell.dart';
import 'graph_view.dart';

class NodeCard extends ConsumerWidget {
  final String dagName;
  // final String runId;
  final Map info;

  NodeCard(
      {super.key,
      required this.dagName,
      // required this.runId,
      required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runId = ref.watch(selectedItemProvider(dagName));
    var color = Colors.grey.shade400;

    if (runId != "default") {
      // print((dagName.runtimeType, runId.runtimeType, info["id"].runtimeType));
      final taskStatus =
          ref.watch(fetchTaskStatusProvider((dagName, runId, int.parse(info["id"]))));

      switch (taskStatus) {
        case AsyncData(:final value):
          color = getStylingForGridStatus(value["status"]);
        // return getStylingForGridStatus(value["status"]);
      }
    }

    return 
    // Card(
    //   clipBehavior: Clip.hardEdge,
    //   child: 
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 4.0,
            
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Center(
          child: Text(
            info["name"],
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      // ),
    );
  }
}
