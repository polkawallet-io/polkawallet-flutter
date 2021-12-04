import 'package:flutter/material.dart';

class ToggleButtonsWithTitle extends StatelessWidget {
  final List<String> items;
  final List<bool> isSelected;
  final Function(int) onPressed;
  final String title;
  final allSelected = false;

  ToggleButtonsWithTitle(
    this.title,
    this.items,
    this.onPressed, {
    Key key,
  })  : isSelected = List.filled(items.length, false),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        child: SizedBox(
          height: 60,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            ToggleButtons(
              children: items
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Text(cat),
                    ),
                  )
                  .toList(),
              // TODO add proper state management, add logic for "all" and other categories
              onPressed: (int index) => onPressed(index),
              isSelected: isSelected,
            ),
          ]),
        ),
      ),
    ]);
  }
}
