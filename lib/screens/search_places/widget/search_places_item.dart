import 'package:flutter/material.dart';
import 'package:gc_customer_app/models/search_places/search_places_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:intl/intl.dart';


class SearchPlacesItem extends StatelessWidget {
  SearchPlacesItem({Key? key, required this.searchPlacesData}) : super(key: key);
  final AutoCompleteAddressList searchPlacesData;



  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date.replaceAll("T", " ").replaceAll(".000Z", ""));
      return DateFormat('MMMM dd, yyyy  | hh:mm aa').format(dateTime);
    } on FormatException {
      return 'Date not available';
    } catch (e) {
      return 'Date not available';
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return ListTile(
      title: Text("${searchPlacesData.street??" "}, "
          "${searchPlacesData.city??" "}, "
          "${searchPlacesData.state??" "},"
          " ${searchPlacesData.zip??" "}",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: kRubik,
      fontSize: 17),),

      leading: Icon(Icons.location_on_outlined),
      onTap: () async {
        Navigator.pop(context,[searchPlacesData.street,
          searchPlacesData.city,
          searchPlacesData.state,
          searchPlacesData.zip]);
      },
      trailing: Icon(Icons.chevron_right,
      color: Colors.black87,),
    );
  }



  void navigateUserToPage(String title, int id) {}

  String displayStoreCount(int count){
    if(count == 0){
      return "";
    }else{
      return count.toString();
    }
  }
}
