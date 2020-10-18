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
  bool _isAwaitingFuture = true;
  dynamic futureResult;

  void _awaitFuture() async {
    futureResult = await widget.future;
    Navigator.of(context).pop(futureResult);
    setState(() {
      _isAwaitingFuture = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _awaitFuture();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoAlertDialog(
      title: Text(widget.title),
      content: _isAwaitingFuture ? CupertinoActivityIndicator() : Container(),
    );
  }
}
