import 'dart:async';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/bazaar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/mocks/api/apiIpfsBazaar.dart';

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
  Future<IpfsBusiness> futureBusiness;

  String getImageAdress(String imageHash) {
    return '$ipfs_gateway_encointer/ipfs/$imageHash';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: RoundedCard(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Observer(
            builder: (_) => (store.encointer.businessRegistry == null)
                ? CupertinoActivityIndicator()
                : (store.encointer.businessRegistry.isEmpty)
                    ? Text("no shops found")
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: store.encointer.businessRegistry == null ? 0 : store.encointer.businessRegistry.length,
                        itemBuilder: (BuildContext context, int index) {

                          futureBusiness = BazaarIpfsApiMock.getBusiness(store.encointer.businessRegistry[index].businessData.url);

                          return FutureBuilder<IpfsBusiness>(
                            future: futureBusiness,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Card(
                                  // Todo: @armin the image should actually be another future that is returned by
                                  // BazaarIpfsAPiMock.getImage();
                                  child: ListTile(
                                    leading: Image.asset(
                                      snapshot.data.imagesCid,
                                      fit: BoxFit.fill,
                                      width: 85,
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
      ),
    );
  }
}
