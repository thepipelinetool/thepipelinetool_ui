import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DagLink extends StatelessWidget {
  const DagLink({super.key});

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // handle the tap event
            context.go('/details');
          },
          child: Text(
            'Click Me',
            style: TextStyle(decoration: TextDecoration.underline), // optional
          ),
        ),
      );
}

class HomeScreenRow extends StatelessWidget {
  const HomeScreenRow({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          DagToggle(),
          DagLink(),
        ],
      );
}

class DagToggle extends StatefulWidget {
  const DagToggle({super.key});

  @override
  State<StatefulWidget> createState() => _DagToggleState();
}

class _DagToggleState extends State<DagToggle> {
  bool on = false;

  @override
  Widget build(BuildContext context) => CupertinoSwitch(
      value: on,
      onChanged: (val) {
        setState(() {
          on = val;
        });
      });
}
