import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/businessFormState.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class OpeningHours extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [0, 1, 2, 3, 4, 5, 6]
          .map(
            (int day) => OpeningHoursViewForDay(day),
          )
          .toList(),
    );
  }
}

class OpeningHoursViewForDay extends StatelessWidget {
  final day;

  OpeningHoursViewForDay(this.day);

  @override
  Widget build(BuildContext context) {
    final businessFormState = Provider.of<BusinessFormState>(context);
    final openingHours = businessFormState.openingHours;
    final openingHoursForThisDay = openingHours.getOpeningHoursFor(day);

    return Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 36),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Observer(
                  builder: (BuildContext context) => IconButton(
                    color: day == openingHours.dayOnFocus ? Colors.lightGreenAccent : Colors.blueGrey,
                    icon: Icon(
                      Icons.add_circle,
                    ),
                    iconSize: 36,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      openingHours.setDayOnFocus(day);
                    },
                  ),
                ),
                Container(
                  width: 32,
                  child: Text(
                    "${openingHours.getDayString(day)}",
                  ),
                ),
                Observer(
                  builder: (BuildContext context) => IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: day == openingHours.dayToCopyFrom ? Colors.lightGreenAccent : Colors.blueGrey, // TODO
                    ),
                    iconSize: 36,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      openingHours.copyFrom(day);
                    },
                  ),
                ),
                Flexible(
                  child: Observer(
                    builder: (_) => ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: openingHoursForThisDay.openingIntervals.length,
                        itemBuilder: (_, index) {
                          final interval = openingHoursForThisDay.openingIntervals[index];
                          return Container(
                              width: 200,
                              child: Row(
                                children: [
                                  Text(
                                    interval.humanReadable(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Observer(
                                    builder: (_) => IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      iconSize: 36,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        openingHoursForThisDay.removeInterval(index);
                                      },
                                    ),
                                  )
                                ],
                              ));
                        }),
                  ),
                ),
                Observer(
                  builder: (_) => IconButton(
                    icon: Icon(
                      Icons.paste,
                      color: Colors.blueGrey,
                    ),
                    iconSize: 36,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      openingHours.pasteOpeningHoursTo(day);
                    },
                  ),
                ),
              ],
            ),

            Observer(
              builder: (_) => Visibility(
                child: AddOpeningIntervalForDay(day),
                visible: day == openingHours.dayOnFocus,
              ),
            ),
            // Text(openingHoursForThisDay.showTextField.toString()),
          ],
        ),
      ),
    );
  }
}

class AddOpeningIntervalForDay extends StatelessWidget {
  final _textController = TextEditingController(text: '');
  final day;

  AddOpeningIntervalForDay(this.day);

  @override
  Widget build(BuildContext context) {
    final businessFormState = Provider.of<BusinessFormState>(context);
    final openingHours = businessFormState.openingHours;
    var openingHoursForDay = openingHours.getOpeningHoursFor(day);

    return Observer(
      builder: (_) => TextField(
        // TODO would be nice to only allow certain chars but then backspace is broken, also if added to regex as \b
        // inputFormatters: <TextInputFormatter>[
        //   FilteringTextInputFormatter.allow(RegExp(r"[0-9]|a|A|p|P|m|M|:|-|\b")),
        // ],
        autofocus: true,
        decoration: InputDecoration(
            labelText: I18n.of(context).translationsForLocale().bazaar.timeIntervalAdd,
            hintText: I18n.of(context).translationsForLocale().bazaar.openningHoursInputHint,
            contentPadding: EdgeInsets.all(8),
            errorText: openingHoursForDay.timeFormatError),
        controller: _textController,
        textInputAction: TextInputAction.done,
        onSubmitted: (String startEnd) {
          openingHoursForDay.addParsedIntervalIfValid(startEnd);
          if (openingHoursForDay.timeFormatError == null) {
            _textController.clear();
          }
        },
      ),
    );
  }
}
