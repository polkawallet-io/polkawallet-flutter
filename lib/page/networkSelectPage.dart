import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/createAccountEntryPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class NetworkSelectPage extends StatefulWidget {
  NetworkSelectPage(this.store, this.changeTheme);

  static final String route = '/network';
  final AppStore store;
  final Function changeTheme;

  @override
  _NetworkSelectPageState createState() =>
      _NetworkSelectPageState(store, changeTheme);
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  _NetworkSelectPageState(this.store, this.changeTheme);

  final AppStore store;
  final Function changeTheme;

  final List<EndpointData> networks = [
    networkEndpointPolkadot,
    networkEndpointKusama,
    networkEndpointAcala,
    networkEndpointLaminar,
  ];

  EndpointData _selectedNetwork;
  bool _networkChanging = false;

  void _loadAccountCache() {
    // refresh balance
    store.assets.clearTxs();
    store.assets.loadAccountCache();

    final isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
    final isLaminar =
        store.settings.endpoint.info == networkEndpointLaminar.info;
    if (isAcala) {
      store.acala.setTransferTxs([], reset: true);
      store.acala.loadCache();
    } else if (isLaminar) {
      store.laminar.setTransferTxs([], reset: true);
      store.laminar.loadCache();
    } else {
      // refresh user's staking info if network is kusama or polkadot
      store.staking.clearState();
      store.staking.loadAccountCache();
    }
  }

  Future<void> _reloadNetwork() async {
    setState(() {
      _networkChanging = true;
    });
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).home['loading']),
          content: Container(height: 64, child: CupertinoActivityIndicator()),
        );
      },
    );

    store.settings.setNetworkLoading(true);
    await store.settings.setNetworkConst({}, needCache: false);
    store.settings.setEndpoint(_selectedNetwork);

    await store.settings.loadNetworkStateCache();

    store.gov.clearState();
    store.assets.loadCache();
    store.staking.clearState();
    store.staking.loadCache();
    final isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
    final isLaminar =
        store.settings.endpoint.info == networkEndpointLaminar.info;
    if (isAcala) {
      store.acala.loadCache();
    } else if (isLaminar) {
//      store.laminar.setTransferTxs([], reset: true);
      store.laminar.loadCache();
    }

    webApi.launchWebview();
    changeTheme();
    if (mounted) {
      Navigator.of(context).pop();
      setState(() {
        _networkChanging = false;
      });
    }
  }

  Future<void> _onSelect(AccountData i, String address) async {
    bool isCurrentNetwork =
        _selectedNetwork.info == store.settings.endpoint.info;
    if (address != store.account.currentAddress || !isCurrentNetwork) {
      /// set current account
      store.account.setCurrentAccount(i.pubKey);

      if (isCurrentNetwork) {
        _loadAccountCache();

        /// reload account info
        webApi.assets.fetchBalance();
      } else {
        /// set new network and reload web view
        await _reloadNetwork();
      }
    }
    Navigator.of(context).pop();
  }

  Future<void> _onCreateAccount() async {
    bool isCurrentNetwork =
        _selectedNetwork.info == store.settings.endpoint.info;
    if (!isCurrentNetwork) {
      await _reloadNetwork();
    }
    Navigator.of(context).pushNamed(CreateAccountEntryPage.route);
  }

  List<Widget> _buildAccountList() {
    Color primaryColor = Theme.of(context).primaryColor;
    List<Widget> res = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _selectedNetwork.info.toUpperCase(),
            style: Theme.of(context).textTheme.headline4,
          ),
          IconButton(
            icon: Image.asset(
                'assets/images/assets/plus_${store.settings.endpoint.color ?? 'pink'}.png'),
            color: primaryColor,
            onPressed: () => _onCreateAccount(),
          )
        ],
      ),
    ];

    /// first item is current account
    List<AccountData> accounts = [store.account.currentAccount];

    /// add optional accounts
    accounts.addAll(store.account.optionalAccounts);

    res.addAll(accounts.map((i) {
      String address = i.address;
      if (store.account.pubKeyAddressMap[_selectedNetwork.ss58] != null) {
        address =
            store.account.pubKeyAddressMap[_selectedNetwork.ss58][i.pubKey];
      }
      final bool isCurrentNetwork =
          _selectedNetwork.info == store.settings.endpoint.info;
      final accInfo = store.account.accountIndexMap[i.address];
      final String accIndex =
          isCurrentNetwork && accInfo != null && accInfo['accountIndex'] != null
              ? '${accInfo['accountIndex']}\n'
              : '';
      final double padding = accIndex.isEmpty ? 0 : 7;
      return RoundedCard(
        border: address == store.account.currentAddress
            ? Border.all(color: Theme.of(context).primaryColorLight)
            : Border.all(color: Theme.of(context).cardColor),
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: ListTile(
          leading: AddressIcon('', pubKey: i.pubKey, addressToCopy: address),
          title: Text(Fmt.accountName(context, i)),
          subtitle: Text('$accIndex${Fmt.address(address)}', maxLines: 2),
          onTap: _networkChanging ? null : () => _onSelect(i, address),
        ),
      );
    }).toList());
    return res;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedNetwork = store.settings.endpoint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map doc = I18n.of(context).home;
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['setting.network']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_selectedNetwork == null) return Container();
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
                      blurRadius: 8.0, // has the effect of softening the shadow
                      spreadRadius: 2.0, // ha
                    )
                  ],
                ),
                child: Column(
                  children: networks.map((i) {
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
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: _buildAccountList(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
