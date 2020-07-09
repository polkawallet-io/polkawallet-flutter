import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountSelectPage extends StatelessWidget {
  AccountSelectPage(this.store);

  static final String route = '/staking/account/list';
  final AppStore store;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).staking['controller']),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Container(
                color: Theme.of(context).cardColor,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: store.account.accountList.map((i) {
                    String address = Fmt.addressOfAccount(i, store);
                    String unavailable;
                    String stashOf =
                        store.account.pubKeyBondedMap[i.pubKey].controllerId;
                    String controllerOf =
                        store.account.pubKeyBondedMap[i.pubKey].stashId;
                    if (stashOf != null &&
                        i.pubKey != store.account.currentAccount.pubKey) {
                      unavailable =
                          '${I18n.of(context).staking['controller.stashOf']} ${Fmt.address(stashOf)}';
                    }
                    if (controllerOf != null &&
                        controllerOf != store.account.currentAddress) {
                      unavailable =
                          '${I18n.of(context).staking['controller.controllerOf']} ${Fmt.address(controllerOf)}';
                    }
                    Color grey = Theme.of(context).disabledColor;
                    return GestureDetector(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 16),
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: AddressIcon('', pubKey: i.pubKey),
                            ),
                            Expanded(
                              child: unavailable != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          i.name,
                                          style: TextStyle(color: grey),
                                        ),
                                        Text(
                                          Fmt.address(address),
                                          style: TextStyle(color: grey),
                                        ),
                                        Text(
                                          unavailable,
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(i.name),
                                        Text(Fmt.address(address)),
                                      ],
                                    ),
                            ),
                            unavailable == null
                                ? Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      onTap: unavailable == null
                          ? () => Navigator.of(context).pop(i)
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );
}
