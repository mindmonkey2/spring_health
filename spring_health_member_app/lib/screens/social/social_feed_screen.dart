import 'package:flutter/material.dart';
import 'package:spring_health_member/core/theme/app_colors.dart';
import 'package:spring_health_member/core/theme/app_text_styles.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/services/social_service.dart';
import 'package:spring_health_member/widgets/social/post_card_widget.dart';
import 'post_detail_screen.dart';
import 'member_wall_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  final String memberId;
  final String memberAuthUid;
  final String memberName;
  final String branch;
  final SocialService? socialServiceOverride;

  const SocialFeedScreen({
    super.key,
    required this.memberId,
    required this.memberAuthUid,
    required this.memberName,
    required this.branch,
    @visibleForTesting this.socialServiceOverride,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  bool _showGlobalFeed = false;
  final Map<String, ValueNotifier<bool>> _likedNotifiers = {};
  late Stream<List<PostModel>> _feedStream;
  SocialService get _socialService => widget.socialServiceOverride ?? SocialService.instance;

  @override
  void initState() {
    super.initState();
    _feedStream = _socialService.streamFeedByBranch(widget.branch);
  }

  ValueNotifier<bool> _getLikedNotifier(PostModel post) {
    if (!_likedNotifiers.containsKey(post.id)) {
      _likedNotifiers[post.id] = ValueNotifier<bool>(false);
      _socialService.isLikedBy(post.id, widget.memberAuthUid).then((isLiked) {
         if (mounted && _likedNotifiers.containsKey(post.id)) {
            _likedNotifiers[post.id]!.value = isLiked;
         }
      });
    }
    return _likedNotifiers[post.id]!;
  }

  @override
  void dispose() {
    for (var notifier in _likedNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _handleLike(PostModel post) async {
    final notifier = _getLikedNotifier(post);
    final previousState = notifier.value;

    notifier.value = !previousState;

    try {
      await _socialService.toggleLike(post.id, widget.memberAuthUid);
    } catch (e) {
      if (mounted && _likedNotifiers.containsKey(post.id)) {
         notifier.value = previousState;
      }
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update like status')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: Text('Spring Social', style: AppTextStyles.heading3),
        backgroundColor: AppColors.backgroundBlack,
        actions: [
          Row(
            children: [
              Text(
                'My Branch',
                style: TextStyle(
                  color: !_showGlobalFeed ? AppColors.neonLime : AppColors.gray400,
                  fontWeight: !_showGlobalFeed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Switch(
                value: _showGlobalFeed,
                activeTrackColor: AppColors.neonLime,
                onChanged: (value) {
                  setState(() {
                    _showGlobalFeed = value;
                    _feedStream = _showGlobalFeed
                        ? _socialService.streamGlobalFeed()
                        : _socialService.streamFeedByBranch(widget.branch);
                  });
                },
              ),
              Text(
                'Global',
                style: TextStyle(
                  color: _showGlobalFeed ? AppColors.neonLime : AppColors.gray400,
                  fontWeight: _showGlobalFeed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _feedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading feed',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Text(
                'No posts yet. Be the first!',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ValueListenableBuilder<bool>(
                valueListenable: _getLikedNotifier(post),
                builder: (context, isLiked, child) {
                  return PostCardWidget(
                    post: post,
                    isLiked: isLiked,
                    onHeaderTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberWallScreen(
                            memberId: post.memberId,
                            currentMemberId: widget.memberId,
                          ),
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            postId: post.id,
                            currentMemberId: widget.memberId,
                          ),
                        ),
                      );
                    },
                    onLikePressed: () => _handleLike(post),
                    onCommentPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(
                            postId: post.id,
                            currentMemberId: widget.memberId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonLime,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.pushNamed(context, '/social/create', arguments: {
            'memberId': widget.memberId,
            'memberAuthUid': widget.memberAuthUid,
            'memberName': widget.memberName,
            'branch': widget.branch,
          });
        },
      ),
    );
  }
}
