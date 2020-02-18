import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polka_wallet/store/democracy.dart';

class Democracy extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<DemocracyStore>(
      create: (_) => DemocracyStore(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Democracy'),
          ),
          body: Column(
            children: <Widget>[Text('Democracy')],
          )));
}
