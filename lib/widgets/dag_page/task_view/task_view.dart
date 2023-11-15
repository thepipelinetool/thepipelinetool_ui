
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/providers/task_view/task_grid.dart';

import 'multiplication_table.dart';

class TaskView extends ConsumerStatefulWidget {
  // final Widget Function(BuildContext context) bottomBar;
  final String dagName;
  //final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskView(this.dagName,
      //  this.scaffoldKey,
      {Key? key})
      : super(key: key);
  @override
  TaskViewState createState() => TaskViewState();
}

class TaskViewState extends ConsumerState<TaskView>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // TaskViewState(this.dagName, {super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(taskGridProvider(widget.dagName));

    return switch (provider) {
      AsyncData(:final value) => FadeTransition(
          opacity: _animation,
          child: MultiplicationTable(
            tasks: value["tasks"],
            runs: value["runs"],
            dagName: widget.dagName,
            // scaffoldKey: widget.scaffoldKey,
          ),
        ),
      // CustomScrollView(slivers: [
      //     SliverList.separated(
      //       itemCount: value.length,
      //       itemBuilder: (BuildContext context, int index) {
      //         return Text(value[index]["function_name"].toString());
      //       },
      //       separatorBuilder: (BuildContext context, int index) =>
      //           const Divider(),
      //     )
      //   ]),
      AsyncError() => const Text('Oops, something unexpected happened'),
      _ => Container(),
      // const Center(child: CircularProgressIndicator()),
    };
  }
}
