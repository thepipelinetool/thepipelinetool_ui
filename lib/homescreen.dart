import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/deserialize/dag_options.dart';
import 'package:thepipelinetool/details_page_state.dart';
import 'package:thepipelinetool/dags_provider.dart';
import 'package:thepipelinetool/homescreen_row.dart';

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
    final dagProvider = ref.watch(fetchDagsOptionsProvider);

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0,toolbarHeight: kMyToolbarHeight, title: const MyAppBar()),
      // backgroundColor: Colors.red,
      body:
          // SingleChildScrollView(
          //     child:
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
                    onSort: (int _columnIndex, bool _ascending) {
                      setState(() {
                        sortColumn = _columnIndex;
                        ascending = _ascending;
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
