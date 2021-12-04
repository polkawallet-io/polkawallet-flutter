import 'package:flutter/material.dart';
import "package:latlong2/latlong.dart";

import '../model/bazaarItemData.dart';

final List<BazaarOfferingData> allOfferings = [
  BazaarOfferingData("Big Ass TV", "This screen takes home cinema to the next level. 8000x6000px, 60fps, asfd asdf",
      2299.95, Image.network('https://picsum.photos/id/123/160/100')),
  BazaarOfferingData(
      "Aliquam auctor",
      "Aliquam auctor mi et nulla sodales pharetra. Proin ultrices eros quis sapien vehicula molestie. Fusce est odio, semper sit amet aliquet id, semper eu sapien. Suspendisse potenti. Aenean laoreet rutrum malesuada. Mauris tincidunt nisi cursus mauris placerat luctus. ",
      230,
      Image.network('https://picsum.photos/id/1016/160/100')),
  BazaarOfferingData(
      "Integer tincidunt",
      "Integer tincidunt dictum lectus, a porttitor mauris rhoncus et. "
          "Donec quis egestas quam. Ut fermentum ultrices nisi eu vulputate. "
          "Nullam luctus ac risus a mattis. Suspendisse fringilla tellus nisl",
      423000,
      Image.network('https://picsum.photos/id/142/160/100')),
  BazaarOfferingData(
      "libero lacinia",
      ", id auctor libero lacinia nec. Nam convallis tincidunt sagittis. "
          "Vivamus quis lacinia neque, sed vestibulum eros. Morbi in arcu pulvinar, "
          "semper metus vel, pretium nisl. Aenean risus metus, lacinia pellentesque ",
      25,
      Image.network('https://picsum.photos/id/125/160/100')),
  BazaarOfferingData(
      "asffgdh ", "Tasfd safd sfda sda sfdasfghdd el", 42, Image.network('https://picsum.photos/id/1016/160/100')),
  BazaarOfferingData("Stamp Collection", "A invaluable selection of beautiful antique stamps", 333.35,
      Image.network('https://picsum.photos/id/222/160/100')),
  BazaarOfferingData(
      "porta vitae",
      "mattis id, porta vitae ligula. Interdum et malesuada fames "
          "ac ante ipsum primis in faucibus. Sed sodales tellus faucibus "
          "interdum feugiat. Suspendisse rutrum nibh quis diam rutrum "
          "consequat ac et justo.",
      423000,
      Image.network('https://picsum.photos/id/142/160/100')),
  BazaarOfferingData("one way trip", "Very expensive trip with no return", 12000000,
      Image.network('https://picsum.photos/id/142/160/100')),
  BazaarOfferingData("Wholemeal Spelt Bread", "Rich spelt bread made according to old rediscovered recipe", 3.75,
      Image.network('https://picsum.photos/id/223/160/100')),
  BazaarOfferingData("White Bread", "Good bread bla bla bla bla bla bla bla bla", 1.00,
      Image.network('https://picsum.photos/id/225/160/100')),
  BazaarOfferingData("Wholemeal Spelt Bread", "Rich spelt bread made according to old rediscovered recipe", 3.75,
      Image.network('https://picsum.photos/id/225/160/100')),
  BazaarOfferingData("Vivamus nisl", "Vivamus nisl ligula, lacinia sed justo non, varius auctor risus. ", 3.75,
      Image.network('https://picsum.photos/id/225/160/100')),
  BazaarOfferingData(
      "Nam laoreet",
      "Nam laoreet turpis quis lacus euismod, id convallis augue cursus. "
          "Morbi sit amet nulla tempor, euismod felis at, mollis lectus. ",
      3.75,
      Image.network('https://picsum.photos/id/225/160/100')),
  BazaarOfferingData(
      "Nam laoreet",
      "Proin ut porta sapien. Morbi sed est malesuada, elementum massa vel, "
          "condimentum augue. Integer vestibulum massa lectus, ac sollicitudin"
          " arcu eleifend id. Nullam est dolor, aliquam at faucibus nec,"
          " viverra a enim. ",
      3.75,
      Image.network('https://picsum.photos/id/225/160/100')),
  BazaarOfferingData(
      "Etiam tempus",
      "Etiam tempus est ornare dolor fringilla ultrices. "
          "Suspendisse quis urna vitae mi porttitor venenatis at a magna. "
          "Vestibulum a magna vitae diam molestie iaculis. Phasellus neque tellus, "
          "facilisis et viverra quis, gravida ac mauris. In varius erat quis "
          "pellentesque tristique. ",
      3.75,
      Image.network('https://picsum.photos/id/225/160/100')),
];

