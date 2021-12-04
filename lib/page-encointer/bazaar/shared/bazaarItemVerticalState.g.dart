// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bazaarItemVerticalState.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BazaarItemVerticalState on _BazaarItemVerticalState, Store {
  final _$likedAtom = Atom(name: '_BazaarItemVerticalState.liked');

  @override
  bool get liked {
    _$likedAtom.reportRead();
    return super.liked;
  }

  @override
  set liked(bool value) {
    _$likedAtom.reportWrite(value, super.liked, () {
      super.liked = value;
    });
  }

  final _$_BazaarItemVerticalStateActionController = ActionController(name: '_BazaarItemVerticalState');

  @override
  void toggleLiked() {
    final _$actionInfo =
        _$_BazaarItemVerticalStateActionController.startAction(name: '_BazaarItemVerticalState.toggleLiked');
    try {
      return super.toggleLiked();
    } finally {
      _$_BazaarItemVerticalStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
liked: ${liked}
    ''';
  }
}
