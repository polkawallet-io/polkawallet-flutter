// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/openingHoursState.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

void main() {
  List<List<String>> testCases = [
    ["8:10-13:40", "8:10 - 13:40", "base case"],
    ["  8 :  10 - 13: 40", "8:10 - 13:40", "with spaces"],
    ["12:00-8:00", "8:00 - 12:00", "sort"],
    ["23:88-3:00", "0:28 - 3:00", "silently turn into valid time, never save an invalid time"],
    ["12:30-14", "12:30 - 14:00", "hour only"],
    ["8:00am-10:00am", "8:00 - 10:00", "using am"],
    ["8:00Am-10:00am", "8:00 - 10:00", "using am ignoring case"],
    ["8:00pm-10:00pm", "20:00 - 22:00", "using pm"],
    ["8:00pM-10:00Pm", "20:00 - 22:00", "using pm ignoring case"],
    ["20:00-10:00pm", "20:00 - 22:00", "using pm mixed"],
    ["8am-5pm", "8:00 - 17:00", "using am and pm and hour only"],
    ["12am-3pm", "0:00 - 15:00", "midnight 12am"],
    ["0-8", "0:00 - 8:00", "midnight 0"],
    ["12pm-3pm", "12:00 - 15:00", "noon 12pm"],
    ["12-3pm", "12:00 - 15:00", "noon 12"],
    ["12:10-3pm", "12:10 - 15:00", "afternoon 12:10"],
    ["12:10pm-3pm", "12:10 - 15:00", "afternoon 12:10pm"],
    ["0:10-3pm", "0:10 - 15:00", "afternoon 12:10"],
    ["12:10am-3pm", "0:10 - 15:00", "afternoon 12:10pm"],
  ];
  testCases.forEach((testCase) {
    test('Should correctly parse time interval: ${testCase[2]}', () {
      final state = OpeningHoursForDayState(ObservableList<OpeningIntervalState>());

      state.addParsedIntervalIfValid(testCase[0]);

      expect(state.humanReadable(), testCase[1]);
    });
  });
}
