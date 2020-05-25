import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/profile/account/createRecoveryPage.dart';
import 'package:polka_wallet/store/app.dart';

class RecoverySettingPage extends StatefulWidget {
  RecoverySettingPage(this.store);
  static final String route = '/profile/recovery';
  final AppStore store;

  @override
  _RecoverySettingPage createState() => _RecoverySettingPage();
}

class _RecoverySettingPage extends State<RecoverySettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('recover setting'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  RoundedCard(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    child: Text('status'),
                  )
                ],
              ),
            ),
            RoundedButton(
              text: 'create or edit',
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(CreateRecoveryPage.route, arguments: 'edit');
              },
            )
          ],
        ),
      ),
    );
  }
}
