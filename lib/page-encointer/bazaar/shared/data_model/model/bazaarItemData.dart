import 'package:flutter/material.dart';
import "package:latlong2/latlong.dart";

/// A BazaarItem can either be an offering or a business.
/// info contains the price in case of an offering and the distance in case of a business
abstract class BazaarItemData {
  BazaarItemData(this.title, this.description, this.keywords, this.image);

  final String title;
  final String description;
  final List<Keyword> keywords;
  final Image image;

  Color get cardColor;

  Icon get icon;

  String get info;
}

class BazaarOfferingData extends BazaarItemData {
  final double price;
  final List<DeliveryOption> availableDeliveryOptions;
  final List<UsageState> availableUsageStates;

  BazaarOfferingData(
      title, description, keywords, image, this.price, this.availableDeliveryOptions, this.availableUsageStates)
      : super(title, description, keywords, image);

  @override
  String get info => price.toString();

  @override
  Color get cardColor => Colors.red[300];

  @override
  Icon get icon => Icon(Icons.local_offer);
}

enum DeliveryOption {
  mailOrder,
  pickUp,
}

enum UsageState { brandNew, used }

class BazaarBusinessData extends BazaarItemData {
  final LatLng coordinates;
  final OpeningHours openingHours;
  final List<BazaarOfferingData> offerings;

  // for now:
  final LatLng turbinenplatz = LatLng(47.389712, 8.517076); // TODO use coordinates of the respective community

  BazaarBusinessData(title, description, keywords, image, this.coordinates, this.openingHours, this.offerings)
      : super(title, description, keywords, image);

  @override
  String get info {
    final Distance distance = new Distance();
    final double distanceInMeters = distance(turbinenplatz, coordinates);
    return distanceInMeters.toStringAsFixed(0) + "m";
  }

  @override
  Color get cardColor => Colors.blue[300];

  @override
  Icon get icon => Icon(Icons.business);
}

/// associated keywords (rather than a single category) cf. discussion https://github.com/encointer/encointer-wallet-flutter/issues/233
enum Keyword {
  food,
  cloths,
  furniture,
  tool,
  device,
  vehicle,
  electronics,
  software,
  service,
  finance,
  commodity,
  outdoors,
  livingRoom,
  kitchen,
  workshop,
  garage,
  bedroom,
  bathroom,
  cooking,
  cleaning,
  grooming,
  playing,
  learning,
  gaming,
  sport,
  leisure,
  spring,
  summer,
  autumn,
  winter,
  forWomen,
  forMen,
  forChildren,
  forAnimals,
}

class OpeningHours {
  /// 0 -> Mon, 1 -> Tue, ... 6 -> Sun
  final OpeningHoursForDay mon;
  final OpeningHoursForDay tue;
  final OpeningHoursForDay wed;
  final OpeningHoursForDay thu;
  final OpeningHoursForDay fri;
  final OpeningHoursForDay sat;
  final OpeningHoursForDay sun;

  OpeningHours(this.mon, this.tue, this.wed, this.thu, this.fri, this.sat, this.sun);

  OpeningHoursForDay getOpeningHoursFor(int day) {
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

/// EmptyList means closed
/// You can have as many (disjoint) OpeningIntervals per day as you please.
class OpeningHoursForDay {
  final List<OpeningInterval> openingIntervals;

  OpeningHoursForDay(this.openingIntervals);

  addInterval(OpeningInterval interval) {
    openingIntervals.add(interval);
  }

  removeInterval(int index) {
    openingIntervals.removeAt(index);
  }

  /// where 0 -> Mon, 1 -> Tue, ...
  @override
  String toString() {
    String asString = '';
    if (openingIntervals.length == 0) {
      asString += "(closed)";
    } else {
      for (var i = 0; i < openingIntervals.length; i++) {
        asString += openingIntervals[i].toString();
        asString += i < openingIntervals.length - 1 ? ', ' : '';
      }
    }
    return asString;
  }
}

/// start and end in minutes since midnight of that day
class OpeningInterval {
  final int start;
  final int end;

  /// example "8:00-12:00" or "8:00 - 12:00"
  OpeningInterval.fromString(String startEndTime)
      : start = _parseTime(startEndTime, 0),
        end = _parseTime(startEndTime, 1);

  OpeningInterval(this.start, this.end);

  static int _parseTime(String startEndTime, int part) {
    var startEnd = startEndTime.split('-');
    var time = startEnd[part].trim();
    var minutes = int.parse(
      time.substring(time.length - 2),
    );
    var hours = int.parse(
      time.substring(0, time.length - 3),
    );
    return (hours * 60 + minutes) % (24 * 60);
  }

  @override
  String toString() {
    return (start ~/ 60).toString() +
        ":" +
        (start % 60 + 100).toString().substring(1) +
        " - " +
        (end ~/ 60).toString() +
        ":" +
        (end % 60 + 100).toString().substring(1);
  }
}
