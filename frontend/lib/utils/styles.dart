import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';

class AppStyles {
  static var primaryButtonStyle = ButtonStyle(
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all<Color>(AppColors.cream),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );

  static var disabledButton = ButtonStyle(
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all<Color>(AppColors.lighterGrey),
    foregroundColor: WidgetStateProperty.all<Color>(AppColors.lightGrey),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );

  static var secondaryButtonStyle = ButtonStyle(
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: const BorderSide(color: Colors.black),
      ),
    ),
  );

  static var tertiaryButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: AppColors.lightGrey),
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
    elevation: WidgetStateProperty.all(0),
    backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
        side: const BorderSide(color: Colors.black),
      ),
    ),
  );
}
