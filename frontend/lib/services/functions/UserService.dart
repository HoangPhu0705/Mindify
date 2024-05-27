import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  User user = FirebaseAuth.instance.currentUser!;

  String getUsername() {
    return user.displayName ?? "Mindify menber";
  }

  Future<void> updateUsername(String newDisplayName) async {
    await user.updateDisplayName(newDisplayName);
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
