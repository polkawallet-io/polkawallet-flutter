// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:encointer_wallet/page-encointer/bazaar/1_home/BazaarSearch/bazaarSearchAndFilter.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/model/bazaarItemData.dart';

class TestCaseBazaarSearch {
  final List<BazaarItemData> items;
  final String searchQuery;
  final List<BazaarItemData> expectedOutput;
  final String testDescription;

  TestCaseBazaarSearch(this.items, this.searchQuery, this.expectedOutput, this.testDescription);
}

/// test case for the low level functions
class TestCaseBazaarSearchLowLevelContainsCharSequence {
  final String input;
  final List<String> searchTerms;
  final bool expectedOutput;
  final String testDescription;

  TestCaseBazaarSearchLowLevelContainsCharSequence(
      this.input, this.searchTerms, this.expectedOutput, this.testDescription);
}

/// test case for the low level functions
class TestCaseBazaarSearchLowLevelWord {
  final String input;
  final List<String> searchTerms;
  final bool expectedOutput;
  final String testDescription;

  TestCaseBazaarSearchLowLevelWord(this.input, this.searchTerms, this.expectedOutput, this.testDescription);
}

class TestCaseBazaarFilter {
  final List<BazaarItemData> rawSearchResults;
  final List<Keyword> keywords;
  final List<DeliveryOption> availableDeliveryOptions;
  final List<UsageState> availableUsageStates;
  final List<BazaarItemData> expectedOutput;
  final String testDescription;

  TestCaseBazaarFilter(this.rawSearchResults, this.keywords, this.availableDeliveryOptions, this.availableUsageStates,
      this.expectedOutput, this.testDescription);
}

