import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Color(0xFF6200EE),
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/john_cena.jpg'), // Add the path to your profile picture
                  radius: 30,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOHN CENA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 10,),
                Icon(Icons.settings, color: Colors.white,)
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.cloud_download),
                    title: Text('Downloads'),
                    subtitle: Text('0 classes'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle Downloads tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('All saved Classes'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle All saved Classes tap
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.list),
                  //   title: Text('My Lists'),
                  //   trailing: Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     // Handle My Lists tap
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Watched History'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle Watched History tap
                    },
                  ),
                  // to test logout, sửa cái này giúp
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: signUserOut,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
