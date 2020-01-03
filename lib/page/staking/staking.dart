import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polka_wallet/store/staking.dart';

class Staking extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<StakingStore>(
      create: (_) => StakingStore('d'),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Staking'),
          ),
          body: Column(
            children: <Widget>[Text('Staking')],
          )));
}
