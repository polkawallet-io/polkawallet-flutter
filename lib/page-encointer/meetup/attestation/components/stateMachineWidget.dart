import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class StateMachineWidget extends StatelessWidget {
  StateMachineWidget({
    Key key,
    @required this.otherMeetupRegistryIndex,
    @required this.myMeetupRegistryIndex,
    @required this.otherParty,
    @required this.onBackward,
    @required this.onForwardText,
    @required this.onForward,
  }) : super(key: key);

  final int otherMeetupRegistryIndex;
  final int myMeetupRegistryIndex;
  final String otherParty;

  final Function onBackward;
  final String onForwardText;
  final Function onForward;

  static const backButtonKey = Key("back");
  static const nextButtonKey = Key("next");

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['ceremony']),
        centerTitle: true,
        leading: new IconButton(
          key: backButtonKey,
          icon: new Icon(Icons.arrow_back),
          onPressed: onBackward,
        ),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            RoundedCard(
              // margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("${dic['myself']}: "),
                        //AddressIcon(store.account.currentAddress, size: 64),
                        Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(8.0),
                            //color: Colors.lime,
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Text(myMeetupRegistryIndex.toString()) //AddressIcon(attestation.pubKey, size: 64),
                            ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${dic['attestation.performing.with']}:",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(8.0),
                          //color: Colors.lime,
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              border: Border.all(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: Text(otherMeetupRegistryIndex.toString()) //AddressIcon(attestation.pubKey, size: 64),
                          ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(width: double.infinity, height: 12),
            RoundedCard(
              child: ListTile(
                title: Text("$onForwardText"),
                trailing: IconButton(
                  key: nextButtonKey,
                  icon: new Icon(Icons.navigate_next),
                  onPressed: onForward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
