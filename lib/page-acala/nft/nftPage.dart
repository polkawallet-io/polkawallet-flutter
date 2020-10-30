import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class NFTPage extends StatefulWidget {
  NFTPage(this.store);

  static const String route = '/acala/nft';
  final AppStore store;

  @override
  _NFTPageState createState() => _NFTPageState();
}

class _NFTPageState extends State<NFTPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _nftMap = {
    'level_1': 'https://api.polkawallet.io/nft/img/nft01.jpg',
    'level_2': 'https://api.polkawallet.io/nft/img/nft02.jpg',
    'level_3': 'https://api.polkawallet.io/nft/img/nft03.jpg',
  };

  Future<void> _refreshData() async {
    await webApi.acala.fetchUserNFTs();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).acala;
    final imageWidth = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      appBar: AppBar(title: Text('NFTs'), centerTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          child: Observer(
            builder: (_) {
              final list = widget.store.acala.userNFTs;
              list.retainWhere((e) => _nftMap.keys.contains(e['metadata']));
              return ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  return RoundedCard(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: imageWidth,
                          backgroundColor: Colors.black26,
                          child: Container(
                            padding: EdgeInsets.all(imageWidth / 3),
                            child: Image.network(_nftMap[list[i]['metadata']]),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            dic['nft.testnet'],
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
