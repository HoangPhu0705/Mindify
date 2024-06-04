import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SuperScaffold(
        appBar: SuperAppBar(
          height: 0,
          searchBar: SuperSearchBar(
            height: 48,
            placeholderText: "What do you want to learn?",
            placeholderTextStyle: const TextStyle(
              color: AppColors.lightGrey,
              fontFamily: "Poppins",
              fontSize: 16,
            ),
            cancelTextStyle: const TextStyle(
              color: Colors.black,
              fontFamily: "Poppins",
            ),
          ),
          backgroundColor: AppColors.ghostWhite,
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Search",
            textStyle: const TextStyle(
              fontSize: 26,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Text("Search"),
      ),
    );
  }
}
