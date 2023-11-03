import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/dags_provider.dart';
import 'package:thepipelinetool/homescreenrow.dart';

/// The home screen
class HomeScreen extends ConsumerWidget {
  /// Constructs a [HomeScreen]
  // const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(fetchUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
          child: switch (userProvider) {
        // TODO: Handle this case.
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (ctx, index) => HomeScreenRow(dagName: value[index]),
          ),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => const CircularProgressIndicator(),
      }

          // ElevatedButton(
          //   onPressed: () => context.go('/details'),
          //   child: const Text('Go to the Details screen'),
          // ),
          ),
    );
  }
}
