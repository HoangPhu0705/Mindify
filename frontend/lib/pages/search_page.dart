import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:chip_list/chip_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentSearchIndex = -1;
  final TextEditingController _searchController = TextEditingController();
  final CourseService _courseService = CourseService();
  final UserService userService = UserService();
  String userId = '';

  List<dynamic> _searchResults = [];
  List<dynamic> _suggestionResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String _lastQuery = '';
  late Future<void> _future;
  bool _isTyping = false;

  final List<String> _popularSearches = [
    'marketing',
    'culinary',
    'design',
    'watercolor',
    'Illustration',
  ];

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    _future = _preloadImages();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _preloadImages() async {
    for (String imagePath in AppConstants.categoryImage) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _isTyping = true;
        _suggestionResults = [];
      });
      return;
    }
    setState(() {
      _isTyping = true;
    });
    _onSearch(_searchController.text);
  }

  void _onSearch(String query) async {
    if (_lastQuery == query && _suggestionResults.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _suggestionResults = [];
      _lastQuery = query;
      _hasMoreData = true;
    });

    try {
      List<Map<String, dynamic>> courses =
          await _courseService.searchCourses(query, isNewSearch: true);
      setState(() {
        _suggestionResults = courses;
        _isLoading = false;
        _hasMoreData = courses.length == 50;
      });
    } catch (e) {
      log("Error searching courses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmit(String query) async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    if (_lastQuery == query && _searchResults.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _lastQuery = query;
      _hasMoreData = true;
      _isTyping = false;
    });

    try {
      List<Map<String, dynamic>> courses =
          await _courseService.searchCourses(query, isNewSearch: true);
      setState(() {
        _searchResults = courses;
        _isLoading = false;
        _hasMoreData = courses.length == 50;
      });
    } catch (e) {
      log("Error searching courses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<Map<String, dynamic>> moreCourses =
          await _courseService.searchCourses(_lastQuery);
      setState(() {
        _searchResults.addAll(moreCourses);
        _isLoadingMore = false;
        _hasMoreData = moreCourses.length == 50;
      });
    } catch (e) {
      log("Error loading more courses: $e");
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const MyLoading(width: 30, height: 30, color: AppColors.deepBlue);
    } else if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No courses found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
          return true;
        },
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _searchResults.length + 1,
          itemBuilder: (context, index) {
            if (index == _searchResults.length) {
              return _isLoadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }

            final course = _searchResults[index];
            return MyCourseItem(
              imageUrl: course['thumbnail'],
              title: course['courseName'],
              author: course['author'],
              duration: course['duration'],
              students: course['students'].toString(),
              moreOnPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetail(
                      courseId: course['id'],
                      userId: userId,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  Widget _buildSuggestionList() {
    if (_suggestionResults.isEmpty) {
      return const Center(
        child: Text(
          'Search your courses you may like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestionResults.length,
      itemBuilder: (context, index) {
        final course = _suggestionResults[index];
        return ListTile(
          leading: Image.network(course['thumbnail'],
              width: 50, height: 50, fit: BoxFit.cover),
          title: Text(course['courseName']),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => CourseDetail(
                  courseId: course['id'],
                  userId: userId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = AppConstants.categories;
    const categoryImage = AppConstants.categoryImage;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              );
            }
            return SuperScaffold(
              appBar: SuperAppBar(
                backgroundColor: AppColors.ghostWhite,
                height: 0,
                searchBar: SuperSearchBar(
                  searchController: _searchController,
                  height: 48,
                  placeholderText: "What do you want to learn today?",
                  scrollBehavior: SearchBarScrollBehavior.pinned,
                  placeholderTextStyle: AppStyles.searchBarPlaceHolderStyle,
                  cancelTextStyle: AppStyles.cancelTextStyle,
                  onChanged: (query) {
                    log("Query changed: $query");
                  },
                  onSubmitted: (query) {
                    _onSearchSubmit(query);
                  },
                  searchResult: _isTyping
                      ? _buildSuggestionList()
                      : _buildSearchResults(),
                ),
                largeTitle: SuperLargeTitle(
                  enabled: true,
                  height: 50,
                  largeTitle: "Search",
                  textStyle: AppStyles.largeTitleSearchPage,
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLabel("Popular Searches"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ChipList(
                          listOfChipNames: _popularSearches,
                          listOfChipIndicesCurrentlySelected: [
                            _currentSearchIndex
                          ],
                          shouldWrap: true,
                          borderRadiiList: const [20],
                          style: const TextStyle(fontSize: 14),
                          showCheckmark: false,
                          activeBorderColorList: const [Colors.black],
                          inactiveBgColorList: const [AppColors.ghostWhite],
                          inactiveBorderColorList: const [AppColors.lightGrey],
                          inactiveTextColorList: const [Colors.black],
                          activeTextColorList: const [Colors.black],
                          activeBgColorList: const [Colors.transparent],
                          axis: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          extraOnToggle: (val) {
                            _currentSearchIndex = val;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    _buildLabel("Categories"),
                    AppSpacing.mediumVertical,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryTile(
                            categories[index], categoryImage[index]);
                      },
                    ),
                    if (_isLoadingMore) const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: AppColors.lightGrey),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String name, String image) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: ListTile(
        onTap: () {},
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
