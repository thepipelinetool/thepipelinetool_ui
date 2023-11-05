import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/appbar.dart';
import 'package:thepipelinetool/details_page_state.dart';
import 'package:thepipelinetool/dags_provider.dart';
import 'package:thepipelinetool/homescreen_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dagProvider = ref.watch(fetchDagsProvider);

    return Scaffold(
      appBar: AppBar(toolbarHeight: kMyToolbarHeight, title: const MyAppBar()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 8.0),
                sliver: SliverAppBar(
                  backgroundColor: Color.fromARGB(255, 170, 170, 170),
                  pinned: true,
                  toolbarHeight: 40,
                  title: Row(
                    children: [Text('DAG')],
                  ),
                ),
              ),
              switch (dagProvider) {
                AsyncData(:final value) => SliverList.separated(
                    itemCount: value.length,
                    itemBuilder: (BuildContext context, int index) {
                      return HomeScreenRow(dagName: value[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  ),
                AsyncError() => SliverList.list(children: const [
                    Text('Oops, something unexpected happened')
                  ]),
                _ => SliverList.list(
                    children: const [CircularProgressIndicator()]),
              },
            ],
          ),
        ),
      ),
    );
  }
}
