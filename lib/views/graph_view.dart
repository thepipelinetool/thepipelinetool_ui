import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphite/graphite.dart';
import 'package:http/http.dart' as http;

import '../drawer/drawer.dart';
// import '../main.dart';

final fetchGraphProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, (String, String)>((ref, args) async {
  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
  final dagName = args.$1;
  final runId = args.$2;

  var path = '/graph/$dagName/$runId';

  if (runId == "default") {
    path = '/default_graph/$dagName';
  }

  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: path,
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
});

// const presetComplex = '['
//     '{"id":"A","next":[{"outcome":"B","type":"one"}]},'
//     '{"id":"U","next":[{"outcome":"G","type":"one"}]},'
//     '{"id":"B","next":[{"outcome":"C","type":"one"},{"outcome":"D","type":"one"},{"outcome":"E","type":"one"},{"outcome":"F","type":"one"},{"outcome":"M","type":"one"}]},'
//     '{"id":"C","next":[{"outcome":"G","type":"one"}]},'
//     '{"id":"D","next":[{"outcome":"H","type":"one"}]},'
//     '{"id":"E","next":[{"outcome":"H","type":"one"}]},'
//     '{"id":"F","next":[{"outcome":"W","type":"one"},{"outcome":"N","type":"one"},{"outcome":"O","type":"one"}]},'
//     '{"id":"W","next":[]},'
//     '{"id":"N","next":[{"outcome":"I","type":"one"}]},'
//     '{"id":"O","next":[{"outcome":"P","type":"one"}]},'
//     '{"id":"P","next":[{"outcome":"I","type":"one"}]},'
//     '{"id":"M","next":[{"outcome":"L","type":"one"}]},'
//     '{"id":"G","next":[{"outcome":"I","type":"one"}]},'
//     '{"id":"H","next":[{"outcome":"J","type":"one"}]},'
//     '{"id":"I","next":[]},'
//     '{"id":"J","next":[{"outcome":"K","type":"one"}]},'
//     '{"id":"K","next":[{"outcome":"L","type":"one"}]},'
//     '{"id":"L","next":[]}'
//     ']';

// final appStateProvider2 =
//     StateNotifierProvider<AppStateNotifier2, String>((ref) {
//   return AppStateNotifier2();
// });

// class AppStateNotifier2 extends StateNotifier<String> {
//   AppStateNotifier2() : super('Initial Data');

//   void updateData(String newData) {
//     state = newData;
//   }
// }

class GraphView extends ConsumerWidget {
  final String dagName;
  final String runId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const GraphView(this.dagName, this.runId,
      {super.key, required this.scaffoldKey});

  // Map<String, bool> selected = {};
  // void _onItemSelected(String nodeId) {
  //   // setState(() {
  //   //   selected[nodeId] =
  //   //       selected[nodeId] == null || !selected[nodeId]! ? true : false;

  //   // });
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graph = ref.watch(fetchGraphProvider((dagName, runId)));

    // return switch(graph) {

    //   // TODO: Handle this case.
    //   AsyncData(:final value) => (){
    //     Container()
    //   }(),
    // };

    return switch (graph) {
      // TODO: Handle this case.
      AsyncData(:final value) => () {
          final list = value.map((m) => NodeInput.fromJson(m)).toList();

          return InteractiveViewer(
            minScale: 0.3,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            constrained: false,
            child: DirectGraph(
              list: list,
              defaultCellSize: const Size(104.0, 104.0 / 2),
              cellPadding: const EdgeInsets.all(14),
              contactEdgesDistance: 5.0,
              orientation: MatrixOrientation.Horizontal,
              // pathBuilder: customEdgePathBuilder,
              centered: true,
              onEdgeTapDown: (details, edge) {
                print("${edge.from.id}->${edge.to.id}");
              },
              nodeBuilder: (ctx, node) {
                return Card(
                  child: Center(
                    child: Text(
                      node.id,
                      style:
                          // selected[node.id] ?? false
                          //     ? const TextStyle(
                          //         fontSize: 20.0,
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.red)
                          //     :
                          const TextStyle(fontSize: 20.0),
                    ),
                  ),
                );
              },
              paintBuilder: (edge) {
                var p = Paint()
                  ..color = Colors.blueGrey
                  ..style = PaintingStyle.stroke
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round
                  ..strokeWidth = 2;
                // if ((selected[edge.from.id] ?? false) &&
                //     (selected[edge.to.id] ?? false)) {
                //   p.color = Colors.red;
                // }
                return p;
              },
              onNodeTapDown: (_, node, __) {
                ref.read(selectedTaskProvider.notifier).updateData(node.id);
                scaffoldKey.currentState!.openEndDrawer();

                // _onItemSelected(node.id);
              },
            ),
          );
        }(),
      AsyncError() => Text('Oops, something unexpected happened'),
      _ => Center(child:CircularProgressIndicator()),
    };

    // final list = graph.map(data: data, error: error, loading: loading)

// List<NodeInput> list = nodeInputFromJson(presetComplex);
  }
}
