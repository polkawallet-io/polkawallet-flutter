import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/page/asExtension/types/signExtrinsicParam.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class WalletExtensionSignPage extends StatefulWidget {
  WalletExtensionSignPage(this.store);

  static const String route = '/extension/sign';

  static const String signTypeBytes = 'pub(bytes.sign)';
  static const String signTypeExtrinsic = 'pub(extrinsic.sign)';

  final AppStore store;

  @override
  _WalletExtensionSignPageState createState() =>
      _WalletExtensionSignPageState();
}

class _WalletExtensionSignPageState extends State<WalletExtensionSignPage> {
  bool _submitting = false;

  Future<void> _showPasswordDialog(AccountData acc) async {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          account: acc,
          onOk: (password) => _sign(password),
        );
      },
    );
  }

  Future<void> _sign(String password) async {
    setState(() {
      _submitting = true;
    });
    final Map args = ModalRoute.of(context).settings.arguments;
    final Map res = await webApi.account.signAsExtension(password, args);
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
    Navigator.of(context).pop({
      'id': args['id'],
      'signature': res['signature'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).home;
    final Map args = ModalRoute.of(context).settings.arguments;
    final String signType = args['msgType'];
    final String address = args['request']['address'];
    final AccountData acc = widget.store.account.accountList.firstWhere((acc) {
      bool matched = false;
      widget.store.account.pubKeyAddressMap.values.forEach((e) {
        e.forEach((k, v) {
          if (acc.pubKey == k && address == v) {
            matched = true;
          }
        });
      });
      return matched;
    });
    return Scaffold(
      appBar: AppBar(
          title: Text(dic[signType == WalletExtensionSignPage.signTypeBytes
              ? 'submit.sign.tx'
              : 'submit.sign.msg']),
          centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: AddressFormItem(acc, label: dic['submit.signer']),
                  ),
                  signType == WalletExtensionSignPage.signTypeExtrinsic
                      ? SignExtrinsicInfo(args)
                      : SignBytesInfo(args),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: _submitting ? Colors.black12 : Colors.orange,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(dic['cancel'],
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: _submitting
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).primaryColor,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        dic['submit.sign'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed:
                          _submitting ? null : () => _showPasswordDialog(acc),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SignExtrinsicInfo extends StatelessWidget {
  SignExtrinsicInfo(this.msg);
  final Map msg;
  @override
  Widget build(BuildContext context) {
    final SignExtrinsicParam param =
        SignExtrinsicParam.fromJson(msg['request']);
    return Column(
      children: [
        InfoItemRow('from', msg['url']),
        InfoItemRow('genesis', Fmt.address(param.genesisHash, pad: 10)),
        InfoItemRow('version', int.parse(param.specVersion).toString()),
        InfoItemRow('nonce', int.parse(param.nonce).toString()),
        InfoItemRow('method data', Fmt.address(param.method, pad: 10)),
      ],
    );
  }
}

class SignBytesInfo extends StatelessWidget {
  SignBytesInfo(this.msg);
  final Map msg;
  @override
  Widget build(BuildContext context) {
    final SignBytesParam param = SignBytesParam.fromJson(msg['request']);
    return Column(
      children: [
        InfoItemRow('from', msg['url']),
        InfoItemRow('bytes', Fmt.address(param.data, pad: 10)),
      ],
    );
  }
}
