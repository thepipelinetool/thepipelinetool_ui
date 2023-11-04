// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphite/graphite.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/details_page.dart';
import 'package:thepipelinetool/drawer/drawer.dart';
import 'package:thepipelinetool/main.dart';
import 'package:thepipelinetool/views/graph_view.dart';
import 'package:thepipelinetool/views/task_view.dart';

const kMyToolbarHeight = 50.0;

class DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Tab> myTabs = ['Tasks', 'Graph']
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

  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          toolbarHeight: kMyToolbarHeight,
          // leading: const Icon(Icons.view_comfy),
          title: MyAppBar()),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 70,
              child: Row(children: [
                // Align(
                //     alignment: Alignment.centerLeft,
                //     child:
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      widget.dagName,
                      style: TextStyle(fontSize: 25),
                    )),
                Expanded(
                    child: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: EdgeInsets.only(right: 10),
                  // padding: EdgeInsets.symmetric(horizontal: 20),
                  isScrollable: true,
                  controller: _tabController,
                  tabs: myTabs,
                  indicator: BoxDecoration(
                      // shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20), // Creates border
                      color: Colors.white),
                ))
              ])),
          Expanded(
            child: Scaffold(
                key: _scaffoldKey,
                endDrawer: Drawer(
                  child: MyDrawer(),
                ),
                body: TabBarView(controller: _tabController, children: [
                  TaskView(scaffoldKey: _scaffoldKey, widget.dagName),
                  GraphView(scaffoldKey: _scaffoldKey,),
                ])),
          )
        ],
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
