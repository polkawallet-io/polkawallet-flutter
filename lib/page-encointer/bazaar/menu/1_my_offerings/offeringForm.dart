import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';

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
    var dic = I18n.of(context).bazaar;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['offering.add']),
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
                        title: Text(dic['photo.add']),
                      )),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: dic['use.descriptive.name'],
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: dic['description'],
                ),
              ),
              ToggleButtonsWithTitle(dic['categories'], categories, null),
              // TODO state mananagement
              ToggleButtonsWithTitle(
                  dic['businesses.offered'], businesses.map((business) => business.title).toList(), null),
              // TODO state mananagement, TODO has to be an business.id not just the title
              ToggleButtonsWithTitle(dic['state'], productNewness, null),
              // TODO state mananagement, TODO has to be an business.id not just the title
              ToggleButtonsWithTitle(dic['delivery.options'], deliveryOptions, null),
              // TODO state mananagement, TODO has to be an business.id not just the title
            ],
          ),
        ),
      ),
      floatingActionButton: ButtonBar(
        children: <Widget>[
          ElevatedButton(
            child: Row(children: [Icon(Icons.delete), Text(dic['delete'])]),
            onPressed: () {
              // TODO modify state
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: Row(children: [Icon(Icons.check), Text(dic['save'])]),
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
