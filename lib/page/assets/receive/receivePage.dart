import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceivePage extends StatelessWidget {
  ReceivePage(this.store);

  static final String route = '/assets/receive';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    String codeAddress =
        'substrate:${store.account.currentAddress}:${store.account.currentAccount.pubKey}:${store.account.currentAccount.name}';
    Color themeColor = Theme.of(context).primaryColor;

    final accInfo =
        store.account.accountIndexMap[store.account.currentAccount.address];

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(I18n.of(context).assets['receive']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Image.asset(
                      'assets/images/assets/receive_line_${store.settings.endpoint.color ?? 'pink'}.png'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(4)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: AddressIcon(
                          '',
                          pubKey: store.account.currentAccount.pubKey,
                        ),
                      ),
                      Text(
                        store.account.currentAccount.name,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      accInfo != null && accInfo['accountIndex'] != null
                          ? Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(accInfo['accountIndex']),
                            )
                          : Container(width: 8, height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: themeColor),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(8)),
                        ),
                        margin: EdgeInsets.fromLTRB(48, 16, 48, 24),
                        child: QrImage(
                          data: codeAddress,
                          size: 200,
                          embeddedImage:
                              AssetImage('assets/images/public/app.png'),
                          embeddedImageStyle:
                              QrEmbeddedImageStyle(size: Size(40, 40)),
                        ),
                      ),
                      Container(
                        width: 160,
                        child: Text(store.account.currentAddress),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.only(top: 16, bottom: 32),
                        child: RoundedButton(
                          text: I18n.of(context).assets['copy'],
                          onPressed: () => UI.copyAndNotify(
                              context, store.account.currentAddress),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
