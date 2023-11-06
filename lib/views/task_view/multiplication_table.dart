import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'table_head.dart';
import 'table_body.dart';

class MultiplicationTable extends StatefulWidget {
  final String dagName;
  final List<Map<dynamic, dynamic>> tasks;
  final Map<String, dynamic> runs;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const MultiplicationTable(
      {super.key,
      required this.tasks,
      required this.runs,
      required this.dagName,
      // required this.scaffoldKey
      });
  @override
  MultiplicationTableState createState() => MultiplicationTableState();
}

class MultiplicationTableState extends State<MultiplicationTable> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _headController;
  late ScrollController _bodyController;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _headController = _controllers.addAndGet();
    _bodyController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _headController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableHead(
          scrollController: _headController,
          runs: widget.runs,
        ),
        Expanded(
          child: TableBody(
            scrollController: _bodyController,
            tasks: widget.tasks,
            runs: widget.runs,
            dagName: widget.dagName,
            // scaffoldKey: widget.scaffoldKey,
          ),
        ),
      ],
    );
  }
}
