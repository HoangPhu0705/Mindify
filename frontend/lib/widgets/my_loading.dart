import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MyLoading extends StatelessWidget {
  final double width;
  final double height;
  const MyLoading({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: const LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          colors: [AppColors.blue],
        ),
      ),
    );
  }
}
