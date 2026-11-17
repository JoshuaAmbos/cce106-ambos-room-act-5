import 'package:flutter/material.dart';
import 'post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController commentController =
      TextEditingController();

  final List<String> comments = [];

  bool isLiked = false;

  void likePost() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void addComment() {
    final String comment = commentController.text.trim();

    if (comment.isEmpty) {
      return;
    }

    setState(() {
      comments.add(comment);
    });

    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post.username.trim();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                username.isEmpty
                    ? '?'
                    : username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Student Feed'),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.post.caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),

          Row(
            children: [
              TextButton.icon(
                onPressed: likePost,
                icon: Icon(
                  isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                label: Text(isLiked ? 'Liked' : 'Like'),
              ),
              Text('${comments.length} Comments'),
            ],
          ),

          for (final String comment in comments)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 4, 16, 4,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(comment),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addComment,
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  tooltip: 'Send comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
