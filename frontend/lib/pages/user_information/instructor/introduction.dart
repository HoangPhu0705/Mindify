import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/user_information/instructor/instructor_signup.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

// https://images.typeform.com/images/8uVv8sPWhbCV/background/large

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  var _image = NetworkImage(
      "https://images.typeform.com/images/8uVv8sPWhbCV/background/large");
  bool _loading = true;
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.initState();
    _image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, call) {
          setState(() {
            _loading = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? MyLoading(
                width: 30,
                height: 30,
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://images.typeform.com/images/8uVv8sPWhbCV/background/large",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Align(
                      alignment: Alignment.topLeft,
                      child: RichText(
                          textAlign: TextAlign.start,
                          text: const TextSpan(
                            text: 'Start teaching on\n',
                            style: TextStyle(
                              fontSize: 24,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Mindify.',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue,
                                ),
                              ),
                            ],
                          )),
                    ),
                    const Spacer(),
                    WidgetAnimator(
                      incomingEffect:
                          WidgetTransitionEffects.incomingSlideInFromBottom(
                        duration: const Duration(
                          milliseconds: 800,
                        ),
                        delay: const Duration(
                          milliseconds: 600,
                        ),
                        blur: const Offset(0.5, 0.5),
                      ),
                      child: Text(
                        'Enroll to become a creator on Mindify. Let\'s get started!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    AppSpacing.largeVertical,
                    WidgetAnimator(
                      incomingEffect:
                          WidgetTransitionEffects.incomingSlideInFromBottom(
                              duration: const Duration(
                                milliseconds: 800,
                              ),
                              delay: const Duration(
                                milliseconds: 600,
                              ),
                              blur: const Offset(0.5, 0.5)),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InstructorSignUp(),
                            ),
                          ).then((value) {
                            SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle(
                                statusBarColor: Colors.black,
                                statusBarIconBrightness: Brightness.light,
                              ),
                            );
                          });
                        },
                        style: AppStyles.primaryButtonStyle,
                        child: Text("Get Started"),
                      ),
                    ),
                    AppSpacing.largeVertical,
                  ],
                ),
              ),
      ),
    );
  }
}
