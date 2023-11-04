import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphite/graphite.dart';

import '../main.dart';

final appStateProvider = StateNotifierProvider<AppStateNotifier, String>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<String> {
  AppStateNotifier() : super('Initial Data');
  void updateData(String newData) {
    state = newData;
  }
  // void updateData(String newData) {
  //   state = state.copyWith(data: newData);
  // }
}

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
  List<NodeInput> list = nodeInputFromJson(presetComplex);

class GraphView extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  GraphView({super.key, required this.scaffoldKey});

  // Map<String, bool> selected = {};
  void _onItemSelected(String nodeId) {
    // setState(() {
    //   selected[nodeId] =
    //       selected[nodeId] == null || !selected[nodeId]! ? true : false;

    scaffoldKey.currentState!.openEndDrawer();
    // });
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ref.read(appStateProvider.notifier).updateData(node.id);
          _onItemSelected(node.id);
        },
      ),
    );
  }
}
