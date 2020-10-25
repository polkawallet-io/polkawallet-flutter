import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

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
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: RoundedCard(
          margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
          padding: EdgeInsets.all(8),
          child: Column(children: <Widget>[
            Text("Choose currency:"),
            Observer(
                builder: (_) => (store.encointer.currencyIdentifiers == null)
                ? CupertinoActivityIndicator()
                : (store.encointer.currencyIdentifiers.isEmpty)
                    ? Text("no currencies found")
                    : DropdownButton<dynamic>(
                              value: (store.encointer.chosenCid.isEmpty ||
                                      !store.encointer.currencyIdentifiers
                                          .contains(store.encointer.chosenCid))
                                  ? store.encointer.currencyIdentifiers[0]
                                  : store.encointer.chosenCid,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 32,
                              elevation: 32,
                              onChanged: (newValue) {
                                setState(() {
                                  store.encointer.setChosenCid(newValue);
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
                            ))
          ]),
        ));
  }
}
