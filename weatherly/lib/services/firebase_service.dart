import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weatherly/models/community_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // User Management
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Weather Data Logging
  Future<void> logWeatherFetch(double lat, double lon) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('userActivity').doc(userId).collection('weatherFetches').add({
        'location': GeoPoint(lat, lon),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Community Reports
  Future<void> submitCommunityReport(CommunityReport report) async {
    await _firestore.collection('communityReports').add(report.toFirestore());
  }

  // Push Notifications
  Future<String?> getFCMToken() async {
    await _messaging.requestPermission();
    return await _messaging.getToken();
  }

  Future<void> subscribeToLocationAlerts(String locationId) async {
    await _messaging.subscribeToTopic('location_$locationId');
  }
}