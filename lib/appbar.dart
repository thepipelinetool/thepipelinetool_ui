import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
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
        )
      ],
    );
  }
}
