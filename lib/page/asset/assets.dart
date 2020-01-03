import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polka_wallet/store/assets.dart';

class Assets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<AssetsStore>(
      create: (_) => AssetsStore('a'),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Assets'),
          ),
          body: Column(
            children: <Widget>[Text('Assets')],
          )));
}
