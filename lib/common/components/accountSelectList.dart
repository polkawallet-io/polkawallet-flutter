import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

class AccountSelectList extends StatelessWidget {
  AccountSelectList(this.store, this.list);

  final AppStore store;
  final List<AccountData> list;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: list.map((i) {
        return ListTile(
          leading: AddressIcon(i.address, pubKey: i.pubKey),
          title: Text(Fmt.accountName(context, i)),
          subtitle: Text(Fmt.address(Fmt.addressOfAccount(i, store))),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.of(context).pop(i),
        );
      }).toList(),
    );
  }
}
