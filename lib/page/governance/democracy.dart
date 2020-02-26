import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';

class Democracy extends StatelessWidget {
  Democracy(this.store);
  final AppStore store;
  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => Column(
          children: <Widget>[Text('Democracy')],
        ),
      );
}