final List<BazaarBusinessData> allBusinesses = [
  BazaarBusinessData(
    "SpaceX",
    "Offering one way trips to Mars",
    LatLng(47.386196, 8.5221215),
    Image.network('https://picsum.photos/id/124/160/100'),
    OpeningHours(
      OpeningHoursForDay([OpeningInterval.fromString("8:00-12:00"), OpeningInterval.fromString("13:30-15:30")]),
      OpeningHoursForDay([]),
      OpeningHoursForDay([OpeningInterval.fromString("8:00-12:00")]),
      OpeningHoursForDay([
        OpeningInterval.fromString("8:00-12:00"),
        OpeningInterval.fromString("13:30-15:30"),
        OpeningInterval.fromString("19:00-22:00")
      ]),
      OpeningHoursForDay([]),
      OpeningHoursForDay([]),
      OpeningHoursForDay([]),
    ),
    <BazaarOfferingData>[allOfferings[7]],
  ),
  BazaarBusinessData(
    "Bakery Meier",
    "Bread, Croissants,  Lorem ipsum dolor sit amet, consectetur adipiscing "
        "elit. Quisque hendrerit dolor orci, porttitor gravida nisl efficitur "
        "eu. Nullam augue orci, bibendum ac vestibulum eget, suscipit eget mi."
        " Morbi lacinia felis nec congue faucibus. Sed mattis tincidunt metus,"
        " ut ullamcorper risus scelerisque sed. Pellentesque scelerisque lacus"
        " vitae ex dapibus sollicitudin. Aliquam at iaculis velit. Curabitur "
        "commodo tellus vitae lorem tempor luctus. Cras a turpis eget diam "
        "ultricies viverra at faucibus nisi. Maecenas et congue diam, vitae ",
    LatLng(47.3907783, 8.5179741),
    Image.network('https://picsum.photos/id/1016/160/100'),
    OpeningHours(
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("7:00-17:00")]),
        OpeningHoursForDay([])),
    <BazaarOfferingData>[allOfferings[8], allOfferings[9], allOfferings[10]],
  ),
  BazaarBusinessData(
      "Galaxus",
      "Der Schweizer Online-Marktführer digitec ist Spezialist in Sachen IT, "
          "Unterhaltungselektronik und Telekommunikation. Galaxus als grösstes "
          "Online-Warenhaus der Schweiz führt ein ständig wachsendes Sortiment "
          "mit Produkten für fast alle alltäglichen und nicht alltäglichen "
          "Bedürfnisse. Stets zu tiefen Preisen und zuverlässig, schnell und "
          "kostenfrei geliefert.",
      LatLng(47.3906821, 8.5149569),
      Image.network('https://picsum.photos/id/1016/160/100'),
      OpeningHours(
        OpeningHoursForDay([OpeningInterval.fromString("9:00-19:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("9:00-19:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("9:00-19:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("9:00-19:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("9:00-19:00")]),
        OpeningHoursForDay([OpeningInterval.fromString("9:00-17:00")]),
        OpeningHoursForDay([]),
      ),
      <BazaarOfferingData>[allOfferings[11], allOfferings[12]]),
  BazaarBusinessData(
      "Coop Supermarkt Zürich Puls 5",
      "Fruits, legumes, bread, meat, fish, sweets, beverages. Self-Checkout, TWINT.",
      LatLng(47.3907031, 8.5183213),
      Image.network('https://picsum.photos/id/1016/160/100'),
      OpeningHours(
          OpeningHoursForDay([OpeningInterval.fromString("7:00-20:00")]),
          OpeningHoursForDay([OpeningInterval.fromString("7:00-20:00")]),
          OpeningHoursForDay([OpeningInterval.fromString("7:00-20:00")]),
          OpeningHoursForDay([OpeningInterval.fromString("7:00-20:00")]),
          OpeningHoursForDay([OpeningInterval.fromString("7:00-20:00")]),
          OpeningHoursForDay([OpeningInterval.fromString("8:00-18:00")]),
          OpeningHoursForDay([])),
      <BazaarOfferingData>[allOfferings[2], allOfferings[3]]),
  BazaarBusinessData(
      "PhotoPro Johnson",
      "Professional Portraits, Wedding photography, Company events, etc.",
      LatLng(47.3900911, 8.5128345),
      Image.network('https://picsum.photos/id/1011/160/100'),
      OpeningHours(
        OpeningHoursForDay([OpeningInterval.fromString("8:00-12:00"), OpeningInterval.fromString("13:30-15:30")]),
        OpeningHoursForDay([]),
        OpeningHoursForDay([OpeningInterval.fromString("8:00-12:00")]),
        OpeningHoursForDay([
          OpeningInterval.fromString("8:00-12:00"),
          OpeningInterval.fromString("13:30-15:30"),
          OpeningInterval.fromString("19:00-22:00")
        ]),
        OpeningHoursForDay([]),
        OpeningHoursForDay([]),
        OpeningHoursForDay([]),
      ),
      <BazaarOfferingData>[allOfferings[14]])
];

final List<BazaarItemData> newInBazaar = [allOfferings[0], allBusinesses[2], allOfferings[1], allOfferings[2]];
final List<BazaarBusinessData> businessesInVicinity = [
  allBusinesses[2],
  allBusinesses[3],
  allBusinesses[4],
];

final List<BazaarItemData> lastVisited = [allOfferings[0], allBusinesses[0], allOfferings[1]];

final List<BazaarItemData> favorites = [
  allOfferings[2],
  allBusinesses[0],
  allOfferings[4],
];

final List<BazaarItemData> myOfferings = [
  allOfferings[1],
  allOfferings[2],
];

final List<BazaarItemData> myBusinesses = [
  allBusinesses[4],
];

final List<BazaarItemData> searchResultsInBusinesses = [
  allBusinesses[0],
  allBusinesses[1],
  allBusinesses[2],
  allBusinesses[3],
  allBusinesses[4],
];

final List<BazaarItemData> searchResultsInOfferings = [
  allOfferings[0],
  allOfferings[1],
  allOfferings[2],
  allOfferings[3],
  allOfferings[4],
  allOfferings[5],
];

final allCategories = ["All", "Food", "Furniture", "Electronics", "Tools", "Cloths", "Other", "Blablabla"];

final allDeliveryOptions = ["Delivery", "Pickup"];

final allProductNewnessOptions = ["New", "Second hand"];
