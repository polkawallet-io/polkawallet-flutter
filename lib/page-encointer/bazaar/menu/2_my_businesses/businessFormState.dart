import 'package:encointer_wallet/page-encointer/bazaar/menu/camera/imagePickerState.dart';
import 'package:mobx/mobx.dart';

import 'openingHoursState.dart';

part 'businessFormState.g.dart';

class BusinessFormState = _BusinessFormState with _$BusinessFormState;

abstract class _BusinessFormState with Store {
  _BusinessFormState() {
    setupValidators();
  }

  // ************** OBSERVABLES ************************************************
  @observable
  String name;

  @observable
  String description;

  // // TODO how to model categories?

  @observable
  String street;

  /// could be e.g. 7a not just a number hence use String
  @observable
  String streetAddendum;

  @observable
  String zipCode;

  @observable
  String city;

  final openingHours = OpeningHoursState(
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
    OpeningHoursForDayState(ObservableList<OpeningIntervalState>()),
  );

  final errors = BusinessFormErrorState();
  final imagePickerState = ImagePickerState();

  // ************** REACTIONS **************************************************
  List<ReactionDisposer> _disposers;

  void setupValidators() {
    _disposers = [
      reaction((_) => name, validateName),
      reaction((_) => description, validateDescription),
      reaction((_) => street, validateStreet),
      reaction((_) => streetAddendum, validateStreetAddendum),
      reaction((_) => zipCode, validateZipCode),
      reaction((_) => city, validateCity),
    ];
  }

  // ************** ACTIONS ****************************************************
  @action
  void validateName(value) {
    return validateIsNotBlank(value, (errorText) => errors.name = errorText);
  }

  @action
  void validateDescription(value) {
    return validateIsNotBlank(value, (errorText) => errors.description = errorText);
  }

  @action
  void validateStreet(value) {
    return validateIsNotBlank(value, (errorText) => errors.street = errorText);
  }

  @action
  void validateStreetAddendum(value) {
    return validateIsNotBlank(value, (errorText) => errors.streetAddendum = errorText);
  }

  @action
  void validateZipCode(value) {
    return validateIsNotBlank(value, (errorText) => errors.zipCode = errorText);
  }

  @action
  void validateCity(value) {
    return validateIsNotBlank(value, (errorText) => errors.city = errorText);
  }

  // ************** OTHER METHODS **********************************************
  validateIsNotBlank(String value, Function(String) errorTarget) {
    String errorText = value == null || value.trim().isEmpty ? 'Cannot be blank' : null;
    errorTarget(errorText);
  }

  void dispose() {
    for (final disposer in _disposers) {
      disposer();
    }
  }

  /// if the user leaves everything blank the validators would not be triggered
  /// (only on change of the value),
  /// hence upon tapping submit this method should be called
  validateAll() {
    validateName(name);
    validateDescription(description);
    validateStreet(street);
    validateStreetAddendum(streetAddendum);
    validateZipCode(zipCode);
    validateCity(city);
  }
}

/// error messages for input fields
class BusinessFormErrorState = _BusinessFormErrorState with _$BusinessFormErrorState;

abstract class _BusinessFormErrorState with Store {
  @observable
  String name;

  @observable
  String description;

  @observable
  String street;

  @observable
  String streetAddendum;

  @observable
  String zipCode;

  @observable
  String city;

  // // TODO how to model categories?

  @computed
  bool get hasErrors => name != null; // || email != null || ...
}
