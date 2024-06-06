// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentSearchIndex = -1;

  final List<String> _popularSearches = [
    'marketing',
    'culinary',
    'design',
    'watercolor',
    'Illustration',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  void _preloadImages() {
    for (String imagePath in AppConstants.categoryImage) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = AppConstants.categories;
    const categoryImage = AppConstants.categoryImage;
    return SafeArea(
      child: Scaffold(
        //SuperScaffold
        body: SuperScaffold(
          //App bar of super Scaffold
          appBar: SuperAppBar(
            height: 0,
            searchBar: SuperSearchBar(
              height: 48,
              placeholderText: "What do you want to learn?",
              scrollBehavior: SearchBarScrollBehavior.pinned,
              placeholderTextStyle: AppStyles.searchBarPlaceHolderStyle,
              cancelTextStyle: AppStyles.cancelTextStyle,
              onChanged: (query) {
                log("query changed $query");
              },
              onSubmitted: (query) {},
              searchResult: const SizedBox(),
            ),
            backgroundColor: AppColors.ghostWhite,

            //Title of Super Scaffold
            largeTitle: SuperLargeTitle(
              enabled: true,
              largeTitle: "Search",
              textStyle: AppStyles.largeTitleSearchPage,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                //label
                _buildLabel("Popular Searches"),

                //Popular Searches
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ChipList(
                      listOfChipNames: _popularSearches,
                      listOfChipIndicesCurrentlySelected: [_currentSearchIndex],
                      shouldWrap: true,
                      // padding: EdgeInsets.all(12),
                      borderRadiiList: [20],
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      showCheckmark: false,
                      activeBorderColorList: [Colors.black],
                      inactiveBgColorList: [AppColors.ghostWhite],
                      inactiveBorderColorList: [AppColors.lightGrey],
                      inactiveTextColorList: [Colors.black],
                      activeTextColorList: [Colors.black],
                      activeBgColorList: [Colors.transparent],
                      axis: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      extraOnToggle: (val) {
                        _currentSearchIndex = val;
                        setState(() {});
                      },
                    ),
                  ),
                ),
                AppSpacing.largeVertical,
                _buildLabel("Categories"),

                AppSpacing.mediumVertical,
                //Categories list tiles with image on the left
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: AppConstants.categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryTile(
                        categories[index], categoryImage[index]);
                  },
                ),
                AppSpacing.largeVertical,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.lightGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String name, String image) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: ListTile(
        onTap: () {},
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), //or 15.0
          child: Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
