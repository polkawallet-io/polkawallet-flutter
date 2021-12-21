// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/openingHoursState.dart';

class TestCaseOpeningHours {
  final String input;
  final String expectedOutput;
  final String testDescription;

  TestCaseOpeningHours(this.input, this.expectedOutput, this.testDescription);
}

void main() {
  List<TestCaseOpeningHours> testCases = [
    TestCaseOpeningHours("8:10-13:40", "8:10 - 13:40", "base case"),
    TestCaseOpeningHours("  8 :  10 - 13: 40", "8:10 - 13:40", "with spaces"),
    TestCaseOpeningHours("12:00-8:00", "8:00 - 12:00", "sort"),
    TestCaseOpeningHours("23:88-3:00", "0:28 - 3:00", "silently turn into valid time, never save an invalid time"),
    TestCaseOpeningHours("12:30-14", "12:30 - 14:00", "hour only"),
    TestCaseOpeningHours("8:00am-10:00am", "8:00 - 10:00", "using am"),
    TestCaseOpeningHours("8:00Am-10:00am", "8:00 - 10:00", "using am ignoring case"),
    TestCaseOpeningHours("8:00pm-10:00pm", "20:00 - 22:00", "using pm"),
    TestCaseOpeningHours("8:00pM-10:00Pm", "20:00 - 22:00", "using pm ignoring case"),
    TestCaseOpeningHours("20:00-10:00pm", "20:00 - 22:00", "using pm mixed"),
    TestCaseOpeningHours("8am-5pm", "8:00 - 17:00", "using am and pm and hour only"),
    TestCaseOpeningHours("12am-3pm", "0:00 - 15:00", "midnight 12am"),
    TestCaseOpeningHours("0-8", "0:00 - 8:00", "midnight 0"),
    TestCaseOpeningHours("12pm-3pm", "12:00 - 15:00", "noon 12pm"),
    TestCaseOpeningHours("12-3pm", "12:00 - 15:00", "noon 12"),
    TestCaseOpeningHours("12:10-3pm", "12:10 - 15:00", "afternoon 12:10"),
    TestCaseOpeningHours("12:10pm-3pm", "12:10 - 15:00", "afternoon 12:10pm"),
    TestCaseOpeningHours("0:10-3pm", "0:10 - 15:00", "afternoon 12:10"),
    TestCaseOpeningHours("12:10am-3pm", "0:10 - 15:00", "afternoon 12:10pm"),
  ];
  testCases.forEach((testCase) {
    test('Should correctly parse time interval: ${testCase.testDescription}', () {
      final state = OpeningHoursForDayState(ObservableList<OpeningIntervalState>());

      state.addParsedIntervalIfValid(testCase.input);

      expect(state.humanReadable(), testCase.expectedOutput);
    });
  });
}
