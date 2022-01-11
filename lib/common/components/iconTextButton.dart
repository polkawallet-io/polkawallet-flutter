import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Function onTap;
  final double iconSize;

  const IconTextButton({
    this.text,
    this.iconData,
    this.onTap,
    this.iconSize = 36,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // TODO
      child: Column(
        children: [
          Icon(
            iconData,
            color: Colors.grey,
            size: iconSize,
          ),
          Text(
            text,
          ),
        ],
      ),
    );
  }
}

/// TODO replace by a more advanced graphical representation of the community
class CommunityIcon extends StatelessWidget {
  const CommunityIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 96,
      onPressed: null,
      icon: Text(
        "L",
        textScaleFactor: 4,
      ),
    );
  }
}
