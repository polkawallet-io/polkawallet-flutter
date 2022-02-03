import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/editIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page/account/createAccountEntryPage.dart';
import 'package:encointer_wallet/page/profile/account/changePasswordPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/settings.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class Profile extends StatefulWidget {
  Profile(this.store);
  final AppStore store;
  @override
  _ProfileState createState() => _ProfileState(store);
}

class _ProfileState extends State<Profile> {
  _ProfileState(this.store);
  final AppStore store;
  EndpointData _selectedNetwork;
  bool developerMode = false;

  void _loadAccountCache() {
    // refresh balance
    store.assets.clearTxs();
    store.assets.loadAccountCache();
    store.encointer.loadCache();
  }

  Future<void> _onSelect(AccountData i, String address) async {
    if (address != store.account.currentAddress) {
      print("we are here changing from addres ${store.account.currentAddress} to $address");

      /// set current account
      store.account.setCurrentAccount(i.pubKey);
      _loadAccountCache();

      /// reload account info
      webApi.assets.fetchBalance();
    }
  }

  Future<void> _onCreateAccount() async {
    Navigator.of(context).pushNamed(CreateAccountEntryPage.route);
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return Container(
          child: showPasswordInputDialog(
            context,
            store.account.currentAccount,
            Text(I18n.of(context).profile['unlock']),
            (password) {
              setState(() {
                store.settings.setPin(password);
              });
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildAccountList() {
    final Map<String, String> dic = I18n.of(context).profile;
    List<Widget> res = _buildAddAccount(dic);

    /// first item is current account
    List<AccountData> accounts = [store.account.currentAccount];

    /// add optional accounts
    accounts.addAll(store.account.optionalAccounts);

    res.addAll(accounts.map((i) {
      String address = i.address;
      if (store.account.pubKeyAddressMap[_selectedNetwork.ss58] != null) {
        address = store.account.pubKeyAddressMap[_selectedNetwork.ss58][i.pubKey];
      }
      return RoundedCard(
        border: address == store.account.currentAddress
            ? Border.all(color: Colors.amber)
            : Border.all(color: Theme.of(context).cardColor),
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.only(top: 7, bottom: 7),
        child: ListTile(
          leading: AddressIcon('', pubKey: i.pubKey, addressToCopy: address),
          title: Text(Fmt.accountName(context, i)),
          subtitle: Text('${Fmt.address(address)}', maxLines: 2),
          onTap: () => _onSelect(i, address),
          selected: address == store.account.currentAddress,
          trailing: EditIcon(i, address, 40, store),
        ),
      );
    }).toList());
    return res;
  }

  List<Widget> _buildAddAccount(Map<String, String> dic) {
    Color primaryColor = Theme.of(context).primaryColor;
    List<Widget> res = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${dic['accounts']} in ${_selectedNetwork.info.toUpperCase()}',
            style: Theme.of(context).textTheme.headline4,
          ),
          Row(children: <Widget>[
            Text(dic['add']),
            IconButton(
                icon: Image.asset('assets/images/assets/plus_indigo.png'),
                color: primaryColor,
                onPressed: () =>
                    {store.settings.cachedPin.isEmpty ? _showPasswordDialog(context) : _onCreateAccount()}),
          ])
        ],
      ),
    ];
    return res;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _selectedNetwork = store.settings.endpoint;
    // if all accounts are deleted, go to createAccountPage
    if (store.account.accountListAll.isEmpty) {
      store.settings.setPin('');
      Future.delayed(Duration.zero, () {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
    }
    final Map<String, String> dic = I18n.of(context).profile;

    return Observer(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(dic['title']),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: Observer(
            builder: (_) {
              if (_selectedNetwork == null) return Container();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 350,
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: _buildAccountList(),
                      // scrollDirection: Axis.horizontal,
                    ),
                  ),
                  ListTile(
                    title: Text(dic['pass.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, ChangePasswordPage.route),
                  ),
                  Row(
                    children: <Widget>[
                      Text(dic['developer']),
                      Checkbox(
                        value: developerMode,
                        onChanged: (bool value) {
                          setState(() {
                            developerMode = !developerMode;
                          });
                        },
                      ),
                    ],
                  ),
                  if (developerMode == true)
                    Row(
                      children: [
                        InkWell(
                          key: Key('choose-network'),
                          child: Observer(
                            builder: (_) => Text(
                              "change network (current: ${store.settings.endpoint.info})",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          onTap: () => Navigator.of(context).pushNamed('/network'),
                        ),
                        SizedBox(width: 8),
                        store.settings.isConnected
                            ? Icon(Icons.check, color: Colors.green)
                            : CupertinoActivityIndicator(),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
