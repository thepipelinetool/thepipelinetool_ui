// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/details_page.dart';
import 'package:thepipelinetool/drawer/drawer.dart';
import 'package:thepipelinetool/views/graph_view/graph_view.dart';

import 'views/task_view/task_view.dart';

const kMyToolbarHeight = 50.0;

final List<Tab> myTabs = ['Tasks', 'Graph']
    .map((e) => Tab(
            child: Container(
          // height: 40,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: 
          Center(
          //     // alignment: Alignment.center,
              child: 
              Text(
                e,
                textAlign: TextAlign.center,
                // style: const TextStyle(color: Colors.black),
              )
              ),
        )))
    .toList();

    const kHorizontalPadding = 20.0;

class DetailsPageState extends ConsumerState<DetailsPage>
    with SingleTickerProviderStateMixin {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      appBar: AppBar(scrolledUnderElevation: 0, elevation: 0 ,toolbarHeight: kMyToolbarHeight, title: const MyAppBar()),
      body: Scaffold(
        endDrawer: Container(
            width: 500,
            child: const Drawer(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
              child: MyDrawer(
                key: Key('Drawer'),
                // dagName: widget.dagName,
              ),
            )),
        body: Padding(padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),child: Column(
          children: [
            Container(
              // padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      widget.dagName,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                  Container(height: 30, child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                    // indicatorWeight: 0,
                    dividerColor: Colors.transparent,
                    // labelPadding: const EdgeInsets.only(right: 10),
                    // padding: EdgeInsets.symmetric(horizontal: 20),
                    isScrollable: true,
                    padding: const EdgeInsets.all(0),
                    

                    controller: _tabController,
                    tabs: myTabs,
                    indicator: 
                    BoxDecoration(
                        // shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.5),
                        //     spreadRadius: 5,
                        //     blurRadius: 7,
                        //     offset: Offset(0, 3), // changes position of shadow
                        //   ),
                        // ],
                        borderRadius:
                            BorderRadius.circular(20), // Creates border
                        // color: Colors.white
                        ),
                  ),)
                ],
              ),
            ),
            Expanded(
              child:
                  // Scaffold(
                  // key: _scaffoldKey,
                  // endDrawer: Drawer(
                  //   child: MyDrawer(
                  //     key: Key('Drawer'),
                  //     dagName: widget.dagName,
                  //   ),
                  // ),
                  // body:
                  TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  TaskView(
                    widget.dagName,
                    // _scaffoldKey,
                  ),
                  GraphView(
                    dagName: widget.dagName,
                    //  scaffoldKey: _scaffoldKey
                  ),
                ],
              ),
            ),
            // )
          ],
        ),)
      ),
    );
  }
}
