import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/graph_view.dart';

final selectedTaskProvider = StateNotifierProvider<AppStateNotifier, String>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<String> {
  AppStateNotifier() : super('Initial Data');
  void updateData(String newData) {
    state = newData;
  }
  // void updateData(String newData) {
  //   state = state.copyWith(data: newData);
  // }
}

class MyDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(selectedTaskProvider);

    return Text(appState);
  }

}