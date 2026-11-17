import 'package:flutter/material.dart';
import 'post.dart';

class CreatePostSheet extends StatefulWidget {
  final String username;

  const CreatePostSheet({
    super.key,
    required this.username,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _captionController = TextEditingController();

  final TextEditingController _imageController = TextEditingController();

  void submitPost() {
    final String caption = _captionController.text.trim();
    final String imageUrl = _imageController.text.trim();

    if (caption.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete both fields before submitting!',
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(imageUrl);

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid HTTP or HTTPS image URL.'),
        ),
      );
      return;
    }

    final Post newPost = Post(
      username: widget.username,
      caption: caption,
      imageUrl: imageUrl,
    );

    Navigator.pop(context, newPost);
  }

  @override
  void dispose() {
    _captionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Caption',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _imageController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                prefixIcon: Icon(Icons.image),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitPost,
              child: const Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
