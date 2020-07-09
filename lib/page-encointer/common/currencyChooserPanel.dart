import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/page-encointer/attesting/meetupPage.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class CurrencyChooserPanel extends StatefulWidget {
  CurrencyChooserPanel(this.store);

  final AppStore store;

  @override
  _CurrencyChooserPanelState createState() => _CurrencyChooserPanelState(store);
}

class _CurrencyChooserPanelState extends State<CurrencyChooserPanel> {
  _CurrencyChooserPanelState(this.store);

  final AppStore store;

  @override
  void initState() {
    // dropdown menu must include chosen cid even if currencies haven't been fetched
    //store.encointer.setCurrencyIdentifiers([store.encointer.chosenCid]);
    _refreshData();
    super.initState();
  }

  Future<void> _refreshData() async {
    // refreshed by parent!
    //await webApi.encointer.fetchCurrencyIdentifiers();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;
    final int decimals = encointer_token_decimals;
    return Container(
        width: double.infinity,
        child: RoundedCard(
          margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
          padding: EdgeInsets.all(8),
          child: Column(children: <Widget>[
            Text("Choose currency:"),
            FutureBuilder<List<dynamic>>(
                future: webApi.encointer.getCurrencyIdentifiers(),
                builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    if (store.encointer.currencyIdentifiers.isEmpty) {
                      store.encointer.setChosenCid("");
                      return Text("no currencies found");
                    }
                    var selectedCid = store.encointer.chosenCid.isEmpty
                        ? store.encointer.currencyIdentifiers[0]
                        : store.encointer.chosenCid;
                    return Observer(
                        builder: (_) => DropdownButton<dynamic>(
                              value: selectedCid,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 32,
                              elevation: 32,
                              onChanged: (newValue) {
                                setState(() {
                                  store.encointer.setChosenCid(newValue);
                                  _refreshData();
                                });
                              },
                              items: store.encointer.currencyIdentifiers
                                  .map<DropdownMenuItem<dynamic>>((value) =>
                                      DropdownMenuItem<dynamic>(
                                        value: value,
                                        child:
                                            Text(Fmt.currencyIdentifier(value)),
                                      ))
                                  .toList(),
                            ));
                  } else {
                    return CupertinoActivityIndicator();
                  }
                })
          ]),
        ));
  }
}
