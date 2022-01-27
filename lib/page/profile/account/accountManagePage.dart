import 'package:encointer_wallet/common/components/BorderedTitle.dart';
import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page/assets/receive/receivePage.dart';
import 'package:encointer_wallet/page/profile/account/changeNamePage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AccountManagePage extends StatelessWidget {
  AccountManagePage(this.store);

  static final String route = '/profile/account';
  final Api api = webApi;
  final AppStore store;

  void _onDeleteAccount(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return showPasswordInputDialog(
            context, store.account.currentAccount, Text(I18n.of(context).profile['delete.confirm']), (_) {
          store.account.removeAccount(store.account.currentAccount).then((_) {
            // refresh balance
            store.assets.loadAccountCache();
            webApi.assets.fetchBalance();
          });
          Navigator.of(context).pop();
        });
      },
    );
  }

  List<Widget> _getBalances() {
    CommunityMetadata cm = store.encointer.communityMetadata;
    String name = cm != null ? cm.name : '';
    String symbol = cm != null ? cm.symbol : '';
    final String tokenView = Fmt.tokenView(symbol);
    return store.encointer.balanceEntries.entries.map((i) {
      if (cm != null) {
        return RoundedCard(
          margin: EdgeInsets.only(top: 16),
          child: ListTile(
            leading: Container(
              width: 36,
              child: Image.asset('assets/images/assets/${symbol.isNotEmpty ? symbol : 'DOT'}.png'),
            ),
            title: Text(name),
            subtitle: Text(tokenView),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.doubleFormat(store.encointer.communityBalance),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54),
                ),
                Container(width: 16),
              ],
            ),
          ),
        );
      } else
        return Container();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;
    Color primaryColor = Theme.of(context).primaryColor;
    var args = {
      "isShare": true,
    };
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(store.account.currentAccount.name),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AddressIcon(
                    '',
                    size: 100,
                    pubKey: store.account.currentAccount.pubKey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Fmt.address(store.account.currentAddress), style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        child: Icon(Icons.copy),
                        onPressed: () {
                          final data = ClipboardData(text: store.account.currentAddress);
                          Clipboard.setData(data);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✓   Copied to Clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  Text(Fmt.address(store.account.currentAddress) ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  Container(padding: EdgeInsets.only(top: 16)),
                  ListTile(
                    title: Text(dic['name.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, ChangeNamePage.route),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        BorderedTitle(
                          title: 'Communities',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(padding: EdgeInsets.all(16), children: _getBalances()),
              ),
              ElevatedButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    dic['account.share'],
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, ReceivePage.route, arguments: args);
                  }),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(color: Colors.red),
                      ),
                      child: Text(dic['delete']),
                      onPressed: () => _onDeleteAccount(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
