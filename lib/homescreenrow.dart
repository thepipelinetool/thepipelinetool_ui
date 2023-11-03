import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DagLink extends StatelessWidget {
  final String dagName;
  const DagLink({super.key, required this.dagName});

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // handle the tap event
            context.goNamed('dag', pathParameters: {'dag_name': dagName});
          },
          child: Text(
            dagName,
            style: TextStyle(decoration: TextDecoration.underline), // optional
          ),
        ),
      );
}

class HomeScreenRow extends StatelessWidget {
  final String dagName;

  const HomeScreenRow({super.key, required this.dagName});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        child: Row(
          children: [
            DagToggle(),
            DagLink(dagName: dagName),
          ],
        ),
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
