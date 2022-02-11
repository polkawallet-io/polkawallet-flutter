import 'package:encointer_wallet/common/components/addressFormItem.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class QrSignerPage extends StatelessWidget {
  QrSignerPage(this.store);

  static const String route = 'tx/uos/signer';

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    final String text = ModalRoute.of(context).settings.arguments;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(dic.account.uosTitle), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AddressFormItem(
                  store.account.currentAccount,
                  label: dic.account.uosSigner,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(dic.account.uosPush),
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
