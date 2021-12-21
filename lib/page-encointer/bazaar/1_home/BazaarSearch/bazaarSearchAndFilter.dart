import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/model/bazaarItemData.dart';

class BazaarSearchAndFilter {
  // TODO use this class in BazaarSearch widget
  final allBazaarItems;

  BazaarSearchAndFilter(this.allBazaarItems);

  /// search character sequences in item title and optionally also in description
  List<BazaarItemData> findItemsContainingIgnoringCase(String query, bool searchInDescriptionToo) {
    final List<String> searchTermsLowerCase = query.trim().toLowerCase().split(RegExp(r"\W"));
    return allBazaarItems.where((item) {
      var input = searchInDescriptionToo ? '${item.title} ${item.description}' : item.title;
      return stringContainsIgnoreCase(input, searchTermsLowerCase);
    }).toList();
  }

  bool stringContainsIgnoreCase(input, List<String> searchTermsLowerCase) {
    var lowerCase = input.toLowerCase();
    for (var term in searchTermsLowerCase) {
      if (lowerCase.contains(term)) return true;
    }
    return false;
  }

  /// search words (enclosed by word bounds cf regex, or in camel/pascal case) in the title and optionally also in the
  /// description
  List<BazaarItemData> findItemsContainingWords(String query, bool searchInDescriptionToo) {
    final List<String> searchTerms = query.trim().toLowerCase().split(RegExp(r"\W"));
    return allBazaarItems.where((item) {
      var input = searchInDescriptionToo ? '${item.title} ${item.description}' : item.title;
      return stringContainsWords(input, searchTerms);
    }).toList();
  }

  /// returns true if input contains any of the search terms as a word (word bounds or camel/pascal cased)
  bool stringContainsWords(input, List<String> searchTerms) {
    var lowerCase = input.replaceAllMapped(RegExp(r"\B([A-Z])"), (match) {
      return ' ${match.group(0)}';
    }).toLowerCase();
    for (var term in searchTerms) {
      if (lowerCase.contains(RegExp("\\b$term\\b"))) return true;
    }
    return false;
  }

  /// filters search results to further constrain the search.
  /// keywords: has to contain at least one of the keywords, if keywords is null or an empty list -> no constraint
  /// deliveryOptions: has to contain at least one of the delivery option(s), if deliveryOption is null -> no constraint
  /// usageState: has to contain at least one of the required usage state, if usageState is null -> no constraint
  List<BazaarItemData> filterSearchResults(
    List<BazaarItemData> searchResults,
    List<Keyword> keywords,
    List<DeliveryOption> deliveryOptions,
    List<UsageState> usageStates,
  ) {
    return searchResults.where((item) {
      var keywordsConstraintSatisfied = checkKeywordConstraint(keywords, item);
      var deliveryOptionsConstraintSatisfied = checkDeliveryOptionsConstraint(deliveryOptions, item);
      var usageStatesConstraintSatisfied = checkUsageStatesConstraint(usageStates, item);
      return keywordsConstraintSatisfied && deliveryOptionsConstraintSatisfied && usageStatesConstraintSatisfied;
    }).toList();
  }

  /// checks if the item contains any of the requested keywords
  /// keywords: the keywords requested in item, null or empty list means NO CONSTRAINT
  bool checkKeywordConstraint(List<Keyword> keywords, BazaarItemData item) {
    if (keywords == null || keywords.length == 0) return true;
    for (var keyword in keywords) {
      if (item.keywords.contains(keyword)) return true;
    }
    return false;
  }

  /// checks if the item contains any of the requested deliveryOptions
  /// deliveryOptions: the delivery options requested in an BazaarOfferingData item, null or empty list means NO CONSTRAINT
  /// in case the item is a BazaarBusinessData the function returns true.
  bool checkDeliveryOptionsConstraint(List<DeliveryOption> deliveryOptions, BazaarItemData item) {
    if (item is BazaarBusinessData) return true;
    final offeringItem = item as BazaarOfferingData;
    if (deliveryOptions == null || deliveryOptions.length == 0) return true;
    for (var option in deliveryOptions) {
      if (offeringItem.availableDeliveryOptions.contains(option)) {
        return true;
      }
    }
    return false;
  }

  /// checks if the item contains any of the requested usageStates
  /// deliveryOptions: the delivery options requested in an BazaarOfferingData item, null or empty list means NO CONSTRAINT
  /// in case the item is a BazaarBusinessData the function returns true.
  bool checkUsageStatesConstraint(List<UsageState> usageStates, BazaarItemData item) {
    if (item is BazaarBusinessData) return true;
    final offeringItem = item as BazaarOfferingData;
    if (usageStates == null || usageStates.length == 0) return true;
    for (var usageState in usageStates) {
      if (offeringItem.availableUsageStates.contains(usageState)) {
        return true;
      }
    }
    return false;
  }
}
