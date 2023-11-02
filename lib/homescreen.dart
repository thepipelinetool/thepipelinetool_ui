import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thepipelinetool/homescreenrow.dart';

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: ListView.builder(
          itemCount: 15,
          itemBuilder: (ctx, index) => HomeScreenRow(),
        ),
        // ElevatedButton(
        //   onPressed: () => context.go('/details'),
        //   child: const Text('Go to the Details screen'),
        // ),
      ),
    );
  }
}
