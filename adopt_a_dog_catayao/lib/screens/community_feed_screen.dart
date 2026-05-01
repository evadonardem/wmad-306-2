import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';

const _posts = [
  {
    'user': 'Alice',
    'caption': 'Beautiful rescue day. Met the sweetest golden mix!',
    'breed': 'retriever',
    'subBreed': 'golden',
    'likes': 24,
    'comments': 4,
    'shares': 2,
  },
  {
    'user': 'Bob',
    'caption': 'Working on a cozy adoption corner setup at home.',
    'breed': 'beagle',
    'likes': 18,
    'comments': 3,
    'shares': 1,
  },
  {
    'user': 'Cara',
    'caption': 'Today\'s goal: find the perfect playful breed for my family.',
    'breed': 'husky',
    'likes': 31,
    'comments': 7,
    'shares': 4,
  },
];

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final DogApiService _dogApiService = DogApiService();
  late Future<List<_FeedPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  Future<List<_FeedPost>> _loadPosts() async {
    return Future.wait(
      _posts.map((post) async {
        String? imageUrl;
        try {
          imageUrl = await _dogApiService.fetchRandomImage(
            breed: post['breed'] as String,
            subBreed: post['subBreed'] as String?,
          );
        } catch (_) {
          imageUrl = null;
        }

        return _FeedPost(
          user: post['user'] as String,
          caption: post['caption'] as String,
          imageUrl: imageUrl,
          likes: post['likes'] as int,
          comments: post['comments'] as int,
          shares: post['shares'] as int,
        );
      }),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = _loadPosts();
    });
    await _postsFuture;
  }

  void _toggleLike(_FeedPost post) {
    setState(() {
      post.liked = !post.liked;
      post.likes += post.liked ? 1 : -1;
    });
  }

  void _addComment(_FeedPost post) {
    setState(() {
      post.comments += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commented on ${post.user}\'s post')),
    );
  }

  void _sharePost(_FeedPost post) {
    setState(() {
      post.shares += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shared ${post.user}\'s post')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Feed')),
      body: FutureBuilder<List<_FeedPost>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? <_FeedPost>[];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: posts.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stories From Dog Lovers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'A simple social-style feed with live dog photos from the API.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }

                final post = posts[i - 1];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade200,
                            child: Text(post.user[0]),
                          ),
                          title: Text(post.user),
                          subtitle: const Text('Dog enthusiast'),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: post.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: post.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.orange.shade100,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.orange.shade100,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.orange.shade100,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.pets, size: 72),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Text(post.caption),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              _FeedActionButton(
                                icon: post.liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                label: '${post.likes}',
                                color: post.liked
                                    ? Colors.pink
                                    : Colors.grey.shade700,
                                onTap: () => _toggleLike(post),
                              ),
                              const SizedBox(width: 12),
                              _FeedActionButton(
                                icon: Icons.chat_bubble_outline,
                                label: '${post.comments}',
                                color: Colors.grey.shade700,
                                onTap: () => _addComment(post),
                              ),
                              const SizedBox(width: 12),
                              _FeedActionButton(
                                icon: Icons.share,
                                label: '${post.shares}',
                                color: Colors.grey.shade700,
                                onTap: () => _sharePost(post),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class _FeedPost {
  final String user;
  final String caption;
  final String? imageUrl;
  int likes;
  int comments;
  int shares;
  bool liked;

  _FeedPost({
    required this.user,
    required this.caption,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    this.liked = false,
  });
}
