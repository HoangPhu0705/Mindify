import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/popular_course.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _pageController = PageController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Mindify", style: Theme.of(context).textTheme.headlineMedium),
            AppSpacing.smallVertical,
            Container(
              height: 400,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return PopularCourse(
                      imageUrl:
                          "https://cdn.domestika.org/ar_16:9,c_fill,dpr_1.0,f_auto,pg_1,q_auto:eco,t_base_params,w_768/v1712231738/course-covers/000/004/280/4280-original.jpg?1712231738",
                      courseName:
                          "Portrait Sketchbooking: Explore the Human Face",
                      instructor: " Gabriela Niko");
                },
              ),
            ),
            AppSpacing.smallVertical,
            SmoothPageIndicator(
              controller: _pageController,
              count: 5,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.blue,
                dotHeight: 4,
              ),
            ),
            AppSpacing.mediumVertical,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "New and Trending",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            AppSpacing.smallVertical
          ],
        ),
      ),
    );
  }
}
