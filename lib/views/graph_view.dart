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
    AsyncData(:final value) => value.isNotEmpty ? value.first : 'default',
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

  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: path,
    ),
  );

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
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: '/runs/$dagName',
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>)
      .cast<int>()
      .map((i) => i.toString())
      .toList()
    ..add('default');
});

class GraphView extends ConsumerWidget {
  final String dagName;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const GraphView(this.dagName, {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(fetchRunsProvider(dagName));
    final graph = ref.watch(fetchGraphProvider(dagName));

    return Column(children: [
      Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton<String>(
            value: ref.watch(selectedItemProvider(dagName)),
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
              ref.read(selectedItemProvider(dagName).notifier).state =
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
                  return Card(
                    child: Center(
                      child: Text(
                        node.id,
                        style: const TextStyle(fontSize: 20.0),
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
                onNodeTapDown: (_, node, __) {
                  ref.read(selectedTaskProvider.notifier).updateData(node.id);
                  scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            );
          }(),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => const Center(child: CircularProgressIndicator())
      })
    ]);
  }
}
