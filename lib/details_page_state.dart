// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphite/graphite.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/details_page.dart';
import 'package:thepipelinetool/drawer/drawer.dart';
import 'package:thepipelinetool/main.dart';
import 'package:thepipelinetool/views/graph_view.dart';
import 'package:thepipelinetool/views/task_view.dart';
import 'package:http/http.dart' as http;

const kMyToolbarHeight = 50.0;

final fetchRunsProvider = FutureProvider.family.autoDispose<List<String>, String>((ref, dagName) async {
  // final selected = ref.watch(selectedItemProvider);

  //  return switch (selectedProvider) {
  //     AsyncData(:final value) => () async {
  final response = await http.get(
    Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8000,
      path: '/runs/$dagName',
      // No need to manually encode the query parameters, the "Uri" class does it for us.
      // queryParameters: {'type': activityType},
    ),
  );

  return (jsonDecode(response.body) as List<dynamic>)
      .cast<int>()
      .map((i) => i.toString())
      .toList()
    ..insert(0, 'default');

  //     }()
  //  };

  // final json = await http.get('api/user/$userId');
  // return User.fromJson(json);
});

// final tabControllerProvider = StateProvider.autoDispose<TabController>((ref) {
//   final tabController = TabController(
//       vsync: NavigatorState(),
//       length: myTabs.length,
//       animationDuration: Duration.zero);
//   ref.onDispose(() => tabController.dispose());

//   return tabController; // Start with no item selected.
// });

// final fetchRunsProvider = FutureProvider.autoDispose
//     .family<List<String>, String>((ref) async {

//       final selected = ref.watch(selectedItemProvider);

//   // final json = await http.get('api/user/$userId');
//   // return User.fromJson(json);
//   final response = await http.get(
//     Uri(
//       scheme: 'http',
//       host: 'localhost',
//       port: 8000,
//       path: '/runs/$selected',
//       // No need to manually encode the query parameters, the "Uri" class does it for us.
//       // queryParameters: {'type': activityType},
//     ),
//   );

//   return (jsonDecode(response.body) as List<dynamic>)
//       .cast<int>()
//       .map((i) => i.toString())
//       .toList()
//     ..insert(0, 'default');
// });
final List<Tab> myTabs = ['Tasks', 'Graph']
    .map((e) => Tab(
            child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 20, right: 20),
          // decoration: BoxDecoration(
          //     // color: Colors.white,
          //     borderRadius: BorderRadius.circular(50),
          //     border: Border.all(color: Colors.black, width: 1)),
          child: Align(
              alignment: Alignment.center,
              child: Text(
                e,
                style: TextStyle(color: Colors.black),
              )),
        )))
    .toList();
// final tabControllerProvider = StateProvider.autoDispose<TabController>((ref) {
//   final tabController = TabController(
//       vsync: NavigatorState(),
//       length: myTabs.length,
//       animationDuration: Duration.zero);
//   ref.onDispose(() => tabController.dispose());

//   return tabController; // Start with no item selected.
// });

class DetailsPageState extends ConsumerState<DetailsPage>
    with SingleTickerProviderStateMixin {
  // final String dagName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //   ,
  //   Tab(
  //       child: Container(
  //     height: 40,
  //     padding: EdgeInsets.only(left: 20, right: 20),
  //     // decoration: BoxDecoration(
  //     //     // color: Colors.white,
  //     //     borderRadius: BorderRadius.circular(50),
  //     //     border: Border.all(color: Colors.black, width: 1)),
  //     child: Align(
  //         alignment: Alignment.center,
  //         child: Text('Overall', style: TextStyle(color: Colors.black))),
  //   )),
  // ];

  // DetailsPageState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this, length: myTabs.length, animationDuration: Duration.zero);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  late  TabController _tabController;
  // final TabController _tabController = TabController(
  //   vsync: NavigatorState(),
  //   length: 2,
  // );
  @override
  Widget build(BuildContext context) {
    final runsProvider = ref.watch(fetchRunsProvider(widget.dagName));

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
            toolbarHeight: kMyToolbarHeight,
            // leading: const Icon(Icons.view_comfy),
            title: MyAppBar()),
        body: switch (runsProvider) {
          AsyncData(:final value) => Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 70,
                    child: Row(children: [
                      // Align(
                      //     alignment: Alignment.centerLeft,
                      //     child:
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            widget.dagName,
                            style: TextStyle(fontSize: 25),
                          )),
                      DropdownButton<String>(
                        value: ref.watch(selectedItemProvider),
                        items:
                            value.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // When the user selects an item, update the state provider.
                          ref.read(selectedItemProvider.notifier).state =
                              newValue!;
                        },
                      ),
                      // Expanded(
                      //     child: 
                          TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        labelPadding: EdgeInsets.only(right: 10),
                        // padding: EdgeInsets.symmetric(horizontal: 20),
                        isScrollable: true,
                        controller: _tabController,
                        tabs: myTabs,
                        indicator: BoxDecoration(
                            // shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.circular(20), // Creates border
                            color: Colors.white),
                      )
                    ])),
                Expanded(
                  child: Scaffold(
                      key: _scaffoldKey,
                      endDrawer: Drawer(
                        child: MyDrawer(),
                      ),
                      body: TabBarView(controller: _tabController, children: [
                        TaskView(scaffoldKey: _scaffoldKey, widget.dagName),
                        GraphView(
                            scaffoldKey: _scaffoldKey,
                            widget.dagName,
                            ref.watch(selectedItemProvider)),
                      ])),
                )
              ],
            ),
          AsyncError() => Text("error"),
          _ => CircularProgressIndicator(),
        }

        // bottomNavigationBar: widget.bottomBar(context),
        );
  }
}

// class MyDropdownWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch the dropdown items and the selected item.
//     final dropdownItems = ref.watch(fetchRunsProvider);
//     final selectedItem = ref.watch(selectedItemProvider);

//     return;
//   }
// }

final selectedItemProvider = StateProvider<String>((ref) {
  return 'default'; // Start with no item selected.
});

// Path customEdgePathBuilder(NodeInput from, NodeInput to,
//     List<List<double>> points, EdgeArrowType arrowType) {
//   var path = Path();
//   path.moveTo(points[0][0], points[0][1]);
//   points.sublist(1).forEach((p) {
//     path.lineTo(p[0], p[1]);
//   });
//   return path;
// }
