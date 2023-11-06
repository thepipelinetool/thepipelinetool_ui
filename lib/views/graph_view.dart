import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphite/graphite.dart';
import 'package:http/http.dart' as http;

import '../drawer/drawer.dart';
// import '../main.dart';

extension CacheForExtension on AutoDisposeRef<Object?> {
  /// Keeps the provider alive for [duration].
  void cacheFor(Duration duration) {
    // Immediately prevent the state from getting destroyed.
    final link = keepAlive();
    // After duration has elapsed, we re-enable automatic disposal.
    final timer = Timer(duration, link.close);

    // Optional: when the provider is recomputed (such as with ref.watch),
    // we cancel the pending timer.
    onDispose(timer.cancel);
  }
}

final selectedItemProvider =
    StateProvider.family.autoDispose<String, String>((ref, dagName) {
  final runs = ref.watch(fetchRunsProvider(dagName));

  return switch (runs) {
    AsyncData(:final value) =>  value.first,
    (_) => 'default'
  };
});

final fetchGraphProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, dagName) async {
  final runId = ref.watch(selectedItemProvider(dagName));

  var path = '/graph/$dagName/$runId';

  if (runId == "default") {
    path = '/default_graph/$dagName';
  }

  final response = await http.get(Uri.parse('http://localhost:8000$path'));

  final map =
      (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();

  if (runId != "default" && map.any((m) => m['status'] == "Pending")) {
    Future.delayed(const Duration(seconds: 3), () {
      print('refresh');
      ref.invalidateSelf();
    });
  }

  return map;
});

final fetchRunsProvider = FutureProvider.family
    .autoDispose<List<String>, String>((ref, dagName) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/runs/$dagName'),
  );

  return (jsonDecode(response.body) as List<dynamic>)
      .cast<int>()
      .map((i) => i.toString())
      .toList()..add('default');
});

class GraphView extends ConsumerStatefulWidget {
  final String dagName;
  final GlobalKey<ScaffoldState> scaffoldKey;

  GraphView({super.key, required this.dagName, required this.scaffoldKey});

  @override
  GraphViewState createState() => GraphViewState();
}

class GraphViewState extends ConsumerState<GraphView>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // GraphViewState(this.dagName, {required this.scaffoldKey});

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(fetchRunsProvider(widget.dagName));
    final graph = ref.watch(fetchGraphProvider(widget.dagName));

    return Column(children: [
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
              ref.read(selectedItemProvider(widget.dagName).notifier).state =
                  newValue!;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )),
      Expanded(
          child: switch (graph) {
        AsyncData(:final value) => () {
            final list = value.map((m) => NodeInput.fromJson(m)).toList();

            return InteractiveViewer(
              minScale: 0.3,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              constrained: false,
              child: FadeTransition(
                opacity: _animation,
                child: DirectGraph(
                  list: list,
                  defaultCellSize: const Size(104.0, 104.0 / 2),
                  cellPadding: const EdgeInsets.all(14),
                  contactEdgesDistance: 5.0,
                  orientation: MatrixOrientation.Horizontal,
                  centered: true,
                  onEdgeTapDown: (details, edge) {
                    print("${edge.from.id}->${edge.to.id}");
                  },
                  nodeBuilder: (ctx, node) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Card(
                        child: Center(
                          child: Text(
                            node.id,
                            style: const TextStyle(fontSize: 20.0),
                          ),
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
                    return p;
                  },
                  onNodeTapUp: (_, node, __) {
                    ref.read(selectedTaskProvider.notifier).updateData(node.id);
                    widget.scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
              ),
            );
          }(),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => Container()
        // const Center(child: CircularProgressIndicator())
      })
    ]);
  }
}
