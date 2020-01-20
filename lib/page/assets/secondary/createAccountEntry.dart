import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccountEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buttonStyle = Theme.of(context).textTheme.button;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Image.asset('assets/images/public/About_logo.png'),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(
                      I18n.of(context).home['create'],
                      style: buttonStyle,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/account/create');
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(
                      I18n.of(context).home['import'],
                      style: buttonStyle,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/account/import');
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
