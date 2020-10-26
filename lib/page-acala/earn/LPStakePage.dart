import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LPStakePage extends StatefulWidget {
  LPStakePage(this.store);

  static const String route = '/acala/earn/stake';
  static const String actionStake = 'stake';
  static const String actionUnStake = 'unStake';
  final AppStore store;

  @override
  _LPStakePage createState() => _LPStakePage();
}

class _LPStakePage extends State<LPStakePage> {
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).acala;
    final args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text(dic['earn.$args']), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            return Text('xxx');
          },
        ),
      ),
    );
  }
}
