import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/accountSelectList.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountSelectPage extends StatelessWidget {
  AccountSelectPage(this.store);

  static final String route = '/staking/account/list';
  final AccountStore store;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).staking['controller']),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: SafeArea(
                child: AccountSelectList(store.accountList.toList()),
              ),
            ),
          );
        },
      );
}
