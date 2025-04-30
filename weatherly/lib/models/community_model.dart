import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityReport {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final GeoPoint location;
  final String weatherCondition;
  final DateTime timestamp;

  CommunityReport({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.location,
    required this.weatherCondition,
    required this.timestamp,
  });

  factory CommunityReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityReport(
      userId: data['userId'],
      userName: data['userName'],
      userAvatar: data['userAvatar'],
      text: data['text'],
      location: data['location'],
      weatherCondition: data['weatherCondition'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'location': location,
      'weatherCondition': weatherCondition,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}