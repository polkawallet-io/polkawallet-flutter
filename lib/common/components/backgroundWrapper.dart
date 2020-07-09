import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  BackgroundWrapper(this.image, this.child);

  final AssetImage image;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).canvasColor,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.topLeft,
              image: image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
