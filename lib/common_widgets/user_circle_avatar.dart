import 'package:flutter/material.dart';

class UserCircularAvatar extends StatelessWidget {
  UserCircularAvatar({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(imageUrl),
      // backgroundColor: Colors.transparent,ƒ
      // CachedNetworkImage(
      //   fit: BoxFit.cover,
      //   imageUrl: imageUrl,
      //   placeholder: (context, url) => CircularProgressIndicator(),
      //   errorWidget: (context, url, error) => Icon(Icons.error),
      // ),
    );
  }
}
