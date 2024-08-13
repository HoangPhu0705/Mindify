import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/pages/course_pages/instructor_profile.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:getwidget/getwidget.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:chip_list/chip_list.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _currentSearchIndex = -1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CourseService _courseService = CourseService();
  final UserService userService = UserService();
  String userId = '';

  List<dynamic> _searchResults = [];
  List<dynamic> _suggestionResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool canFilter = false;
  String _lastQuery = '';
  late Future<void> _future;
  bool _isTyping = false;
  Timer? _debounce;

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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  Future<void> _preloadImages() async {
    for (String imagePath in AppConstants.categoryImage) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  void _onSearchChanged() {
    setState(() {
      canFilter = false;
    });
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        setState(() {
          _isTyping = false;
          _suggestionResults = [];
        });
        return;
      }

      _onSearch(_searchController.text);
    });
  }

  void _onSearch(String query) async {
    setState(() {
      _isLoading = true;
      _lastQuery = query;
      _suggestionResults = [];
    });

    try {
      List<Map<String, dynamic>> results =
          await _courseService.searchCoursesAndUsers(query, isNewSearch: true);
      setState(() {
        _suggestionResults = results;
        _isLoading = false;
        _hasMoreData = results.length == 50;
      });
    } catch (e) {
      log("Error searching courses and users: $e");
    }
  }

  void _onSearchSubmit(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // if (_lastQuery == query && _searchResults.isNotEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResults = [];
      _lastQuery = query;
      _hasMoreData = true;
      canFilter = true;
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return FilterSheet(
          onApply: (filterCriteria) {
            setState(() {
              _applyFilter(filterCriteria);
            });
          },
        );
      },
    );
  }

  void _applyFilter(FilterCriteria criteria) {
    List<dynamic> filteredResults = _searchResults;

    // Filter by date
    if (criteria.dateRange != null) {
      final now = DateTime.now();
      DateTime cutoffDate;
      switch (criteria.dateRange) {
        case DateRange.oneWeek:
          cutoffDate = now.subtract(const Duration(days: 7));
          break;
        case DateRange.oneMonth:
          cutoffDate = now.subtract(const Duration(days: 30));
          break;
        case DateRange.oneYear:
          cutoffDate = now.subtract(const Duration(days: 365));
          break;
        default:
          cutoffDate = now; // Handle null case
      }

      filteredResults = filteredResults.where((course) {
        final createdAtField = course['createdAt'];
        if (createdAtField is Map && createdAtField.containsKey('_seconds')) {
          // Firebase timestamp
          final createdAtTimestamp = DateTime.fromMillisecondsSinceEpoch(
              createdAtField['_seconds'] * 1000);
          return createdAtTimestamp.isAfter(cutoffDate);
        } else if (createdAtField is DateTime) {
          // Direct DateTime object
          return createdAtField.isAfter(cutoffDate);
        } else {
          return false; // If createdAt is not a timestamp or DateTime, skip this entry
        }
      }).toList();
    }

    // Sort by selected criteria
    if (criteria.sortBy != null) {
      switch (criteria.sortBy) {
        case SortBy.students:
          filteredResults.sort((a, b) => b['students'] - a['students']);
          break;
        case SortBy.lessons:
          filteredResults.sort((a, b) => b['lessonNum'] - a['lessonNum']);
          break;
        default:
          break; // Handle null case
      }
    }

    setState(() {
      _searchResults = filteredResults;
    });
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const MyLoading(
        width: 30,
        height: 30,
        color: AppColors.deepBlue,
      );
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
              log("search result BUIasdaccLDDDD");

              return _isLoadingMore
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox.shrink();
            }

            final course = _searchResults[index];
            return GestureDetector(
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
              child: MyCourseItem(
                imageUrl: course['thumbnail'],
                title: course['courseName'],
                lessonNum: course["lessonNum"].toString(),
                author: course['author'],
                duration: course['duration'],
                students: course['students'].toString(),
                moreOnPress: () {},
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildSuggestionList() {
    log("suggestion result BUILDDDD");

    if (_suggestionResults.isEmpty) {
      return const Center(
        child: Text(
          'Search courses you may like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestionResults.length,
      itemBuilder: (context, index) {
        final result = _suggestionResults[index];
        if (result.containsKey('courseName')) {
          // Course item
          return ListTile(
            leading: Container(
              width: 100,
              height: 50,
              child: Image.network(
                result['thumbnail'],
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              result['courseName'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(result['author']),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CourseDetail(
                    courseId: result['id'],
                    userId: userId,
                  ),
                ),
              );
            },
          );
        } else if (result.containsKey('displayName')) {
          // User item
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(result['photoURL']),
            ),
            title: Text(result['displayName']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstructorProfile(
                    instructorId: result['uid'],
                  ),
                ),
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
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
                  actions: [
                    SuperAction(
                      child: !canFilter
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _showFilterSheet,
                            ),
                    ),
                  ],
                  onFocused: (focus) {
                    setState(() {
                      _isTyping = focus;
                    });
                  },
                  resultBehavior: SearchBarResultBehavior.visibleOnFocus,
                  searchFocusNode: _searchFocusNode,
                  searchController: _searchController,
                  height: 48,
                  placeholderText: "What do you want to learn today?",
                  scrollBehavior: SearchBarScrollBehavior.pinned,
                  placeholderTextStyle: AppStyles.searchBarPlaceHolderStyle,
                  cancelTextStyle: AppStyles.cancelTextStyle,
                  onChanged: (query) {
                    log("Query changed: $query");
                    setState(() {
                      _isTyping = true;
                    });
                  },
                  onSubmitted: (query) {
                    setState(() {
                      _isTyping = false;
                    });
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
                            FocusScope.of(context)
                                .requestFocus(_searchFocusNode);
                            setState(() {
                              _searchController.text =
                                  _popularSearches[_currentSearchIndex];
                            });
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
                          categories[index],
                          categoryImage[index],
                        );
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
        onTap: () {
          FocusScope.of(context).requestFocus(_searchFocusNode);
          setState(() {
            _searchController.text = name;
          });
        },
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

class FilterSheet extends StatefulWidget {
  final Function(FilterCriteria) onApply;

  const FilterSheet({super.key, required this.onApply});

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  DateRange? _selectedDateRange;
  SortBy? _selectedSortBy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          AppSpacing.mediumVertical,
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.smallVertical,
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: DateRange.values.length,
            itemBuilder: (context, index) {
              DateRange range = DateRange.values[index];
              String label = "";
              if (range == DateRange.oneYear) {
                label = "Past Year";
              } else if (range == DateRange.oneMonth) {
                label = "Past Month";
              } else if (range == DateRange.oneWeek) {
                label = "Past Week";
              }

              return GFCheckboxListTile(
                margin: const EdgeInsets.only(
                  bottom: 15,
                  right: 10,
                ),
                padding: EdgeInsets.zero,
                titleText: label,
                size: 24,
                activeBgColor: AppColors.cream,
                type: GFCheckboxType.circle,
                activeIcon: const Icon(
                  Icons.check,
                  size: 15,
                  color: AppColors.deepSpace,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedDateRange = value ? range : null;
                  });
                },
                value: _selectedDateRange == range,
                inactiveIcon: null,
              );
            },
          ),
          AppSpacing.mediumVertical,
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.mediumVertical,
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: SortBy.values.length,
            itemBuilder: (context, index) {
              SortBy sortBy = SortBy.values[index];
              String label = "";
              if (sortBy == SortBy.students) {
                label = "Students";
              } else if (sortBy == SortBy.lessons) {
                label = "Lessons";
              }

              return GFCheckboxListTile(
                margin: const EdgeInsets.only(
                  bottom: 15,
                  right: 10,
                ),
                padding: EdgeInsets.zero,
                titleText: label,
                size: 24,
                activeBgColor: AppColors.cream,
                type: GFCheckboxType.circle,
                activeIcon: const Icon(
                  Icons.check,
                  size: 15,
                  color: AppColors.deepSpace,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedSortBy = value ? sortBy : null;
                  });
                },
                value: _selectedSortBy == sortBy,
                inactiveIcon: null,
              );
            },
          ),
          AppSpacing.mediumVertical,
          Center(
            child: ElevatedButton(
              style: AppStyles.secondaryButtonStyle,
              onPressed: () {
                widget.onApply(FilterCriteria(
                  dateRange: _selectedDateRange,
                  sortBy: _selectedSortBy,
                ));
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterCriteria {
  final DateRange? dateRange;
  final SortBy? sortBy;

  FilterCriteria({this.dateRange, this.sortBy});
}

enum DateRange { oneWeek, oneMonth, oneYear }

enum SortBy { students, lessons }
