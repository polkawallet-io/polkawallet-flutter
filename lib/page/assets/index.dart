import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/claim/claimPage.dart';
import 'package:polka_wallet/page/assets/lock/lockPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/page/assets/signal/signalPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Assets extends StatefulWidget {
  Assets(this.store);

  final AppStore store;

  @override
  _AssetsState createState() => _AssetsState(store);
}

class _AssetsState extends State<Assets> {
  _AssetsState(this.store);

  final AppStore store;
  Set expandSet = new Set();

  Future<void> _fetchBalance() async {
    await Future.wait([
      webApi.assets.fetchBalance(store.account.currentAccount.pubKey),
      webApi.staking.fetchAccountStaking(store.account.currentAccount.pubKey),
    ]);
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;

    return RoundedCard(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: AddressIcon('', pubKey: acc.pubKey),
            title: Text(acc.name ?? ''),
            subtitle: Text(network),
          ),
          ListTile(
            title: Text(Fmt.address(store.account.currentAddress)),
            trailing: IconButton(
              icon: Image.asset('assets/images/assets/Assets_nav_code.png'),
              onPressed: () {
                if (acc.address != '') {
                  Navigator.pushNamed(context, ReceivePage.route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // if network connected failed, reconnect
    if (!store.settings.loading && store.settings.networkName == null) {
      store.settings.setNetworkLoading(true);
      webApi.connectNode();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol;
        String networkName = store.settings.networkName;
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _fetchBalance,
          child: ListView(
            padding: EdgeInsets.only(left: 16, right: 16),
            children: <Widget>[
              _buildTopCard(context),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: BorderedTitle(
                  title: I18n.of(context).home['assets'],
                ),
              ),
              item(
                context,
                store: store,
                symbol: symbol, 
                name: networkName,
                expandSet: expandSet,
                expandTap: (){
                  if(expandSet.contains(networkName)){
                    expandSet.remove(networkName);
                  }else{
                    expandSet.add(networkName);
                  }

                  setState(() {});
                } 
              )
            ],
          ),
        );
      },
    );
  }
}

Widget item(context,{store,symbol,name = '',Set expandSet,expandTap}){
  return RoundedCard(
    margin: EdgeInsets.only(top: 16),
    child: Column(
      children: <Widget>[
        itemHeader(
          context,
          store: store,
          symbol: symbol, 
          name: name
        ),
        operater(
          context,
          name: name,
          expandSet: expandSet,
          expandTap: expandTap),
        itemButtons(context),
        expandSet != null && expandSet.contains(name) ?
          expandTab(context):
          Container(),
        // itemExpand()
      ]
    )
  );
}

Widget itemHeader(context,{store,symbol,name = ''}){
  return ListTile(
    // contentPadding: EdgeInsets.symmetric(vertical:0),
    leading: Container(
      width: 40,
      height: 40,
      child: Image.asset(
        'assets/images/assets/${symbol.isNotEmpty ? symbol : 'DOT'}.png'),
    ),
    title: Text(symbol ?? ''),
    subtitle: Text(name.isNotEmpty ? name : '~'),
    trailing: Container(
      width: 140,
      // padding: const EdgeInsets.only(bottom:10),
      child: ListTile(
        isThreeLine: true,
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          I18n.of(context).assets['balance'],
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          )
        ),
        subtitle: Container(
          padding: EdgeInsets.zero,
          child: const Text('(~3000 USD)',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10
            ),
          )
        ),
        trailing: Text(
          Fmt.balance(store.assets.balance),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black54
          ),
        )
      ),
    ),
    // onTap: () {
      // Navigator.pushNamed(context, AssetPage.route);
    // },
  );
}

Widget operater(context,{name = '',expandSet,expandTap}){
  return Container(
    padding: EdgeInsets.only(right:20),
    child: Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        GestureDetector(
          child: Icon(
            expandSet.contains(name) ? 
              Icons.expand_less :
              Icons.expand_more,
          ),
          onTap: expandTap,
        ),
        GestureDetector(
          child: Icon(
            Icons.fullscreen,
          ),
          onTap: () => Navigator.pushNamed(context, AssetPage.route),
        )
      ]
    )
  );
}

final List<String> itemButtonsList = [
  'topup',
  'withdraw',
  'lock',
  'signal',
  'claim',
];

Widget itemButtons(context){
  var dic = I18n.of(context).assets;

  return DefaultTabController(
    length: itemButtonsList.length,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TabBar(
        isScrollable: true,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        // indicator: BoxDecoration(
        //   border: Border.all(
        //     style: BorderStyle.solid
        //   )
        // ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.black38,
        tabs: itemButtonsList.map((btnName) {
          return Tab(
            // text: itemTab,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
              decoration: BoxDecoration( 
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5
                ),
                // borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(dic[btnName]),
            ),
          );
        }).toList(),
        onTap: (index) => _tapBtns(context,index)
      )
    )
  );
}

void _tapBtns(context,index){
  String name = itemButtonsList[index];
  switch(name){
    case 'topup':

      break;
    case 'withdraw':

      break;
    case 'signal':
      Navigator.pushNamed(context, SignalPage.route);
      break;
    case 'lock':
      Navigator.pushNamed(context, LockPage.route);
      break;
    case 'claim':
      Navigator.pushNamed(context, ClaimPage.route);
      break;
    default:
      break;
  }
}

final List<String> itemTabList = [
  'claim.eligibility',//'claim Eligibility(MXC)',
  'rewards'//'Rewards(DHC)'
];

Widget expandTab(context){
  var dic = I18n.of(context).assets;

  return DefaultTabController(
    length: itemTabList.length,
    child: Column(
      children: <Widget>[
        TabBar(
          onTap: (index){},
          isScrollable: true,
          // indicator: const BoxDecoration(),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black38,
          tabs: itemTabList.map((itemTab) {
            return Tab(
              text: dic[itemTab],
            );
          }).toList(),
        ),
        Container(
          height: 110,
          child: TabBarView(
            children: itemTabList.map((itemTab) {
              return itemTab.contains('claim.eligibility') ? 
              tabCE(context) :
              tabRW(context);
            }).toList()
          )
        )
      ]
    )
  );
}

Widget tabCE(context){
  var dic = I18n.of(context).assets;

  return Center(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              content(
                '',
              ),
              content(
                dic['approved']
              ),
              content(
                dic['pending']
              ),
              content(
                dic['rejected']
              ),
            ]
          ),
          Row(
            children: <Widget>[
              content(
                dic['locked']
              ),
              content(
                '370(37%)',
                color: Colors.green
              ),
              content(
                '53%',
                color: Colors.orange
              ),
              content(
                '10%',
                color: Colors.red
              ),
            ]
          ),
          Row(
            children: <Widget>[
              content(
                dic['signaled']
              ),
              content(
                '0(0%)',
                color: Colors.grey
              ),
              content(
                '100%',
                color: Colors.orange
              ),
              content(
                '0%',
                color: Colors.grey
              ),
            ]
          ),
        ]
      ),
    )
  );
}

Widget tabRW(context){
  var dic = I18n.of(context).assets;

  return Center(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              content(
                dic['staking']
              ),
              content(
                'MSB',
              ),
              content(
                dic['total']
              ),
            ]
          ),
          Row(
            children: <Widget>[
              content(
                '24000',
              ),
              content(
                '1.025',
              ),
              content(
                '2460',
                color: Colors.green
              ),
            ]
          ),
        ]
      ),
    )
  );
}

Widget content(text,{color = Colors.black,fontWeight = FontWeight.normal}){
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: fontWeight
        ),
      ),
    ),
  );
}