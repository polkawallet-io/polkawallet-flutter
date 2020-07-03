import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class VouchRecoveryPage extends StatefulWidget {
  VouchRecoveryPage(this.store);
  static final String route = '/profile/recovery/vouch';
  final AppStore store;

  @override
  _VouchRecoveryPage createState() => _VouchRecoveryPage();
}

class _VouchRecoveryPage extends State<VouchRecoveryPage> {
  final TextEditingController _addressOldCtrl = new TextEditingController();
  final TextEditingController _addressNewCtrl = new TextEditingController();

  bool _loading = false;

  Future<void> _onValidateSubmit() async {
    final Map dic = I18n.of(context).profile;
    setState(() {
      _loading = true;
    });
    String addressOld = _addressOldCtrl.text.trim();
    String addressNew = _addressNewCtrl.text.trim();
    String address;
    String errorMsg;

    /// check if old account is recoverable
    Map info =
        await webApi.account.queryRecoverable(_addressOldCtrl.text.trim());
    if (info == null) {
      address = addressOld;
      errorMsg = dic['recovery.not.recoverable'];
    } else {
      /// check if there is an active recovery for new account
      info = (await webApi.account.queryActiveRecoveryAttempts(
        _addressOldCtrl.text.trim(),
        [_addressNewCtrl.text.trim()],
      ))[0];
      if (info == null) {
        address = addressNew;
        errorMsg = dic['recovery.no.active'];
      }
    }

    setState(() {
      _loading = false;
    });

    if (errorMsg != null) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Fmt.address(address)),
            content: Text(errorMsg),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  I18n.of(context).home['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _onSubmit(addressOld, addressNew);
    }
  }

  void _onSubmit(String addressOld, String addressNew) {
    final Map dic = I18n.of(context).profile;
    var args = {
      "title": dic['recovery.help'],
      "txInfo": {
        "module": 'recovery',
        "call": 'vouchRecovery',
      },
      "detail": jsonEncode({
        'lost': addressOld,
        'rescuer': addressNew,
      }),
      "params": [addressOld, addressNew],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery/proof'));
        globalRecoveryProofRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    final Color primary = Theme.of(context).primaryColor;
    final Color grey = Theme.of(context).disabledColor;
    final List<AccountData> friends = ModalRoute.of(context).settings.arguments;
    final String symbol = widget.store.settings.networkState.tokenSymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.help']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic['recovery.help.old'],
                        labelText: dic['recovery.help.old'],
                        suffix: GestureDetector(
                          child:
                              Image.asset('assets/images/profile/address.png'),
                          onTap: () async {
                            var to = await Navigator.of(context)
                                .pushNamed(ContactListPage.route);
                            if (to != null) {
                              setState(() {
                                _addressOldCtrl.text =
                                    (to as AccountData).address;
                              });
                            }
                          },
                        ),
                      ),
                      controller: _addressOldCtrl,
                      validator: (v) {
                        return Fmt.isAddress(v.trim())
                            ? null
                            : dic['address.error'];
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic['recovery.help.new'],
                        labelText: dic['recovery.help.new'],
                        suffix: GestureDetector(
                          child:
                              Image.asset('assets/images/profile/address.png'),
                          onTap: () async {
                            var to = await Navigator.of(context)
                                .pushNamed(ContactListPage.route);
                            if (to != null) {
                              setState(() {
                                _addressNewCtrl.text =
                                    (to as AccountData).address;
                              });
                            }
                          },
                        ),
                      ),
                      controller: _addressNewCtrl,
                      validator: (v) {
                        return Fmt.isAddress(v.trim())
                            ? null
                            : dic['address.error'];
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['next'],
                  onPressed: () => _onValidateSubmit(),
                  submitting: _loading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
