import 'dart:async';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shop/shopClass.dart';
import 'package:encointer_wallet/common/consts/settings.dart';

class ShopOverviewPanel extends StatefulWidget {
  ShopOverviewPanel(this.store);

  static const String route = '/encointer/bazaar/shopOverviewPanel';
  final AppStore store;

  @override
  _ShopOverviewPanelState createState() => _ShopOverviewPanelState(store);
}

class _ShopOverviewPanelState extends State<ShopOverviewPanel> {
  _ShopOverviewPanelState(this.store);

  final AppStore store;
  Future<Shop> futureShop;

  String getImageAdress(String imageHash) {
    return '$ipfs_gateway_address/ipfs/$imageHash';
  }

  @override
  Widget build(BuildContext context) {
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // Height (without SafeArea)
    var padding = MediaQuery.of(context).padding;
    double height1 = height - padding.top - padding.bottom;
    return Container(
      child: RoundedCard(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Text("Show shops:"),
            Observer(
              builder: (_) => (store.encointer.shopRegistry == null)
                  ? CupertinoActivityIndicator()
                  : (store.encointer.shopRegistry.isEmpty)
                      ? Text("no shops found")
                      : Container(
                          height: height1 / 1.9,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: store.encointer.shopRegistry == null ? 0 : store.encointer.shopRegistry.length,
                            itemBuilder: (BuildContext context, int index) {
                              futureShop = Shop().getShopData(store.encointer.shopRegistry[index]);
                              return FutureBuilder<Shop>(
                                future: futureShop,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Card(
                                      child: ListTile(
                                        leading: Image.network(
                                          getImageAdress(snapshot.data.imageHash),
                                          fit: BoxFit.fill,
                                          width: 100,
                                          height: 100,
                                          alignment: Alignment.center,
                                        ),
                                        title: Text(snapshot.data.name),
                                        subtitle: Text(snapshot.data.description),
                                      ),
                                    );
                                    //return Text(snapshot.data.name);
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  }
                                  // By default, show a loading spinner.
                                  return CircularProgressIndicator();
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
