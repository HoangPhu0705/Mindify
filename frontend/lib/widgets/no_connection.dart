import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';

class NoConnection extends StatefulWidget {
  final VoidCallback? onRetry;
  const NoConnection({
    super.key,
    this.onRetry,
  });

  @override
  State<NoConnection> createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 80,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          Text(
            "Looks like you're offline",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 32,
                ),
          ),
          AppSpacing.smallVertical,
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: const Divider(
              color: AppColors.deepBlue,
              thickness: 4,
            ),
          ),
          AppSpacing.mediumVertical,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: AppStyles.primaryButtonStyle,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Go to My Downloads"),
              ),
            ),
          ),
          AppSpacing.mediumVertical,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onRetry,
              style: AppStyles.secondaryButtonStyle,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Try Reconnecting"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
