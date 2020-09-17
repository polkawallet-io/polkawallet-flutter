import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrSignerPage extends StatelessWidget {
  QrSignerPage(this.store);

  static const String route = 'tx/uos/signer';

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).account;
    final String text = ModalRoute.of(context).settings.arguments;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(dic['uos.title']), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AddressFormItem(
                  store.account.currentAccount,
                  label: dic['uos.signer'],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextTag(
                    dic['uos.warn'],
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(dic['uos.push']),
                ),
                QrImage(data: text, size: screenWidth - 24),
              ],
            )
          ],
        ),
      ),
    );
  }
}
