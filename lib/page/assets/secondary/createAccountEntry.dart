import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccountEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buttonStyle = Theme.of(context).textTheme.button;

    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['create'])),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Image.asset('assets/images/public/About_logo.png'),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['create'],
                onPressed: () {
                  Navigator.pushNamed(context, '/account/create');
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: RoundedButton(
                text: I18n.of(context).home['import'],
                onPressed: () {
                  Navigator.pushNamed(context, '/account/import');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
