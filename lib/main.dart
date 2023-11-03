// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphite/graphite.dart';
import 'package:thepipelinetool/custom_edges_page.dart';

import 'homescreen.dart';

/// This sample app shows an app with two screens.
///
/// The first route '/' is mapped to [HomeScreen], and the second route
/// '/details' is mapped to [DetailsScreen].
///
/// The buttons use context.go() to navigate to each destination. On mobile
/// devices, each destination is deep-linkable and on the web, can be navigated
/// to using the address bar.
void main() => runApp(const ProviderScope(child: MyApp()));

CustomTransitionPage<void> pageBuilder(
    BuildContext context, GoRouterState state, Widget widget) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: widget,
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
      // builder: (BuildContext context, GoRouterState state) {
      //   return HomeScreen();
      // },
      routes: <RouteBase>[
        GoRoute(
          name: 'dag',
          path: 'dag/:dag_name',
          pageBuilder: (BuildContext context, GoRouterState state) => pageBuilder(context, state, CustomEdgesPage(dagName: state.pathParameters['dag_name']!)),
        ),
      ],
      pageBuilder: (BuildContext context, GoRouterState state) => pageBuilder(context, state, HomeScreen()),
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
      debugShowCheckedModeBanner: false,
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
