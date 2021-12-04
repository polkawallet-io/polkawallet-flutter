import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

part 'imagePickerState.g.dart';

class ImagePickerState = _ImagePickerState with _$ImagePickerState;

abstract class _ImagePickerState with Store {
  @observable
  ObservableList<PickedFile> images = new ObservableList<PickedFile>();

  @observable
  String pickImageError;

  @observable
  String retrieveDataError;

  @action
  void addImage(PickedFile image) {
    images.add(image);
  }

  @action
  void removeImage(PickedFile toDelete) {
    images.remove(toDelete);
  }
}
