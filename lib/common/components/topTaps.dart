import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopTabs extends StatelessWidget {
  TopTabs({this.names, this.activeTab, this.onTab});

  final List<String> names;
  final Function(int) onTab;
  final int activeTab;

  // TODO: tab text style
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: names.map(
        (title) {
          int index = names.indexOf(title);
          return GestureDetector(
            child: Column(
              children: <Widget>[
                Container(
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 12,
                  width: 32,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: activeTab == index ? 3 : 0,
                            color: Colors.white)),
                  ),
                )
              ],
            ),
            onTap: () => onTab(index),
          );
        },
      ).toList(),
    );
  }
}
