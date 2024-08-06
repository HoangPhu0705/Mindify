import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
}
