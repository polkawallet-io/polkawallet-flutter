import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: RoundedCard(
          padding: EdgeInsets.all(8),
          child: Column(children: <Widget>[
            Observer(
                builder: (_) => store.encointer.meetupTime != null
                    ? store.encointer.currencyIdentifiers.isEmpty
                        ? Text("no currencies found")
                        : Column(children: <Widget>[
                            store.encointer.meetupIndex > 0
                                ? Column(children: <Widget>[
                                    Text("You are registered! ", style: TextStyle(color: Colors.green)),
                                    Text("Ceremony will take place on:"),
                                    Text(new DateTime.fromMillisecondsSinceEpoch(store.encointer.meetupTime)
                                        .toIso8601String()),
                                    Text("at location:"),
                                    Text((store.encointer.meetupLocation.lat / (BigInt.from(2).pow(32)))
                                            .toStringAsFixed(3) +
                                        " lat, " +
                                        (store.encointer.meetupLocation.lon / (BigInt.from(2).pow(32)))
                                            .toStringAsFixed(3) +
                                        " lon"),
                                  ])
                                : Text(
                                    "You are not registered for ceremony on " +
                                        DateFormat('yyyy-MM-dd').format(
                                            new DateTime.fromMillisecondsSinceEpoch(store.encointer.meetupTime)) +
                                        " for the selected currency",
                                    style: TextStyle(color: Colors.red)),
                          ])
                    : CupertinoActivityIndicator())
          ]),
        ));
  }
}
