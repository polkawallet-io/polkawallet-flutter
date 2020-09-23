import 'package:flutter/cupertino.dart';

class ActivityIndicator extends StatefulWidget {
  ActivityIndicator({Key key, this.title, this.future}) : super(key: key);

  final String title;
  final Future<dynamic> future;

  @override
  _ActivityIndicatorState createState() {
    return _ActivityIndicatorState();
  }
}

class _ActivityIndicatorState extends State<ActivityIndicator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: widget.future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Navigator.of(context).pop(snapshot.data);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return new CupertinoAlertDialog(title: Text(widget.title));
          }
          return Container();
        });
  }
}
