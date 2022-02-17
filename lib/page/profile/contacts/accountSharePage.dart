import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class AccountSharePage extends StatefulWidget {
  AccountSharePage(this.store);
  static final String route = '/profile/share';
  final AppStore store;
  @override
  _AccountSharePageState createState() => _AccountSharePageState();
}

class _AccountSharePageState extends State<AccountSharePage> {
  @override
  Widget build(BuildContext context) {
    var contact = [
      'encointer-contact',
      'V1.0',
      widget.store.account.currentAddress,
      widget.store.encointer.chosenCid != null ? (widget.store.encointer.chosenCid).toFmtString() : '',
      widget.store.account.currentAccount.name
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(I18n.of(context).translationsForLocale().profile.share),
        leading: Container(),
        actions: [
          IconButton(
            key: Key('close-share-page'),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 60, right: 60, bottom: 20),
                  child: Text(
                    I18n.of(context).translationsForLocale().profile.qrScanHintAccount,
                    style: Theme.of(context).textTheme.headline2.copyWith(color: encointerBlack),
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  children: [
                    Container(
                      child: QrImage(
                        size: MediaQuery.of(context).copyWith().size.height / 2,
                        data: contact.join('\n'),
                        embeddedImage: AssetImage('assets/images/public/app.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: Text('${widget.store.account.currentAccount.name}',
                          style: Theme.of(context).textTheme.headline3.copyWith(color: encointerGrey),
                          textAlign: TextAlign.center),
                    )
                  ],
                ),
              ],
            ),
            Text(I18n.of(context).translationsForLocale().profile.shareLinkHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4.copyWith(color: encointerGrey)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: ZurichLion.shade500),
                    SizedBox(width: 12),
                    Text(I18n.of(context).translationsForLocale().profile.sendLink,
                        style: Theme.of(context).textTheme.headline3),
                  ],
                ),
                onPressed: () => Share.share(contact.join('\n')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
