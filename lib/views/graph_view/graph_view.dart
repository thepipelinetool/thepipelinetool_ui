import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphite/graphite.dart';

import '../../drawer/drawer.dart';
import '../task_view/table_cell.dart';
import 'node_card.dart';
// import '../main.dart';

// extension CacheForExtension on AutoDisposeRef<Object?> {
//   /// Keeps the provider alive for [duration].
//   void cacheFor(Duration duration) {
//     // Immediately prevent the state from getting destroyed.
//     final link = keepAlive();
//     // After duration has elapsed, we re-enable automatic disposal.
//     final timer = Timer(duration, link.close);

//     // Optional: when the provider is recomputed (such as with ref.watch),
//     // we cancel the pending timer.
//     onDispose(timer.cancel);
//   }
// }

final selectedItemProvider =
    StateProvider.family.autoDispose<String, String>((ref, dagName) {
  final runs = ref.watch(fetchRunsProvider(dagName));

  return switch (runs) {
    AsyncData(:final value) => value.first,
    (_) => 'default'
  };
});

final fetchGraphProvider = FutureProvider.autoDispose
    .family<(List<Map<String, dynamic>>, String), String>((ref, dagName) async {
  final runId = ref.watch(selectedItemProvider(dagName));

  var path = '/graph/$runId';

  if (runId == "default") {
    path = '/default_graph/$dagName';
  }
  final client = ref.watch(clientProvider);

  // final client = http.Client();
  // ref.onDispose(client.close);
  final response = await client.get(Uri.parse('http://localhost:8000$path'));
  ref.keepAlive();

  final map = (await compute(jsonDecode, response.body) as List<dynamic>)
      .cast<Map<String, dynamic>>();
  // print(runId);
  // print(runId != "default");
  if (runId != "default" &&
      map.any(
          (m) => {"Pending", "Running", "Retrying"}.contains(m['status']))) {
    Future.delayed(const Duration(seconds: 3), () {
      // print('refresh');
      ref.invalidateSelf();
    });
  }

  return (map, runId);
});

// "Pending" => Colors.grey,
// "Success" => Colors.green,
// "Failure" => Colors.red,
// "Running" => HexColor.fromHex("#90EE90"),
// "Retrying" => Colors.orange,
// "Skipped" => Colors.pink,

final fetchRunsProvider = FutureProvider.family
    .autoDispose<List<String>, String>((ref, dagName) async {
        final client = ref.watch(clientProvider);

  final response = await client.get(
    Uri.parse('http://localhost:8000/runs/$dagName'),
  );

  return (await compute(jsonDecode, response.body) as List<dynamic>)
      .cast<int>()
      .map((i) => i.toString())
      .toList()
      .reversed
      .toList()
    ..add('default');
});

class GraphView extends ConsumerStatefulWidget {
  final String dagName;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const GraphView({super.key, required this.dagName});

  @override
  GraphViewState createState() => GraphViewState();


static final p = Paint()
  ..color = Colors.blueGrey
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..strokeWidth = 2;

}

class GraphViewState extends ConsumerState<GraphView>


    with TickerProviderStateMixin {
  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();

    super.dispose();
  }
  // GraphViewState(this.dagName, {required this.scaffoldKey});

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  late final AnimationController _controller2 = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> _animation2 = CurvedAnimation(
    parent: _controller2,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(fetchRunsProvider(widget.dagName));
    final graph = ref.watch(fetchGraphProvider(widget.dagName));

    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: ref.watch(selectedItemProvider(widget.dagName)),
                items: (switch (runs) {
                  AsyncData(:final value) => value,
                  (_) => ['default']
                })
                    .map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  ref
                      .read(selectedItemProvider(widget.dagName).notifier)
                      .state = newValue!;
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              )),
          Expanded(
              child: switch (graph) {
            AsyncData(:final value) => () {
                final (graph, runId) = value;

                final list = graph.map((m) => NodeInput.fromJson(m)).toList();

                final map = {};
                for (final json in graph) {
                  map[json["id"]] = json;
                }

                return FadeTransition(
                  opacity: _animation2,
                  child: InteractiveViewer(
                    minScale: 0.3,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    constrained: false,
                    child: DirectGraph(
                      list: list,
                      defaultCellSize: const Size(154.0, 104.0 / 2),
                      cellPadding: const EdgeInsets.all(14),
                      contactEdgesDistance: 5.0,
                      orientation: MatrixOrientation.Horizontal,
                      centered: true,
                      onEdgeTapDown: (details, edge) {
                        // print("${edge.from.id}->${edge.to.id}");
                      },
                      nodeBuilder: (ctx, node) {
                        return NodeCard(
                              dagName: widget.dagName, info: map[node.id]
                        );
                      },
                      paintBuilder: (edge) {
                        return GraphView.p;
                      },
                      onNodeTapUp: (_, node, __) {
                        ref.read(selectedTaskProvider.notifier).updateData(
                            SelectedTask(runId: runId, taskId: node.id, dagName: widget.dagName));
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                );
              }(),
            AsyncError() => const Text('Oops, something unexpected happened'),
            _ => Container()
            // const Center(child: CircularProgressIndicator())
          })
        ],
      ),
    );
  }
}