void main() {
  // constants
  final List<TestCaseBazaarSearchLowLevelContainsCharSequence> lowLevelTestCasesCharSequence =
      <TestCaseBazaarSearchLowLevelContainsCharSequence>[
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "a bone",
      <String>["bone"],
      true,
      "should find the word bone",
    ),
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "stick and Bone",
      <String>["bone"],
      true,
      "should find the word Bone",
    ),
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "four trombones",
      <String>["bone"],
      true,
      "should find the sequence bone in trombones",
    ),
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "four trombones",
      <String>["bone"],
      true,
      "should find the sequence bone in trombones",
    ),
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "FishBoneBucket",
      <String>["bone"],
      true,
      "pascal case",
    ),
    TestCaseBazaarSearchLowLevelContainsCharSequence(
      "bOne",
      <String>["bone"],
      true,
      "ignoring case",
    ),
  ];

  final List<TestCaseBazaarSearchLowLevelWord> lowLevelTestCasesWord = <TestCaseBazaarSearchLowLevelWord>[
    TestCaseBazaarSearchLowLevelWord(
      "a bone",
      <String>["bone"],
      true,
      "should find the word bone",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "stick and Bone",
      <String>["bone"],
      true,
      "should find the word Bone",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "four trombones",
      <String>["bone"],
      false,
      "should ignore the sequence bone in trombones",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "four trombones",
      <String>["bone"],
      false,
      "should ignore the sequence bone in trombones",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "FishBoneBucket",
      <String>["bone"],
      true,
      "pascal case",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "bOne",
      <String>["bone"],
      false,
      "bump case",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "boneFracture",
      <String>["bone"],
      true,
      "bump case",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "BoneFracture",
      <String>["bone"],
      true,
      "bump case",
    ),
    TestCaseBazaarSearchLowLevelWord(
      "fishBone",
      <String>["bone"],
      true,
      "bump case",
    ),
  ];

  final coopItems = <BazaarItemData>[
    BazaarOfferingData("coop super card", null, null, null, null, null, null),
    BazaarBusinessData("myCoop", null, null, null, null, null, null),
    BazaarBusinessData("the coOp", null, null, null, null, null, null),
    BazaarOfferingData("PaccoOppulent", null, null, null, null, null, null),
  ];

  final coopItemsWord = <BazaarItemData>[
    BazaarOfferingData("coop super card", null, null, null, null, null, null),
    BazaarBusinessData("myCoop", null, null, null, null, null, null),
  ];

  final nonCoopItems = <BazaarItemData>[
    BazaarBusinessData("migros", null, null, null, null, null, null),
    BazaarBusinessData("copy shop", null, null, null, null, null, null),
    BazaarOfferingData("car", null, null, null, null, null, null),
    BazaarOfferingData("opaque button", null, null, null, null, null, null),
    BazaarOfferingData("co op", null, null, null, null, null, null),
  ];

  final List<TestCaseBazaarSearch> testCasesIgnoringCase = [
    TestCaseBazaarSearch(
      <BazaarItemData>[...coopItems, ...nonCoopItems],
      "coop",
      coopItems,
      "items containing the char sequence 'Coop' in their name (ignoring case)",
    ),
  ];

  final List<TestCaseBazaarSearch> testCasesWords = [
    TestCaseBazaarSearch(
      <BazaarItemData>[...coopItems, ...nonCoopItems],
      "coop",
      coopItemsWord,
      "items containing the word 'Coop' in their name",
    ),
  ];

  var rawSearchResultsKeywords = <BazaarItemData>[
    BazaarBusinessData("b1", null, <Keyword>[Keyword.winter, Keyword.livingRoom], null, null, null, null),
    BazaarBusinessData("b2", null, <Keyword>[Keyword.summer, Keyword.livingRoom], null, null, null, null),
    BazaarBusinessData(
        "b3", null, <Keyword>[Keyword.cooking, Keyword.food, Keyword.livingRoom], null, null, null, null),
    BazaarBusinessData("b4", null, <Keyword>[Keyword.food], null, null, null, null),
    BazaarBusinessData("b5", null, <Keyword>[Keyword.food, Keyword.summer], null, null, null, null),
  ];

  var rawSearchResultsDeliveryOptions = <BazaarItemData>[
    BazaarBusinessData("b1", null, null, null, null, null, null),
    BazaarOfferingData("o1", null, null, null, null, <DeliveryOption>[], null),
    BazaarOfferingData("o2", null, null, null, null, <DeliveryOption>[DeliveryOption.mailOrder], null),
    BazaarOfferingData("o3", null, null, null, null, <DeliveryOption>[DeliveryOption.pickUp], null),
    BazaarOfferingData(
        "o4", null, null, null, null, <DeliveryOption>[DeliveryOption.mailOrder, DeliveryOption.pickUp], null),
  ];

  var rawSearchResultsUsageStates = <BazaarItemData>[
    BazaarBusinessData("b1", null, null, null, null, null, null),
    BazaarOfferingData("o1", null, null, null, null, <DeliveryOption>[], <UsageState>[]),
    BazaarOfferingData("o2", null, null, null, null, <DeliveryOption>[], <UsageState>[UsageState.used]),
    BazaarOfferingData("o3", null, null, null, null, <DeliveryOption>[], <UsageState>[UsageState.brandNew]),
    BazaarOfferingData(
      "o4",
      null,
      null,
      null,
      null,
      <DeliveryOption>[],
      <UsageState>[UsageState.used, UsageState.brandNew],
    )
  ];

  final List<TestCaseBazaarFilter> testCasesFilterKeywords = [
    TestCaseBazaarFilter(
      rawSearchResultsKeywords,
      <Keyword>[Keyword.summer, Keyword.food],
      <DeliveryOption>[],
      <UsageState>[],
      rawSearchResultsKeywords.sublist(1),
      "summer and food",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsKeywords,
      null,
      <DeliveryOption>[],
      <UsageState>[],
      rawSearchResultsKeywords,
      "No keywords constraint (null) -> should pass all",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsKeywords,
      <Keyword>[],
      <DeliveryOption>[],
      <UsageState>[],
      rawSearchResultsKeywords,
      "No keywords constraint (empty list) -> should pass all",
    ),
  ];

  final List<TestCaseBazaarFilter> testCasesFilterDeliveryOptions = [
    TestCaseBazaarFilter(
      rawSearchResultsDeliveryOptions,
      null,
      null,
      <UsageState>[],
      rawSearchResultsDeliveryOptions,
      "no delivery option constraint (null) -> should pass all",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsDeliveryOptions,
      null,
      <DeliveryOption>[],
      <UsageState>[],
      rawSearchResultsDeliveryOptions,
      "no delivery option constraint (empty list) -> should pass all",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsDeliveryOptions,
      null,
      <DeliveryOption>[DeliveryOption.mailOrder],
      <UsageState>[],
      [
        ...rawSearchResultsDeliveryOptions.sublist(0, 1),
        ...rawSearchResultsDeliveryOptions.sublist(2, 3),
        ...rawSearchResultsDeliveryOptions.sublist(4)
      ],
      "mailOrder",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsDeliveryOptions,
      null,
      <DeliveryOption>[DeliveryOption.pickUp],
      <UsageState>[],
      [
        ...rawSearchResultsDeliveryOptions.sublist(0, 1),
        ...rawSearchResultsDeliveryOptions.sublist(3),
      ],
      "pickUp",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsDeliveryOptions,
      null,
      <DeliveryOption>[DeliveryOption.mailOrder, DeliveryOption.pickUp],
      <UsageState>[],
      [...rawSearchResultsDeliveryOptions.sublist(0, 1), ...rawSearchResultsDeliveryOptions.sublist(2)],
      "mailOrder and pickUp",
    ),
  ];

  final List<TestCaseBazaarFilter> testCasesFilterUsageStates = [
    TestCaseBazaarFilter(
      rawSearchResultsUsageStates,
      null,
      null,
      null,
      rawSearchResultsUsageStates,
      "no usage states constraint (null) -> should pass all",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsUsageStates,
      null,
      null,
      <UsageState>[],
      rawSearchResultsUsageStates,
      "no usage states constraint (empty list) -> should pass all",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsUsageStates,
      null,
      <DeliveryOption>[],
      <UsageState>[UsageState.used],
      [
        ...rawSearchResultsUsageStates.sublist(0, 1),
        ...rawSearchResultsUsageStates.sublist(2, 3),
        ...rawSearchResultsUsageStates.sublist(4)
      ],
      "used",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsUsageStates,
      null,
      <DeliveryOption>[],
      <UsageState>[UsageState.brandNew],
      [...rawSearchResultsUsageStates.sublist(0, 1), ...rawSearchResultsUsageStates.sublist(3)],
      "brandNew",
    ),
    TestCaseBazaarFilter(
      rawSearchResultsUsageStates,
      null,
      <DeliveryOption>[],
      <UsageState>[UsageState.used, UsageState.brandNew],
      [...rawSearchResultsUsageStates.sublist(0, 1), ...rawSearchResultsUsageStates.sublist(2)],
      "used or brandNew",
    ),
  ];

  lowLevelTestCasesCharSequence.forEach((testCase) {
    test('Should correctly find (ignoring case): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(null);

      var actualOutput = bazaarSearchAndFilter.stringContainsIgnoreCase(testCase.input, testCase.searchTerms);

      expect(actualOutput, testCase.expectedOutput);
    });
  });

  lowLevelTestCasesWord.forEach((testCase) {
    test('Should correctly find (words): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(null);

      var actualOutput = bazaarSearchAndFilter.stringContainsWords(testCase.input, testCase.searchTerms);

      expect(actualOutput, testCase.expectedOutput);
    });
  });

  testCasesIgnoringCase.forEach((testCase) {
    test('Should correctly find (ignoring case): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(testCase.items);

      var actualSearchResults = bazaarSearchAndFilter.findItemsContainingIgnoringCase(testCase.searchQuery, false);

      expect(actualSearchResults.length, testCase.expectedOutput.length);
      compareItems(actualSearchResults, testCase.expectedOutput);
    });
  });

  testCasesWords.forEach((testCase) {
    test('Should correctly find (words): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(testCase.items);

      var actualSearchResults = bazaarSearchAndFilter.findItemsContainingWords(testCase.searchQuery, false);

      expect(actualSearchResults.length, testCase.expectedOutput.length);
      compareItems(actualSearchResults, testCase.expectedOutput);
    });
  });

  test('search in title, vs. in both title and description', () {
    final bazaarSearchAndFilter = BazaarSearchAndFilter(<BazaarItemData>[
      BazaarOfferingData("loop", "green loop", null, null, null, null, null),
    ]);
    var actualInTitle = bazaarSearchAndFilter.findItemsContainingWords("green", false);
    expect(actualInTitle.length, 0);

    var actualInTitleAndDescription = bazaarSearchAndFilter.findItemsContainingWords("green", true);
    expect(actualInTitleAndDescription.length, 1);
  });

  testCasesFilterKeywords.forEach((testCase) {
    test('Should filter keywords: ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(null);

      var actualFilteredSearchResults = bazaarSearchAndFilter.filterSearchResults(
        testCase.rawSearchResults,
        testCase.keywords,
        testCase.availableDeliveryOptions,
        testCase.availableUsageStates,
      );

      expect(actualFilteredSearchResults.length, testCase.expectedOutput.length);
      compareItems(actualFilteredSearchResults, testCase.expectedOutput);
    });
  });

  testCasesFilterDeliveryOptions.forEach((testCase) {
    test('Should filter delivery options (criteria for offerings only): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(null);

      var actualFilteredSearchResults = bazaarSearchAndFilter.filterSearchResults(
        testCase.rawSearchResults,
        testCase.keywords,
        testCase.availableDeliveryOptions,
        testCase.availableUsageStates,
      );

      expect(actualFilteredSearchResults.length, testCase.expectedOutput.length);
      compareItems(actualFilteredSearchResults, testCase.expectedOutput);
    });
  });

  testCasesFilterUsageStates.forEach((testCase) {
    test('Should filter usage states (criteria for offerings only): ${testCase.testDescription}', () {
      final bazaarSearchAndFilter = BazaarSearchAndFilter(null);

      var actualFilteredSearchResults = bazaarSearchAndFilter.filterSearchResults(
        testCase.rawSearchResults,
        testCase.keywords,
        testCase.availableDeliveryOptions,
        testCase.availableUsageStates,
      );

      expect(actualFilteredSearchResults.length, testCase.expectedOutput.length);
      compareItems(actualFilteredSearchResults, testCase.expectedOutput);
    });
  });
}

void compareItems(List<BazaarItemData> actualSearchResults, List<BazaarItemData> expectedOutput) {
  // compare ignoring order, only need it sorted here for comparison.
  final sortRule = (a, b) => "${a.title} +++ ${a.description}".compareTo("${b.title} +++ ${b.description}");
  actualSearchResults.sort(sortRule);
  expectedOutput.sort(sortRule);
  for (int i = 0; i < expectedOutput.length; i++) {
    expect(actualSearchResults[i].title, expectedOutput[i].title);
    expect(actualSearchResults[i].description, expectedOutput[i].description);
  }
}
