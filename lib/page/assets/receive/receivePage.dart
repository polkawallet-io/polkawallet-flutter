import 'package:encointer_wallet/common/components/encointerTextFormField.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceivePage extends StatefulWidget {
  ReceivePage(this.store);
  static final String route = '/assets/receive';
  final AppStore store;
  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  @override
  Widget build(BuildContext context) {
    bool isShare = false;
    final Map args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      isShare = args['isShare'];
    }

    String codeAddress =
        'substrate:${widget.store.account.currentAddress}:${widget.store.account.currentAccount.pubKey}:${widget.store.account.currentAccount.name}';

    final TextEditingController _amountController = new TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: isShare
              ? Text(I18n.of(context).translationsForLocale().profile.share)
              : Text(I18n.of(context).translationsForLocale().assets.receive),
          leading: Container(),
          actions: [
            IconButton(
              key: Key('close-receive-page'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      I18n.of(context).translationsForLocale().profile.qrScanHint,
                      style: Theme.of(context).textTheme.headline3.copyWith(color: encointerBlack),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: EncointerTextFormField(
                      labelText: I18n.of(context).translationsForLocale().assets.invoiceAmount,
                      textStyle: Theme.of(context).textTheme.headline2.copyWith(color: encointerBlack),
                      inputFormatters: [UI.decimalInputFormatter()],
                      controller: _amountController,
                      textFormFieldKey: Key('invoice-amount-input'),
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return I18n.of(context).translationsForLocale().assets.amountError;
                        }
                        return null;
                      },
                      suffixIcon: Text(
                        "ⵐ",
                        style: TextStyle(
                          color: encointerGrey,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Column(children: [
                Container(
                  child: QrImage(
                    data: codeAddress,
                    embeddedImage: AssetImage('assets/images/public/app.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
                  ),
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: ZurichLion.shade500),
                          SizedBox(width: 8),
                          Text(
                            I18n.of(context).translationsForLocale().assets.shareQrCode,
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ]),
                  ),
                  onTap: () => {
                    _formKey.currentState.validate()
                    // TODO add functionality to share the QR code
                  },
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
