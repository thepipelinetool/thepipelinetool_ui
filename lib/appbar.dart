import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyAppBar extends ConsumerWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkmode = ref.watch(darkmodeProvider);


    return Row(
      children: [
        const Text("TPT"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                // handle the tap event
                context.go('/');
              },
              child: const Text(
                'DAGS',
                style:
                    TextStyle(decoration: TextDecoration.underline), // optional
              ),
            ),
          ),
        ),
        const Spacer(),
        Switch(value: darkmode, onChanged: (v) {
          ref.read(darkmodeProvider.notifier).change(v);
        })
      ],
    );
  }
}

final darkmodeProvider = StateNotifierProvider<DarkMode, bool>((ref) {
  return DarkMode();
});

class DarkMode extends StateNotifier<bool> {
  DarkMode() : super(false);

  void change(bool text) => state = text;
}