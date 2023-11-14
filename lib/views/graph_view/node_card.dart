import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../task_view/table_cell.dart';
import 'graph_view.dart';

class NodeCard extends ConsumerWidget {
  final String dagName;
  // final String runId;
  final Map info;

  const NodeCard(
      {super.key,
      required this.dagName,
      // required this.runId,
      required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runId = ref.watch(selectedItemProvider(dagName));
    final tooltip = ref.watch(fetchTooltip);
    var vals = '';

    switch (tooltip) {
      case AsyncData(:final value):
        vals += value;
      // case AsyncError():
      //   ref.invalidate(fetchTooltip);

      // ref.invalidate(
      //     fetchTaskStatusProvider((dagName, runId, value["id"], true)));
      // return getStylingForGridStatus(value["status"]);
    }

    var color = Colors.grey.shade400;

    if (runId != "default") {
      // print((dagName.runtimeType, runId.runtimeType, info["id"].runtimeType));
      final taskStatus = ref.watch(fetchTaskStatusProvider(
          (dagName, runId, int.parse(info["id"]), true)));

      switch (taskStatus) {
        case AsyncData(:final value):
          color = getStylingForGridStatus(value);
        // return getStylingForGridStatus(value["status"]);
      }
    }

    return
        // Card(
        //   clipBehavior: Clip.hardEdge,
        //   child:
        MouseRegion(
      onEnter: (_) {
        // print(1);
        ref
            .read(hoveredTooltipProvider.notifier)
            .change((dagName, runId, info["id"].toString()));
      },
      cursor: SystemMouseCursors.click,
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 4.0,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4)),
          child: vals.isEmpty
              ? Center(
                  child: Text(
                    info["name"],
                    style: const TextStyle(fontSize: 20.0),
                  ),
                )
              : Tooltip(
                  // height: vals.isEmpty ? 0 : null,
                  // message: 'I am a Tooltip',
                  richMessage: TextSpan(
                    // text: 'I am a rich tooltip. ',
                    // text: '${value["function_name"]}_${value["id"]}\n$vals',
                    // style: TextStyle(color: Colors.red),
                    children: <InlineSpan>[
                      TextSpan(
                        text: "${info["name"]}\n",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "${vals}",
                        // style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // onTriggered: () {
                  // },
                  preferBelow: false,
                  verticalOffset: outerCellHeight,
                  showDuration: Duration.zero,
                  child: Center(
                    child: Text(
                      info["name"],
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                )),
    );
  }
}
