import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';

class EntryPageCard extends StatelessWidget {
  EntryPageCard(this.title, this.brief, this.icon, {this.color});

  final Widget icon;
  final String title;
  final String brief;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  bottomLeft: const Radius.circular(8)),
            ),
            child: Center(child: icon),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16),
                width: MediaQuery.of(context).size.width / 2,
                child: Text(
                  brief,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).unselectedWidgetColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
