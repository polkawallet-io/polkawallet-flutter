import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

class ImagePickerHandler extends StatelessWidget {
  BuildContext context;
  File _imageFile;

  static final String route = '/encointer/imagePickerHandler';

  Future<void> _openCamera() async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.camera);
      File imageFile = File(image.path);
      // TODO: app crashes when image cropper is opened
      // File croppedImage = await _cropImage(image);
      _setStateAndReturn(imageFile);
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  Future<void> _openGallery() async {
    try {
      var image = await ImagePicker().getImage(source: ImageSource.gallery);
      File imageFile = File(image.path);
      // TODO: app crashes when image cropper is opened
      // File croppedImage = await _cropImage(imageFile);
      _setStateAndReturn(imageFile);
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  Future<File> _cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      //ratioX: 1.0,
      //ratioY: 1.0,
      // TODO: set reasonable picture size
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  void _setStateAndReturn(File image) {
    _imageFile = image;
    Navigator.pop(context, _imageFile);
  }

  void _dismiss() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
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
                  onTap: () => _openCamera(),
                  child: roundedButton(dic['camera.default'], EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF167F67), const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _openGallery(),
                  child: roundedButton(dic['gallery.default'], EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF167F67), const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _dismiss(),
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
