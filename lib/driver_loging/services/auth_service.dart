import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signIn(String username, String nic) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('drivers')
          .where('username', isEqualTo: username)
          .where('nic', isEqualTo: nic)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.id; // Return driver ID
      }
    } catch (e) {
      print("Error: $e");
    }
    return null; // Return null if not found
  }
}
