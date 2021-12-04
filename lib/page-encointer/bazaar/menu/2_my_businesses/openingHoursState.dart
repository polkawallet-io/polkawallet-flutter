import 'package:mobx/mobx.dart';

part 'openingHoursState.g.dart';

class OpeningHoursState = _OpeningHoursState with _$OpeningHoursState;

abstract class _OpeningHoursState with Store {
  /// 0 -> Mon, 1 -> Tue, ... 6 -> Sun

  @observable
  OpeningHoursForDayState mon;
  @observable
  OpeningHoursForDayState tue;
  @observable
  OpeningHoursForDayState wed;
  @observable
  OpeningHoursForDayState thu;
  @observable
  OpeningHoursForDayState fri;
  @observable
  OpeningHoursForDayState sat;
  @observable
  OpeningHoursForDayState sun;

  @observable
  OpeningHoursForDayState copiedOpeningHours;

  @observable
  int dayOnFocus;

  @observable
  int dayToCopyFrom;

  @action
  copyFrom(int day) {
    if (day == dayToCopyFrom) {
      // tapping the same button again turns copying off and clears clipboard
      dayToCopyFrom = null;
      copiedOpeningHours = null;
    } else {
      dayToCopyFrom = day;
      copiedOpeningHours = getOpeningHoursFor(day);
    }
  }

  @action
  setDayOnFocus(int day) {
    if (day == dayOnFocus) {
      // turn editing off again
      dayOnFocus = null;
    } else {
      dayOnFocus = day;
    }
  }

  @action
  pasteOpeningHoursTo(int day) {
    var target = getOpeningHoursFor(day);
    if (copiedOpeningHours == null) return;

    copiedOpeningHours.openingIntervals.forEach(
      (OpeningIntervalState interval) => target.addInterval(interval),
    );
  }

  _OpeningHoursState(this.mon, this.tue, this.wed, this.thu, this.fri, this.sat, this.sun);

  // generic getter
  OpeningHoursForDayState getOpeningHoursFor(int day) {
    switch (day) {
      case 0:
        return mon;
      case 1:
        return tue;
      case 2:
        return wed;
      case 3:
        return thu;
      case 4:
        return fri;
      case 5:
        return sat;
      case 6:
        return sun;
      default:
        // TODO
        // throw IllegalArgumentException();
        return null;
    }
  }

  /// where 0 -> Mon, 1 -> Tue, ...
  String getDayString(int day) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day];
  }
}

class OpeningHoursForDayState = _OpeningHoursForDayState with _$OpeningHoursForDayState;

/// EmptyList means closed
/// You can have as many (disjoint) OpeningIntervals per day as you please.
abstract class _OpeningHoursForDayState with Store {
  @observable
  ObservableList<OpeningIntervalState> openingIntervals;

  _OpeningHoursForDayState(this.openingIntervals);

  @observable
  String timeFormatError;

  @action
  addParsedIntervalIfValid(String startEnd) {
    try {
      OpeningIntervalState openingIntervalState = _OpeningIntervalState.parseOpeningIntervalState(startEnd);
      timeFormatError = null;
      openingIntervals.add(openingIntervalState);
    } catch (e) {
      timeFormatError = "Invalid time format";
    }
  }

  @action
  addInterval(OpeningIntervalState interval) {
    if (interval == null) return;
    openingIntervals.add(interval);
  }

  @action
  removeInterval(int index) {
    openingIntervals.removeAt(index);
  }

  /// where 0 -> Mon, 1 -> Tue, ...
  /// (pitfall: overriding the toString method of this *abstract* class would
  /// not not be wise, as it will not be called, but instead the toString of the
  /// actually used class with a similar name will be called.)
  String humanReadable() {
    String asString = '';
    if (openingIntervals.length == 0) {
      asString += "(closed)";
    } else {
      for (var i = 0; i < openingIntervals.length; i++) {
        asString += openingIntervals[i].humanReadable();
        asString += i < openingIntervals.length - 1 ? ', ' : '';
      }
    }
    return asString;
  }
}

class OpeningIntervalState = _OpeningIntervalState with _$OpeningIntervalState;

/// start and end in minutes since midnight of that day
abstract class _OpeningIntervalState with Store {
  @observable
  int start;
  @observable
  int end;

  /// example "8:00-12:00" or "8:00 - 12:00"
  static _OpeningIntervalState parseOpeningIntervalState(String startEndTime) {
    return OpeningIntervalState(_parseTimeInterval(startEndTime, 0), _parseTimeInterval(startEndTime, 1));
  }

  _OpeningIntervalState(this.start, this.end);

  static int _parseTimeInterval(String startEndTime, int part) {
    var startEnd = startEndTime.split('-');
    List<int> parsed = [];
    for (var value in startEnd) {
      parsed.add(_parseTime(value.trim()));
    }
    return (parsed[0] < parsed[1]) ? parsed[part % 2] : parsed[(part + 1) % 2];
  }

  static int _parseTime(String time) {
    var timeLowerCase = time.toLowerCase();
    var pm = timeLowerCase.contains("p") ? 12 * 60 : 0;
    var indexOfMeridiem = timeLowerCase.indexOf(RegExp(r"a|p"));
    var timeClean = indexOfMeridiem > 0 ? timeLowerCase.substring(0, indexOfMeridiem) : timeLowerCase;
    var hoursMinutes = timeClean.split(':');
    var hours = int.parse(hoursMinutes[0].trim());

    // 12am is midnight, 12pm is noon.
    hours = (hours == 12 && timeLowerCase.contains("m") ? 0 : hours);
    var minutes = hoursMinutes.length > 1 ? int.parse(hoursMinutes[1].trim()) : 0;
    return (hours * 60 + minutes + pm) % (24 * 60);
  }

  String humanReadable() {
    return (start ~/ 60).toString() +
        ":" +
        (start % 60 + 100).toString().substring(1) +
        " - " +
        (end ~/ 60).toString() +
        ":" +
        (end % 60 + 100).toString().substring(1);
  }
}
