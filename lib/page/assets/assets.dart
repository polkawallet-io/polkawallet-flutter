import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polka_wallet/store/assets.dart';

class Assets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<AssetsStore>(
      create: (_) => AssetsStore(),
      child: new Scaffold(
        body: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('test'),
              onPressed: () => Navigator.pushNamed(context, '/account/backup'),
            )
          ],
        ),
      ));
}
