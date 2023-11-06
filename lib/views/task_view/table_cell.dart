import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../drawer/drawer.dart';

const double cellHeight = 20;
const double firstCellWidth = 100;

final fetchTaskStatusProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String, int)>((ref, args) async {
  // final runId = ref.watch(selectedItemProvider(dagName));

  final (dagName, runId, taskId) = args;

  var path = '/task_status/$dagName/$runId/$taskId';

  final response = await http.get(Uri.parse('http://localhost:8000$path'));

  final map = jsonDecode(response.body) as Map<String, dynamic>;
  // print("map ${map}");

  if (map['status'] == "Pending") {
    Future.delayed(const Duration(seconds: 3), () {
      // print('refresh');
      ref.invalidateSelf();
    });
  }

  return map;
  // return {"status": "Pending"};
});

Color getStylingForGridStatus(String taskStatus) {
  return switch (taskStatus) {
    "Pending" => Colors.grey,
    "Success" => Colors.green,
    "Failure" => Colors.red,
    "Running" => HexColor.fromHex("#90EE90"),
    "Retrying" => Colors.orange,
    "Skipped" => Colors.pink,
    (_) => Colors.transparent,
  };
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class MultiplicationTableCell extends ConsumerWidget {
  final String dagName;
  final String runId;
  final Map value;
  // final Color color;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const MultiplicationTableCell({
    super.key,
    // required this.scaffoldKey,
    required this.value,
    required this.runId,
    required this.dagName,
    // required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskStatus =
        ref.watch(fetchTaskStatusProvider((dagName, runId, value["id"])));

    var color = Colors.transparent;

    switch (taskStatus) {
      case AsyncData(:final value):
        color = getStylingForGridStatus(value["status"]);
      // return getStylingForGridStatus(value["status"]);
    }

    return Container(
      width: cellHeight,
      height: cellHeight,
      // decoration: BoxDecoration(
      //   // color:
      //   //     // value["status"] == "Pending"
      //   //     //     ? switch (taskStatus) {
      //   //     //         AsyncData(:final value) => (){
      //   //     //           print(value);
      //   //     //           return Colors.red;
      //   //     //           return getStylingForGridStatus(value["status"]);}(),
      //   //     //         (_) => Colors.transparent,
      //   //     //       }
      //   //     //     : getStylingForGridStatus(value["status"]),

      //   //     Colors.red,
      //   border: Border.all(
      //     color: Colors.black12,
      //     width: 1.0,
      //   ),
      // ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // print(runId);
              // print(value);
              Scaffold.of(context).openEndDrawer();
              ref.read(selectedTaskProvider.notifier).updateData(
                  SelectedTask(runId: runId, taskId: value["id"].toString()));
              // scaffoldKey.currentState!.openEndDrawer();
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        // Text(
        //   '${value ?? ''}',
        //   style: TextStyle(fontSize: 16.0),
        // ),
      ),
    );
  }
}
