// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import 'drawer.dart';

// class DrawScaffold extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _DrawScaffoldState();

// }

// class _DrawScaffoldState extends State<DrawScaffold>
//     with SingleTickerProviderStateMixin {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//                 key: _scaffoldKey,
//                 endDrawer: Drawer(
//                   child: MyDrawer(),
//                 ),
//                 body: TabBarView(controller: _tabController, children: [
//                   TaskView(scaffoldKey: _scaffoldKey, widget.dagName),
//                   GraphView(scaffoldKey: _scaffoldKey, widget.dagName),
//                 ]));
//   }

//     }