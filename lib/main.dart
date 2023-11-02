// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphite/graphite.dart';

import 'homescreen.dart';

/// This sample app shows an app with two screens.
///
/// The first route '/' is mapped to [HomeScreen], and the second route
/// '/details' is mapped to [DetailsScreen].
///
/// The buttons use context.go() to navigate to each destination. On mobile
/// devices, each destination is deep-linkable and on the web, can be navigated
/// to using the address bar.
void main() => runApp(const MyApp());

CustomTransitionPage<void> pageBuilder(
    BuildContext context, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: const CustomEdgesPage(),
    transitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      // Change the opacity of the screen using a Curve based on the the animation's
      // value
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          pageBuilder: pageBuilder,
        ),
      ],
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}


const presetComplex = '['
    '{"id":"A","next":[{"outcome":"B","type":"one"}]},'
    '{"id":"U","next":[{"outcome":"G","type":"one"}]},'
    '{"id":"B","next":[{"outcome":"C","type":"one"},{"outcome":"D","type":"one"},{"outcome":"E","type":"one"},{"outcome":"F","type":"one"},{"outcome":"M","type":"one"}]},'
    '{"id":"C","next":[{"outcome":"G","type":"one"}]},'
    '{"id":"D","next":[{"outcome":"H","type":"one"}]},'
    '{"id":"E","next":[{"outcome":"H","type":"one"}]},'
    '{"id":"F","next":[{"outcome":"W","type":"one"},{"outcome":"N","type":"one"},{"outcome":"O","type":"one"}]},'
    '{"id":"W","next":[]},'
    '{"id":"N","next":[{"outcome":"I","type":"one"}]},'
    '{"id":"O","next":[{"outcome":"P","type":"one"}]},'
    '{"id":"P","next":[{"outcome":"I","type":"one"}]},'
    '{"id":"M","next":[{"outcome":"L","type":"one"}]},'
    '{"id":"G","next":[{"outcome":"I","type":"one"}]},'
    '{"id":"H","next":[{"outcome":"J","type":"one"}]},'
    '{"id":"I","next":[]},'
    '{"id":"J","next":[{"outcome":"K","type":"one"}]},'
    '{"id":"K","next":[{"outcome":"L","type":"one"}]},'
    '{"id":"L","next":[]}'
    ']';

class CustomEdgesPage extends StatefulWidget {
  // final Widget Function(BuildContext context) bottomBar;

  const CustomEdgesPage({Key? key}) : super(key: key);
  @override
  CustomEdgesPageState createState() {
    return CustomEdgesPageState();
  }
}

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
        // minScale: 0.01,
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