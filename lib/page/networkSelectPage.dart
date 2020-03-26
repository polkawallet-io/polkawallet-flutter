import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/createAccountEntryPage.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class NetworkSelectPage extends StatefulWidget {
  NetworkSelectPage(this.store);

  static final String route = '/network';
  final AppStore store;

  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState(store);
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  _NetworkSelectPageState(this.store);

  final AppStore store;

  EndpointData _selectedNetwork;

  List<Widget> _buildAccountList() {
    List<Widget> res = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _selectedNetwork.info.toUpperCase(),
            style: Theme.of(context).textTheme.display4,
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            color: Theme.of(context).primaryColor,
            onPressed: () =>
                Navigator.of(context).pushNamed(CreateAccountEntryPage.route),
          )
        ],
      ),
    ];
    bool isCurrentNetwork =
        _selectedNetwork.info == store.settings.endpoint.info;
    List<AccountData> accounts =
        isCurrentNetwork ? [store.account.currentAccount] : [];

    accounts.addAll(store.account.optionalAccounts);
    res.addAll(accounts.map((i) {
      return RoundedCard(
        margin: EdgeInsets.only(bottom: 16),
        child: ListTile(
          title: Text(i.name),
          subtitle: Text(Fmt.address(
              store.account.pubKeyAddressMap[_selectedNetwork.info][i.pubKey] ??
                  '')),
        ),
      );
    }).toList());
    return res;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedNetwork == null) {
      setState(() {
        _selectedNetwork = store.settings.endpoint;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map doc = I18n.of(context).home;
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['setting.network']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            return Row(
              children: <Widget>[
                // left side bar
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius:
                            8.0, // has the effect of softening the shadow
                        spreadRadius: 2.0, // ha
                      )
                    ],
                  ),
                  child: Column(
                    children:
                        [networkEndpointKusama, networkEndpointAcala].map((i) {
                      String network = i.info;
                      bool isCurrent = network == _selectedNetwork.info;
                      String img =
                          'assets/images/public/$network${isCurrent ? '' : '_gray'}.png';
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.only(right: 8),
                        decoration: isCurrent
                            ? BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: 2,
                                        color: Theme.of(context).primaryColor)),
                              )
                            : null,
                        child: IconButton(
                          padding: EdgeInsets.all(8),
                          icon: Image.asset(img),
                          onPressed: () {
                            if (!isCurrent) {
                              setState(() {
                                _selectedNetwork = i;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: _buildAccountList(),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
