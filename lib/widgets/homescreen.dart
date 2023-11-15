// ignore_for_file: constant_identifier_names

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thepipelinetool/widgets/appbar.dart';
import 'package:thepipelinetool/classes/dag_options.dart';
import 'package:thepipelinetool/providers/dags.dart';
// import 'package:thepipelinetool/homescreen_row.dart';

import 'dag_page/dag_page.dart';

class DagLink extends ConsumerWidget {
  final DagOptions dagOptions;
  const DagLink({super.key, required this.dagOptions});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // handle the tap event
            FocusScope.of(context).requestFocus(FocusNode());

            // ref.invalidate(selectedItemProvider(dagName));
            context.goNamed('dag',
                pathParameters: {'dag_name': dagOptions.dagName});
          },
          child: Text(
            dagOptions.dagName,
            // style: const TextStyle(
            //     decoration: TextDecoration.underline), // optional
          ),
        ),
      );
}

class DTS extends DataTableSource {
  final List<DagOptions> allDagOptions;
  DTS(this.allDagOptions);

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(DagLink(dagOptions: allDagOptions[index])),
        DataCell(Text(allDagOptions[index].schedule ?? '')),

        // Text(allDagOptions[index].dagName)),
        // DataCell(Text('#cel2$index')),
        // DataCell(Text('#cel3$index')),
        // DataCell(Text('#cel4$index')),
        // DataCell(Text('#cel5$index')),
        // DataCell(Text('#cel6$index')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => allDagOptions.length;

  @override
  int get selectedRowCount => 0;
}

class HomeScreen extends ConsumerStatefulWidget {
  // final Widget Function(BuildContext context) bottomBar;

  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

enum Columns {
  DAG,
  // endDate;
  // maxAttempts;
  // retryDelay;
  Schedule,
  // startDate;
  // timeout;
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  HomeScreenState();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  int sortColumn = 0;
  bool ascending = false;

  @override
  Widget build(BuildContext context) {
    final dagProvider = ref.watch(dagsProvider);

    // return Container();

    // final data = {
    //   "name": "Aleix Melon",
    //   "id": "E00245",
    //   "role": ["Dev", "DBA"],
    //   "age": 23,
    //   "doj": "11-12-2019",
    //   "married": false,
    //   "address": {
    //     "street": "32, Laham St.",
    //     "city": "Innsbruck",
    //     "country": "Austria"
    //   },
    //   "referred-by": "E0012"
    // };

    return Scaffold(
      appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: kMyToolbarHeight,
          title: const MyAppBar()),
      // backgroundColor: Colors.red,
      body:

          //   Scrollbar(
          // child:
          PaginatedDataTable2(
        wrapInCard: false,
        // controller: _scrollController,
        sortColumnIndex: sortColumn,
        sortAscending: ascending,
        columns: Columns.values
            .map((e) => e.name)
            .map((e) => DataColumn(
                  label: Text(e),
                  onSort: (int columnIndex, bool ascending_) {
                    setState(() {
                      sortColumn = columnIndex;
                      ascending = ascending_;
                    });
                  },
                ))
            .toList(),
        source:
            // children: <Widget>[
            //   const SliverPadding(
            //     padding: EdgeInsets.only(bottom: 8.0),
            //     sliver: SliverAppBar(
            //       backgroundColor: Color.fromARGB(255, 170, 170, 170),
            //       pinned: true,
            //       toolbarHeight: 40,
            //       title: Row(
            //         children: [Text('DAG')],
            //       ),
            //     ),
            //   ),
            switch (dagProvider) {
          AsyncData(:final value) => DTS(value
            ..sort((a, b) {
              if (ascending) {
                [a, b] = [b, a];
              }
              // print(ascending);

              switch (Columns.values[sortColumn]) {
                case Columns.DAG:
                  return a.dagName.compareTo(b.dagName);
                case Columns.Schedule:
                  if (a.schedule != null && b.schedule != null) {
                    return a.schedule!.compareTo(b.schedule!);
                  }

                  if (b.schedule == null) {
                    return -1;
                  }

                  return 1;
              }
            })),
          // SliverList.separated(
          //     itemCount: value.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return HomeScreenRow(dagOptions: value[index]);
          //     },
          //     separatorBuilder: (BuildContext context, int index) =>
          //         const Divider(),
          //   ),
          AsyncError() => DTS([]),
          _ => DTS([]),
        },
        // ],
        // ),
        // ),
      ),
      //   ),
      // ),
    );
  }
}
