// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphite/graphite.dart';
import 'package:thepipelinetool/custom_edges_page.dart';
import 'package:thepipelinetool/main.dart';

class CustomEdgesPageState extends State<CustomEdgesPage> {
  List<NodeInput> list = nodeInputFromJson(presetComplex);

  Map<String, bool> selected = {};
  void _onItemSelected(String nodeId) {
    setState(() {
      selected[nodeId] =
          selected[nodeId] == null || !selected[nodeId]! ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          // leading: const Icon(Icons.view_comfy),
          title: const Text('Custom Edges Example')),
      body: InteractiveViewer(
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
                  style: selected[node.id] ?? false
                      ? const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)
                      : const TextStyle(fontSize: 20.0),
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
            if ((selected[edge.from.id] ?? false) &&
                (selected[edge.to.id] ?? false)) {
              p.color = Colors.red;
            }
            return p;
          },
          onNodeTapDown: (_, node, __) {
            _onItemSelected(node.id);
          },
        ),
      ),
      // bottomNavigationBar: widget.bottomBar(context),
    );
  }
}

// Path customEdgePathBuilder(NodeInput from, NodeInput to,
//     List<List<double>> points, EdgeArrowType arrowType) {
//   var path = Path();
//   path.moveTo(points[0][0], points[0][1]);
//   points.sublist(1).forEach((p) {
//     path.lineTo(p[0], p[1]);
//   });
//   return path;
// }