import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

class ImagePickerHandler extends StatelessWidget {
  static final String route = '/encointer/imagePickerHandler';

  Future<void> _openCamera(BuildContext context) async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      File imageFile = File(image.path);
      // TODO: app crashes when image cropper is opened
      // File croppedImage = await _cropImage(image);
      _setStateAndReturn(context, imageFile);
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      File imageFile = File(image.path);
      // TODO: app crashes when image cropper is opened
      // File croppedImage = await _cropImage(imageFile);
      _setStateAndReturn(context, imageFile);
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  // Future<File> _cropImage(File image) async {
  //   File croppedFile = await ImageCropper.cropImage(
  //     sourcePath: image.path,
  //     //ratioX: 1.0,
  //     //ratioY: 1.0,
  //     // TODO: set reasonable picture size
  //     maxWidth: 512,
  //     maxHeight: 512,
  //   );
  //   return croppedFile;
  // }

  void _setStateAndReturn(BuildContext context, File image) {
    Navigator.pop(context, image);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).bazaar;

    return Scaffold(
        //type: MaterialType.transparency,
        backgroundColor: Colors.black.withOpacity(0.85),
        body: Opacity(
          opacity: 1,
          child: Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => _openCamera(context),
                  child: roundedButton(dic['camera.default'], EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF167F67), const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _openGallery(context),
                  child: roundedButton(dic['gallery.default'], EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF167F67), const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, null),
                  child: roundedButton(dic['cancel.default'], EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF167F67), const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(100.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }
}
