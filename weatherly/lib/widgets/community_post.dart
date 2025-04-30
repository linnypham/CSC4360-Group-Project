import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/models/community_model.dart';

class CommunityPost extends StatelessWidget {
  final CommunityReport report;
  final bool isCurrentUser;

  const CommunityPost({
    super.key,
    required this.report,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: report.userAvatar != null
                      ? NetworkImage(report.userAvatar!)
                      : null,
                  child: report.userAvatar == null
                      ? Text(report.userName[0])
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(report.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _deletePost(context),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.text),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.weatherCondition}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}