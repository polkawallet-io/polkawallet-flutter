// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imagePickerState.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ImagePickerState on _ImagePickerState, Store {
  final _$imagesAtom = Atom(name: '_ImagePickerState.images');

  @override
  ObservableList<PickedFile> get images {
    _$imagesAtom.reportRead();
    return super.images;
  }

  @override
  set images(ObservableList<PickedFile> value) {
    _$imagesAtom.reportWrite(value, super.images, () {
      super.images = value;
    });
  }

  final _$pickImageErrorAtom = Atom(name: '_ImagePickerState.pickImageError');

  @override
  String get pickImageError {
    _$pickImageErrorAtom.reportRead();
    return super.pickImageError;
  }

  @override
  set pickImageError(String value) {
    _$pickImageErrorAtom.reportWrite(value, super.pickImageError, () {
      super.pickImageError = value;
    });
  }

  final _$retrieveDataErrorAtom = Atom(name: '_ImagePickerState.retrieveDataError');

  @override
  String get retrieveDataError {
    _$retrieveDataErrorAtom.reportRead();
    return super.retrieveDataError;
  }

  @override
  set retrieveDataError(String value) {
    _$retrieveDataErrorAtom.reportWrite(value, super.retrieveDataError, () {
      super.retrieveDataError = value;
    });
  }

  final _$_ImagePickerStateActionController = ActionController(name: '_ImagePickerState');

  @override
  void addImage(PickedFile image) {
    final _$actionInfo = _$_ImagePickerStateActionController.startAction(name: '_ImagePickerState.addImage');
    try {
      return super.addImage(image);
    } finally {
      _$_ImagePickerStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeImage(PickedFile toDelete) {
    final _$actionInfo = _$_ImagePickerStateActionController.startAction(name: '_ImagePickerState.removeImage');
    try {
      return super.removeImage(toDelete);
    } finally {
      _$_ImagePickerStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
images: ${images},
pickImageError: ${pickImageError},
retrieveDataError: ${retrieveDataError}
    ''';
  }
}
