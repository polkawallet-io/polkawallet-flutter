import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/api.dart';

class Validator extends StatelessWidget {
  Validator(this.api, this.address);

  final Api api;
  final String address;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: api.evalJavascript('api.derive.staking.query($address)'),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          var info = snapshot.data;
          print(info);
          return ListTile(
            leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
            title: Text(address),
            subtitle: Text('Own/Other Stake: '),
            trailing: Container(
              width: 120,
              child: Column(
                children: <Widget>[Text('commission'), Text('kkkk')],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
