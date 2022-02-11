import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class OfferingForm extends StatefulWidget {
  const OfferingForm();

  @override
  _OfferingFormState createState() => _OfferingFormState();
}

class _OfferingFormState extends State<OfferingForm> {
  var categories = allCategories; // TODO state management
  var businesses = myBusinesses; // TODO state management
  var productNewness = allProductNewnessOptions; // TODO state management
  var deliveryOptions = allDeliveryOptions; // TODO state management

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.bazaar.offeringAdd),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
          child: ListView(
            children: <Widget>[
              Row(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    height: 150,
                    width: 150,
                    color: Colors.grey,
                    child: ListTile(
                      leading: Icon(Icons.add_a_photo),
                      title: Text(dic.bazaar.photoAdd),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: dic.bazaar.useDescriptiveName,
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: dic.bazaar.description,
                ),
              ),
              ToggleButtonsWithTitle(dic.bazaar.categories, categories, null),
              // TODO state mananagement
              ToggleButtonsWithTitle(
                  dic.bazaar.businessesOffered, businesses.map((business) => business.title).toList(), null),
              // TODO state mananagement, TODO has to be an business.id not just the title
              ToggleButtonsWithTitle(dic.bazaar.state, productNewness, null),
              // TODO state mananagement, TODO has to be an business.id not just the title
              ToggleButtonsWithTitle(dic.bazaar.deliveryOptions, deliveryOptions, null),
              // TODO state mananagement, TODO has to be an business.id not just the title
            ],
          ),
        ),
      ),
      floatingActionButton: ButtonBar(
        children: <Widget>[
          ElevatedButton(
            child: Row(children: [Icon(Icons.delete), Text(dic.bazaar.delete)]),
            onPressed: () {
              // TODO modify state
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: Row(children: [Icon(Icons.check), Text(dic.bazaar.save)]),
            onPressed: () {
              // TODO modify state
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
