import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showImageOptionModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    useRootNavigator: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0))),
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 112,
        child: Column(
          children: [
            ListTile(
              leading: Icon(CupertinoIcons.photo_camera),
              title: Text("Take photo"),
              onTap: () {
                //open camera
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.photo_on_rectangle),
              title: Text("Open photos"),
              onTap: () {
                //open gallery
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
