import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/providers/drawer/task_info.dart';

import '../dag_page/dag_page.dart';

JsonEncoder encoder = const JsonEncoder.withIndent('  ');
String prettyprint = encoder.convert(json);

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  MyDrawerState createState() => MyDrawerState();
}

class MyDrawerState extends ConsumerState<MyDrawer> with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    // final appState = ref.watch(selectedTaskProvider);

    final task = ref.watch(taskInfoProvider);

    return switch (task) {
      AsyncData(value: final value) => FadeTransition(
          // key: const Key('key'),
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(children: [
                  SizedBox(
                      key: Key("${value["function_name"]}_${value["id"]}"),
                      height: 50,
                      child: Text("${value["function_name"]}_${value["id"]}")),
                  const Spacer(),
                  // TODO
                  // SizedBox(height: 50, child: Text(status.toString())),
                ]),
                Expanded(
                  child: SingleChildScrollView(
                    child: ExpansionPanelList.radio(
                      // materialGapSize: 0,
                      // dividerColor: Colors.transparent,
                      elevation: 0,
                      children: [
                        ExpansionPanelRadio(
                            // backgroundColor: Colors.transparent,
                            canTapOnHeader: true,
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return const ListTile(
                                // tileColor: Theme.of(context).primaryColor,

                                // style: ListTileStyle.list,
                                title: Text('Args'),
                              );
                            },
                            // body: v["template_args"] == null ? Container() : Container(width: 400, child: jsonView(v["template_args"], false)),
                            body: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: kHorizontalPadding, right: kHorizontalPadding, bottom: kHorizontalPadding),
                                  child: Text(encoder.convert(value["template_args"])),
                                )),
                            value: 'Args'),
                        // if (v.containsKey("results"))
                        ExpansionPanelRadio(
                            // backgroundColor: Colors.transparent,

                            canTapOnHeader: true,
                            headerBuilder: (BuildContext context, bool isExpanded) =>
                                const ListTile(title: Text('Attempts')),
                            body: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: kHorizontalPadding, right: kHorizontalPadding, bottom: kHorizontalPadding),
                                child: const Text(""),
                              ),
                            ),
                            value: 'Attempts')
                      ],
                    ),
                    // Text(encoder.convert(v))
                  ),
                )
              ],
            ),
          ),

          // print(value);
          // return Text(value.toString());
        ),
      // ),
      (_) => Container(
          // color: Colors.red,
          )
    };

    // return Text(appState);
    // return Text("test");
  }
}

// Widget jsonView(Object o, bool inner) {
//   var items = <Widget>[];
//   if (o is List) {
//     items = o.map((e) => Text(e.toString())).toList();
//     // print(1);
//   } else if (o is Map) {
//     items = [
//       Container(
//           // decoration: BoxDecoration(
//           //     // border: Border.all()
//           //     ),
//           decoration: BoxDecoration(
//             border: Border(
//                 top: const BorderSide(),
//                 left: const BorderSide(),
//                 bottom: const BorderSide(),
//                 right: inner ? BorderSide.none : const BorderSide()),
//           ),
//           child: Table(
//               children:
//                   // TableRow(children: o.keys.map((e) => Text(e.toString())).toList()),
//                   // TableRow(children: o.values.map((e) => jsonView(e)).toList())
//                   o.entries
//                       .map((e) => TableRow(children: [
//                             Text("${e.key}:"),
//                             Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: jsonView(e.value, true))
//                           ]))
//                       .toList()))
//     ];
//     // print(2);
//   } else {
//     items = [Text(o.toString())];
//     // print(3);
//   }
//   // print(items);

//   // return ListView.builder(
//   //   itemCount: items.length,
//   //   itemBuilder: (ctx, index) {
//   //     return items[index];
//   //   });
//   return Wrap(
//       // color: Colors.blue,
//       children: [
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: items)
//       ]);
// }
