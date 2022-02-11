import 'dart:async';

import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/businessFormState.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'imagePickerState.dart';
import 'imagePreview.dart';

class ImagePickerScaffold extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final businessFormState = Provider.of<BusinessFormState>(context);
    final imagePickerState = businessFormState.imagePickerState;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).translationsForLocale().bazaar.imagesAddRemove),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(imagePickerState),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Text(
                        I18n.of(context).translationsForLocale().bazaar.waiting,
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return ImagePreview();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return Text(
                          I18n.of(context).translationsForLocale().bazaar.imageNotPicked,
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : ImagePreview(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(
                  imagePickerState,
                  ImageSource.gallery,
                  context: context,
                );
              },
              heroTag: 'image1',
              tooltip: I18n.of(context).translationsForLocale().bazaar.imagesMultiplePick,
              child: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(imagePickerState, ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: I18n.of(context).translationsForLocale().bazaar.photoTake,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  void _onImageButtonPressed(ImagePickerState state, ImageSource source, {BuildContext context}) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        // maxWidth: maxWidth,
        // maxHeight: maxHeight,
        // imageQuality: quality,
      );
      state.addImage(pickedFile);
    } catch (e) {
      state.pickImageError = e.toString();
    }
  }

  Future<void> retrieveLostData(ImagePickerState imagePickerState) async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type != RetrieveType.video) {
        imagePickerState.addImage(response.file);
      }
    } else {
      imagePickerState.retrieveDataError = response.exception.code;
    }
  }
}
