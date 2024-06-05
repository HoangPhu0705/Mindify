import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';

class AppStyles {
  static var primaryButtonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all<Color>(AppColors.cream),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );

  static var secondaryButtonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: const BorderSide(color: Colors.black),
      ),
    ),
  );

  static var searchBarPlaceHolderStyle = const TextStyle(
    color: AppColors.lightGrey,
    fontFamily: "Poppins",
    fontSize: 16,
  );

  static var largeTitleSearchPage = const TextStyle(
    fontSize: 26,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w600,
  );

  static var cancelTextStyle = const TextStyle(
    color: Colors.black,
    fontFamily: "Poppins",
  );

  static var courseLabelStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
        side: const BorderSide(color: Colors.black),
      ),
    ),
  );
}
