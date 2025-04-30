import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/models/community_model.dart';
import 'package:weatherly/providers/auth_provider.dart';
import 'package:weatherly/widgets/community_post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _postController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Reports'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_reports')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reports yet'));
                }

                final reports = snapshot.data!.docs.map((doc) {
                  return CommunityReport.fromFirestore(doc);
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return CommunityPost(
                      report: reports[index],
                      isCurrentUser: reports[index].userId == user?.uid,
                    );
                  },
                );
              }),
          ),
          _buildPostInput(),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Share weather observation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitPost,
          ),
        ],
      ),
    );
  }

  void _submitPost() async {
    if (_postController.text.trim().isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    final weather = context.read<WeatherProvider>().currentWeather;

    if (user == null || weather == null) return;

    final report = CommunityReport(
      userId: user.uid,
      userName: user.displayName ?? 'Anonymous',
      userAvatar: user.photoURL,
      text: _postController.text,
      location: GeoPoint(weather.location.lat, weather.location.lon),
      weatherCondition: weather.condition,
      timestamp: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('community_reports')
          .add(report.toFirestore());
      _postController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: ${e.toString()}')),
      );
    }
  }
}