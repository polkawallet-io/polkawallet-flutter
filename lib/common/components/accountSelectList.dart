import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';

class AccountSelectList extends StatelessWidget {
  AccountSelectList(this.list);

  final List<AccountData> list;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: list.map((i) {
        return ListTile(
          leading: AddressIcon(address: i.address),
          title: Text(i.name),
          subtitle: Text(Fmt.address(i.address)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.of(context).pop(i.address),
        );
      }).toList(),
    );
  }
}
