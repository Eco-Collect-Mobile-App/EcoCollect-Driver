import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWasteRequestsForUser() {
    return _firestore
        .collection('wasteData')
        .orderBy('pickupDate', descending: true)
        .orderBy('pickupTime', descending: true)
        .snapshots();
  }
}
