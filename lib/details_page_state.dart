// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/details_page.dart';
import 'package:thepipelinetool/drawer/drawer.dart';
import 'package:thepipelinetool/views/graph_view.dart';
import 'package:thepipelinetool/views/task_view.dart';

const kMyToolbarHeight = 50.0;

final List<Tab> myTabs = ['Tasks', 'Graph']
    .map((e) => Tab(
            child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Align(
              alignment: Alignment.center,
              child: Text(
                e,
                style: const TextStyle(color: Colors.black),
              )),
        )))
    .toList();

class DetailsPageState extends ConsumerState<DetailsPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this, length: myTabs.length, animationDuration: Duration.zero);
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(toolbarHeight: kMyToolbarHeight, title: const MyAppBar()),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 70,
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    widget.dagName,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
                TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.only(right: 10),
                  // padding: EdgeInsets.symmetric(horizontal: 20),
                  isScrollable: true,
                  controller: _tabController,
                  tabs: myTabs,
                  indicator: BoxDecoration(
                      // shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20), // Creates border
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scaffold(
              key: _scaffoldKey,
              endDrawer: const Drawer(
                child: MyDrawer(),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  TaskView(
                    scaffoldKey: _scaffoldKey,
                    widget.dagName,
                  ),
                  GraphView(dagName: widget.dagName, scaffoldKey: _scaffoldKey),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
