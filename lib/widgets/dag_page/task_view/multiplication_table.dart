import 'package:flutter/material.dart';

import 'table_body.dart';

class MultiplicationTable extends StatefulWidget {
  final String dagName;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> runs;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const MultiplicationTable({
    super.key,
    required this.tasks,
    required this.runs,
    required this.dagName,
    // required this.scaffoldKey
  });
  @override
  MultiplicationTableState createState() => MultiplicationTableState();
}

class MultiplicationTableState extends State<MultiplicationTable> {
  // late LinkedScrollControllerGroup _controllers;
  // late ScrollController _headController;
  // late ScrollController _bodyController;

  @override
  void initState() {
    super.initState();
    // _controllers = LinkedScrollControllerGroup();
    // _headController = _controllers.addAndGet();
    // _bodyController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    // _headController.dispose();
    // _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Column(
        //   children: [
        //     TableHead(
        //       scrollController: _headController,
        //       runs: widget.runs,
        //       tasks: widget.tasks,
        //     ),
        //     Expanded(
        //       child:

        TableBody(
      // scrollController: _bodyController,
      tasks: widget.tasks,
      runs: widget.runs,
      dagName: widget.dagName,
      // scaffoldKey: widget.scaffoldKey,
      // ),
      //   ),
      // ],
    );
  }
}
