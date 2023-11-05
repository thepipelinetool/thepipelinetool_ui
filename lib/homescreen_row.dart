import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thepipelinetool/deserialize/dag_options.dart';

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
            style: const TextStyle(
                decoration: TextDecoration.underline), // optional
          ),
        ),
      );
}

// class HomeScreenRow extends StatelessWidget {
//   final DagOptions dagOptions;

//   const HomeScreenRow({super.key, required this.dagOptions});

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
//         child: Row(
//           children: [
//             // DagToggle(),
//             DagLink(dagOptions: dagOptions),

//           ],
//         ),
//       );
// }

// class DagToggle extends StatefulWidget {
//   const DagToggle({super.key});

//   @override
//   State<StatefulWidget> createState() => _DagToggleState();
// }

// class _DagToggleState extends State<DagToggle> {
//   bool on = false;

//   @override
//   Widget build(BuildContext context) => CupertinoSwitch(
//       value: on,
//       onChanged: (val) {
//         setState(() {
//           on = val;
//         });
//       });
// }
