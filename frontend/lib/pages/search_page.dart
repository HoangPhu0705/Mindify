// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
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

  final List<String> _categories = [
    'Animation',
    'Culinary',
    'Drawing',
    'Film',
    'Graphic Design',
    'Illustration',
    'Photography',
    'Procreate',
    'Watercolor',
    'Web & App Design',
    'Writing',
  ];

  final List<String> _catogoryImage = [
    'assets/images/category/animation.jpg',
    'assets/images/category/culinary.jpg',
    'assets/images/category/drawing.jpg',
    'assets/images/category/film.jpg',
    'assets/images/category/graphic_design.jpg',
    'assets/images/category/illustration.jpg',
    'assets/images/category/photography.jpg',
    'assets/images/category/procreate.jpg',
    'assets/images/category/watercolor.jpg',
    'assets/images/category/web_app_design.jpg',
    'assets/images/category/writing.jpg',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        log(_currentSearchIndex.toString());
                        setState(() {});
                      },
                    ),
                  ),
                ),

                _buildLabel("Categories"),

                AppSpacing.mediumVertical,
                //Categories list tiles with image on the left
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryTile(
                        _categories[index], _catogoryImage[index]);
                  },
                ),
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
