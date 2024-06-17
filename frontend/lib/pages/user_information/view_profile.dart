import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/providers/UserProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:provider/provider.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile>
    with SingleTickerProviderStateMixin {
  UserService userService = UserService();
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String displayName = userService.getUsername();
      Provider.of<UserProvider>(context, listen: false)
          .setDisplayName(displayName);
      String photoUrl = userService.getPhotoUrl();
      Provider.of<UserProvider>(context, listen: false).setPhotoUrl(photoUrl);
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.deepBlue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: Image(
                        image: NetworkImage(
                          context.watch<UserProvider>().photoUrl,
                        ),
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Text('Error loading image');
                        },
                      ).image,
                      radius: 40,
                    ),
                    AppSpacing.smallVertical,
                    Text(
                      context.watch<UserProvider>().displayName,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    //email
                    Text(
                      FirebaseAuth.instance.currentUser!.email!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "0 Followers •",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          " 0 Following ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                splashFactory: NoSplash.splashFactory,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Achievements'),
                  Tab(text: 'Teaching'),
                ],
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black,
                indicatorWeight: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}