import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:thepipelinetool/views/task_view/constants.dart';
import 'package:retry/retry.dart';

import '../../drawer/drawer.dart';


const double outerCellHeight = 16;
const double cellWidth = 10;
const double firstCellWidth = 100;

final clientProvider = StateProvider.autoDispose<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

final fetchTaskStatusProvider = FutureProvider.autoDispose
    .family<TaskStatus, (String?, String?, int?, bool)>((ref, args) async {
  // final runId = ref.watch(selectedItemProvider(dagName));

  final (dagName, runId, taskId, refresh) = args;

  var path = '/task_status/$runId/$taskId';
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
      final response2 =
          await client.get(Uri.parse('http://localhost:8000$path'));
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
    TaskStatus.None => Colors.transparent,
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

    final tooltip = ref.watch(fetchTooltip);

    // final vals = <String>[];
    var vals = '';

    var color = Colors.transparent;

    switch (taskStatus) {
      case AsyncData(:final value):
        color = getStylingForGridStatus(value);
      case AsyncError():
        ref.invalidate(
            fetchTaskStatusProvider((dagName, runId, value["id"], true)));
      // return getStylingForGridStatus(value["status"]);
    }

        switch (tooltip) {
      case AsyncData(:final value):
        vals += value;
      // case AsyncError():
      //   ref.invalidate(fetchTooltip);

        // ref.invalidate(
        //     fetchTaskStatusProvider((dagName, runId, value["id"], true)));
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
          top: BorderSide(width: .0, color: Colors.transparent),
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
          onEnter: (_) {

                // print(1);
                ref.read(hoveredTooltipProvider.notifier).change((dagName, runId, value["id"].toString()));
          },
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // print(runId);
              // print(value);
              ref.read(selectedTaskProvider.notifier).updateData(SelectedTask(
                  runId: runId,
                  taskId: value["id"].toString(),
                  dagName: dagName));
              // ref.invalidate(fetchTaskStatusProvider(
              //     (dagName, runId, value["id"], false)));
              Scaffold.of(context).openEndDrawer();

              // scaffoldKey.currentState!.openEndDrawer();
            },
            child: 
            vals.isEmpty ? Container(
                width: cellWidth,
                height: cellWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ) :
            Tooltip(
              // height: vals.isEmpty ? 0 : null,
              // message: 'I am a Tooltip',
              richMessage: TextSpan(
                // text: 'I am a rich tooltip. ',
                // text: '${value["function_name"]}_${value["id"]}\n$vals',
                // style: TextStyle(color: Colors.red),
                children: <InlineSpan>[
                   TextSpan(
                    text: "${value["function_name"]}_${value["id"]}\n",
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

final fetchTooltip = FutureProvider.autoDispose<String>((ref) async {
  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
  final client = ref.watch(clientProvider);
  final hovered = ref.watch(hoveredTooltipProvider);

  if (hovered == null) {
    return '';
  }

  // final response = await client.get(
  //   Uri.parse(
  //       'http://localhost:8000/task/${hovered.$1}/${hovered.$2}/${hovered.$3}'),
  //   // No need to manually encode the query parameters, the "Uri" class does it for us.
  //   // queryParameters: {'type': activityType},
  // );
  final response2 = await retry(
    // Make a GET request
    () async => await client.get(Uri.parse(
        'http://localhost:8000/task_status/${hovered.$2}/${hovered.$3}')),
    // Retry on SocketException or TimeoutException
    retryIf: (e) => e is SocketException || e is TimeoutException,
  );
  // final response = ;
  ref.keepAlive();
  final map = response2.bodyBytes.first.toTaskStatus();

  var res = '';

  res += 'Status: ${map.toString()}\n';

  if (!{TaskStatus.Pending, TaskStatus.Running, TaskStatus.Retrying}
      .contains(map)) {
    final response3 = await client.get(
      Uri.parse(
        // TODO use task result info? we dont use the actual result here, only info
          'http://localhost:8000/task_result/${hovered.$2}/${hovered.$3}'),
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    );
    final result  = jsonDecode(response3.body);
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

final hoveredTooltipProvider =
    StateNotifierProvider<HoveredTooltip, (String, String, String)?>((ref) {
  return HoveredTooltip();
});

class HoveredTooltip extends StateNotifier<(String, String, String)?> {
  HoveredTooltip() : super(null);

  void change((String, String, String) text) => state = text;
}
