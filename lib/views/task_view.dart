import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskView extends StatelessWidget {
    final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskView({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Text('Task View');
  }

}