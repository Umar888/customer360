import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class RecommendAddressDialog extends StatelessWidget {
  final VerifyAddress enteredAddress;
  final VerifyAddress recommendAddress;
  RecommendAddressDialog(
      {Key? key, required this.enteredAddress, required this.recommendAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        '${enteredAddress.addressline1}, ${(enteredAddress.addressline2 ?? '').isEmpty ? '' : '${enteredAddress.addressline2}, '}${enteredAddress.city}, ${enteredAddress.state} - ${enteredAddress.postalcode}');
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      title: Text(
        "Confirmation",
        textAlign: TextAlign.center,
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Do you want to change the address?",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Existing",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: kRubik)),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          '${enteredAddress.addressline1}, ${(enteredAddress.addressline2 ?? '').isEmpty ? '' : '${enteredAddress.addressline2}, '}${enteredAddress.city}, ${enteredAddress.state} - ${enteredAddress.postalcode}',
                          maxLines: 10,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: kRubik)),
                    ],
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Recommended",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: kRubik)),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          '${recommendAddress.addressline1}, ${(recommendAddress.addressline2 ?? '').isEmpty ? '' : '${recommendAddress.addressline2}, '}${recommendAddress.city}, ${recommendAddress.state} - ${recommendAddress.postalcode}',
                          maxLines: 10,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: kRubik)),
                    ],
                  ),
                )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(ColorSystem.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor)))),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ))),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Yes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
