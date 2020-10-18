import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/utils/i18n/index.dart';


class ConfirmAttendeesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Grid List';
    final Map dic = I18n.of(context).encointer;

    return Scaffold(
        appBar: AppBar(
          title: Text(dic['ceremony']),
          centerTitle: true,
        ),
        backgroundColor:Theme.of(context).canvasColor,
        body: SafeArea(
          child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'How many attendees are present?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: RoundedCard(
                    margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: GridView.count(
                      // Create a grid with 2 columns.
                      crossAxisCount: 2,
                      childAspectRatio: 4/2,
                      children: List.generate(10, (index) {
                        var value = index +3;
                        return Center(
                            child: CupertinoButton(
                                child: Text(value.toString()),
                                onPressed: () {
                                  Navigator.of(context).pop(value);
                                }
                            )
                        );
                      }),
                    ),
                  ),
                ),
              ]
          ),
        )
    );
  }
}