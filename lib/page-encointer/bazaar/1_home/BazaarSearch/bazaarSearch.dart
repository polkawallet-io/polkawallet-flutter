import 'package:encointer_wallet/page-encointer/bazaar/1_home/BazaarSearch/searchResults.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class BazaarSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: I18n.of(context).translationsForLocale().bazaar.search,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 340 : 400,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      // actions: [
      //   FloatingSearchBarAction(
      //     showIfOpened: false,
      //     child: CircularButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: () {},
      //     ),
      //   ),
      //   FloatingSearchBarAction.searchToClear(
      //     showIfClosed: false,
      //   ),
      // ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: SearchResults(),
          ),
        );
      },
    );
  }
}
