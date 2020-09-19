import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AssignmentPanel extends StatefulWidget {
  AssignmentPanel(this.store);

  final AppStore store;

  @override
  _AssignmentPanelState createState() => _AssignmentPanelState(store);
}

class _AssignmentPanelState extends State<AssignmentPanel> {
  _AssignmentPanelState(this.store);

  final AppStore store;

  @override
  void initState() {
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
    final int decimals = encointerTokenDecimals;
    return Container(
        width: double.infinity,
        child: RoundedCard(
          margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
          padding: EdgeInsets.all(8),
          child: Column(children: <Widget>[
            FutureBuilder<DateTime>(
                future: webApi.encointer.getNextMeetupTime(),
                builder:
                    (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
                  if (snapshot.hasData) {
                    if (store.encointer.currencyIdentifiers.isEmpty) {
                      store.encointer.setChosenCid("");
                      return Text("no currencies found");
                    }
                    var selectedCid = store.encointer.chosenCid.isEmpty
                        ? store.encointer.currencyIdentifiers[0]
                        : store.encointer.chosenCid;
                    return Observer(
                        builder: (_) => Column(children: <Widget>[
                              store.encointer.meetupIndex != 0
                                  ? Column(children: <Widget>[
                                      Text("You are registered! ",
                                          style:
                                              TextStyle(color: Colors.green)),
                                      /* TODO this causes an endless loop of reloads
                                      FutureBuilder<dynamic>(
                                          future: webApi.encointer
                                              .fetchMeetupRegistry(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<dynamic> snapshot) {
                                            if (snapshot.hasData) {
                                              return Text("with " +
                                                  (snapshot.data.length - 1)
                                                      .toString() +
                                                  " others");
                                            } else {
                                              return CupertinoActivityIndicator();
                                            }
                                          }),*/
                                      Text("Ceremony will take place on:"),
                                      Text(new DateTime
                                                  .fromMillisecondsSinceEpoch(
                                              store.encointer.nextMeetupTime)
                                          .toIso8601String()),
                                      Text("at location:"),
                                      Text(
                                          (store.encointer.nextMeetupLocation.lat / (BigInt.from(2).pow(32))
                                          ).toStringAsFixed(3) +
                                          " lat, " +
                                          (store.encointer.nextMeetupLocation.lon/ (BigInt.from(2).pow(32))
                                          ).toStringAsFixed(3) +
                                          " lon"),
                                    ])
                                  : Text(
                                      "You are not registered for ceremony on " +
                                          DateFormat('yyyy-MM-dd').format(
                                              new DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                  store.encointer
                                                      .nextMeetupTime)) +
                                          " for the selected currency",
                                      style: TextStyle(color: Colors.red)),
                            ]));
                  } else {
                    return CupertinoActivityIndicator();
                  }
                })
          ]),
        ));
  }
}
