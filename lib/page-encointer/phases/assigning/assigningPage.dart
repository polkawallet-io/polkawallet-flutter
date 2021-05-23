import 'dart:async';

import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:encointer_wallet/page-encointer/meetup/startMeetup.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

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
    Map dic = I18n.of(context).encointer;

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
                child: RoundedButton(
                  text: timeToMeetup > 60
                      ? "${dic['meetup.remaining']} ${Fmt.hhmmss(timeToMeetup)}"
                      : dic['meetup.start'],
                  onPressed: timeToMeetup > 60 ? null : () => startMeetup(context, store),
                ))
            : Container(),
      ]),
    );
  }
}
