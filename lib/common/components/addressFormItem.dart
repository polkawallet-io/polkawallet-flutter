import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

class AddressFormItem extends StatelessWidget {
  AddressFormItem(this.label, this.account, {this.onTap});
  final String label;
  final AccountData account;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    Color grey = Theme.of(context).unselectedWidgetColor;

    String address = globalAppStore.account.currentAddress;

    Column content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(color: grey),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 4),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border:
                Border.all(color: Theme.of(context).disabledColor, width: 0.5),
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8),
                child: AddressIcon(address, pubKey: account.pubKey, size: 32),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(account.name),
                    Text(
                      Fmt.address(address),
                      style: TextStyle(fontSize: 14, color: grey),
                    )
                  ],
                ),
              ),
              onTap == null
                  ? Container()
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: grey,
                    )
            ],
          ),
        )
      ],
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(
      child: content,
      onTap: () => onTap(),
    );
  }
}
