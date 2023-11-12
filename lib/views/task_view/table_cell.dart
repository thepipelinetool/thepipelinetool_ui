import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:thepipelinetool/views/task_view/constants.dart';
import 'package:retry/retry.dart';

import '../../drawer/drawer.dart';

import 'constants.dart';

const double outerCellHeight = 16;
const double cellWidth = 10;
const double firstCellWidth = 100;

final clientProvider = StateProvider.autoDispose<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

final fetchTaskStatusProvider = FutureProvider.autoDispose
    .family<TaskStatus, (String, String, int, bool)>((ref, args) async {
  // final runId = ref.watch(selectedItemProvider(dagName));

  final (dagName, runId, taskId, refresh) = args;

  var path = '/task_status/$dagName/$runId/$taskId';
  // final client = http.Client();
  // ref.onDispose(client.close);
  final client = ref.watch(clientProvider);

  final response = await retry(
    // Make a GET request
    () async => await client.get(Uri.parse('http://localhost:8000$path')),
    // Retry on SocketException or TimeoutException
    retryIf: (e) => e is SocketException || e is TimeoutException,
  );
  // final response = ;
  ref.keepAlive();
  final map = response.bodyBytes.first.toTaskStatus();
  // print('MAP $map');

  // final map = jsonDecode(response.) as Map<String, dynamic>;
  // print("map ${map}");

  if (refresh &&
      {TaskStatus.Pending, TaskStatus.Running, TaskStatus.Retrying}
          .contains(map)) {
    Timer.periodic(const Duration(seconds: 3), (t) async {
      final response2 = await client.get(Uri.parse('http://localhost:8000$path'));
      final map2 = response2.bodyBytes.first.toTaskStatus();
      // final map2 = jsonDecode(response2.body) as Map<String, dynamic>;
      if (map2 != map) {
        // print('refresh');
        t.cancel();
        ref.invalidateSelf();
      }
    });
  }

  return map;
  // return {"status": "Pending"};
});

Color getStylingForGridStatus(TaskStatus taskStatus) {
  return switch (taskStatus) {
    TaskStatus.Pending => Colors.grey,
    TaskStatus.Success => Colors.green,
    TaskStatus.Failure => Colors.red,
    TaskStatus.Running => HexColor.fromHex("#90EE90"),
    TaskStatus.Retrying => Colors.orange,
    TaskStatus.Skipped => Colors.pink,
    // (_) => Colors.transparent,
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
  // String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
  //     '${alpha.toRadixString(16).padLeft(2, '0')}'
  //     '${red.toRadixString(16).padLeft(2, '0')}'
  //     '${green.toRadixString(16).padLeft(2, '0')}'
  //     '${blue.toRadixString(16).padLeft(2, '0')}';
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
        ref.watch(fetchTaskStatusProvider((dagName, runId, value["id"], true)));

    var color = Colors.transparent;

    switch (taskStatus) {
      case AsyncData(:final value):
        color = getStylingForGridStatus(value);
      case AsyncError():
        ref.invalidate(
            fetchTaskStatusProvider((dagName, runId, value["id"], true)));
      // return getStylingForGridStatus(value["status"]);
    }

    return Container(
      width: outerCellHeight,
      height: outerCellHeight,
      decoration: BoxDecoration(
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
        // decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.transparent),
          bottom: BorderSide(width: 1.0, color: Colors.grey.withAlpha(80)),
        ),
      ),
      // ),
      alignment: Alignment.center,
      child:

          // Padding(
          //   padding: const EdgeInsets.all(2),
          // child:
          Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // print(runId);
              // print(value);
              ref.read(selectedTaskProvider.notifier).updateData(
                  SelectedTask(runId: runId, taskId: value["id"].toString()));
              // ref.invalidate(fetchTaskStatusProvider(
              //     (dagName, runId, value["id"], false)));
              Scaffold.of(context).openEndDrawer();

              // scaffoldKey.currentState!.openEndDrawer();
            },
            child: Tooltip(
              message: 'I am a Tooltip',
              preferBelow: false,
              verticalOffset: outerCellHeight / 2,
              showDuration: Duration.zero,
              child: Container(
                width: cellWidth,
                height: cellWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
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
