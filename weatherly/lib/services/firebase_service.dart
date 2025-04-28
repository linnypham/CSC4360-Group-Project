import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weatherly/models/weather_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // User Preferences
  Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('userPreferences').doc(userId).set(prefs);
    }
  }

  // Community Reports
  Future<void> submitCommunityReport(WeatherObservation observation) async {
    await _firestore.collection('communityReports').add({
      'userId': _auth.currentUser?.uid,
      'location': GeoPoint(observation.lat, observation.lon),
      'observation': observation.text,
      'timestamp': FieldValue.serverTimestamp(),
      'weatherCondition': observation.condition,
    });
  }

  // Push Notifications
  Future<void> setupPushNotifications() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (_auth.currentUser != null && token != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }
}