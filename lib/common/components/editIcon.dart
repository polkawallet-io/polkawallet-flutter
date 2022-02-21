import 'package:encointer_wallet/page/profile/account/accountManagePage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class EditIcon extends StatelessWidget {
  EditIcon(this.accountData, this.address, this.size, this.store);
  final String address;
  final AccountData accountData;
  final double size;
  final AppStore store;

  Future<void> _onSelect(AccountData i, String address) async {
    if (address != store.account.currentAddress) {
      print("[editIcon] changing from address ${store.account.currentAddress} to $address");

      store.account.setCurrentAccount(i.pubKey);
      await store.loadAccountCache();

      webApi.fetchAccountData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return GestureDetector(
          child: Container(
            width: size ?? 40,
            height: size ?? 40,
            child: Icon(Icons.edit),
          ),
          onTap: () async => {
            await _onSelect(this.accountData, this.address),
            Navigator.pushNamed(context, AccountManagePage.route),
          },
        );
      },
    );
  }
}