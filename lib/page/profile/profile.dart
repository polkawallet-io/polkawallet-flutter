import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polka_wallet/store/profile.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<ProfileStore>(
      create: (_) => ProfileStore('d'),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: Column(
            children: <Widget>[Text('Profile')],
          )));
}
