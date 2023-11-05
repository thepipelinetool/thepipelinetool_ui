// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepipelinetool/details_page_state.dart';

class DetailsPage extends ConsumerStatefulWidget {
  final String dagName;
  // final Widget Function(BuildContext context) bottomBar;

  const DetailsPage({Key? key, required this.dagName}) : super(key: key);
  @override
  DetailsPageState createState() {
    return DetailsPageState();
  }
}
