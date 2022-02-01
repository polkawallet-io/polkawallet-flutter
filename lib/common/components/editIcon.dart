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

  void _loadAccountCache() {
    // refresh balance
    store.assets.clearTxs();
    store.assets.loadAccountCache();
    store.encointer.loadCache();
  }

  Future<void> _onSelect(AccountData i, String address) async {
    if (address != store.account.currentAddress) {
      print("we are here changing from addres ${store.account.currentAddress} to $address");

      /// set current account
      store.account.setCurrentAccount(i.pubKey);
      _loadAccountCache();

      /// reload account info
      webApi.assets.fetchBalance();
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
