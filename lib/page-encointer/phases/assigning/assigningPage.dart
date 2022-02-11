import 'dart:async';

import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:encointer_wallet/page-encointer/meetup/startMeetup.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class AssigningPage extends StatefulWidget {
  AssigningPage(this.store);

  static const String route = '/encointer/assigning';
  final AppStore store;

  @override
  _AssigningPageState createState() => _AssigningPageState(store);
}

class _AssigningPageState extends State<AssigningPage> {
  _AssigningPageState(this.store);

  final AppStore store;

  int timeToMeetup;
  StreamSubscription<CountdownTimer> sub;

  @override
  void initState() {
    this.timeToMeetup = store.encointer.getTimeToMeetup();
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: timeToMeetup),
      new Duration(seconds: 1),
    );

    sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        timeToMeetup = duration.remaining.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();

    if (sub == null) {
      startTimer();
    }

    return SafeArea(
      child: Column(children: <Widget>[
        AssignmentPanel(store),
        SizedBox(height: 16),
        store.encointer.meetupIndex != null && store.encointer.meetupIndex > 0
            ? Container(
                key: Key('start-meetup'),
                child: Column(
                  children: <Widget>[
                    RoundedCard(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          "${dic.encointer.meetupRemaining} ${Fmt.hhmmss(timeToMeetup)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    timeToMeetup < 60
                        ? RoundedButton(
                            text: dic.encointer.meetupStart,
                            onPressed: () => startMeetup(context, store),
                          )
                        : Container(),
                  ],
                ),
              )
            : Container(),
      ]),
    );
  }
}
