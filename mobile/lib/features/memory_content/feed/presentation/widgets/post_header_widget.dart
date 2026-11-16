import 'package:flutter/material.dart';

class PostHeaderWidget extends StatelessWidget {
  final String userName;
  final String? userAvatarUrl;
  final DateTime createdAt;

  const PostHeaderWidget({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    required this.createdAt,
  });

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} g';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: userAvatarUrl != null
                ? NetworkImage(userAvatarUrl!)
                : null,
            child: userAvatarUrl == null
                ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?')
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTime(createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
