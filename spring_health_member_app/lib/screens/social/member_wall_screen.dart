import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/core/theme/app_colors.dart';
import 'package:spring_health_member/core/theme/app_text_styles.dart';
import 'package:spring_health_member/models/member_model.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/services/social_service.dart';
import 'package:spring_health_member/widgets/social/post_card_widget.dart';
import 'package:spring_health_member/screens/social/post_detail_screen.dart';

class MemberWallScreen extends StatefulWidget {
  final String memberId;
  final String currentMemberId;
  final SocialService? socialServiceOverride;

  const MemberWallScreen({
    super.key,
    required this.memberId,
    required this.currentMemberId,
    @visibleForTesting this.socialServiceOverride,
  });

  @override
  State<MemberWallScreen> createState() => _MemberWallScreenState();
}

class _MemberWallScreenState extends State<MemberWallScreen> {
  final Map<String, ValueNotifier<bool>> _likedNotifiers = {};
  late Stream<List<PostModel>> _postsStream;
  SocialService get _socialService => widget.socialServiceOverride ?? SocialService.instance;

  bool _isLoadingMember = true;
  MemberModel? _member;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _postsStream = _socialService.streamMemberPosts(widget.memberId);
    _fetchMemberProfile();
  }

  Future<void> _fetchMemberProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.memberId)
          .get();

      if (doc.exists) {
        setState(() {
          _member = MemberModel.fromMap(doc.data()!, id: doc.id);
          _isLoadingMember = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Member not found';
          _isLoadingMember = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load member profile';
        _isLoadingMember = false;
      });
    }
  }

  ValueNotifier<bool> _getLikedNotifier(PostModel post) {
    if (!_likedNotifiers.containsKey(post.id)) {
      final bool currentlyLiked = post.likedBy.contains(widget.currentMemberId);
      _likedNotifiers[post.id] = ValueNotifier<bool>(currentlyLiked);
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
      await _socialService.toggleLikeWithMemberId(post.id, widget.currentMemberId);
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

  Widget _buildMemberHeader() {
    if (_isLoadingMember) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.neonLime),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            _errorMessage!,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    if (_member == null) return const SizedBox.shrink();

    final isSelf = widget.memberId == widget.currentMemberId;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.backgroundBlack,
            backgroundImage: _member!.photoUrl != null && _member!.photoUrl!.isNotEmpty
                ? NetworkImage(_member!.photoUrl!)
                : null,
            child: _member!.photoUrl == null || _member!.photoUrl!.isEmpty
                ? Text(
                    _member!.name.isNotEmpty ? _member!.name[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _member!.name,
                  style: AppTextStyles.heading2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _member!.branch,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neonLime),
                ),
                const SizedBox(height: 4),
                Text(
                  _member!.membershipPlan,
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
                ),
                if (isSelf) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Your Wall',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: Text(
          _member?.name ?? 'Member Wall',
          style: AppTextStyles.heading3,
        ),
        backgroundColor: AppColors.backgroundBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          _buildMemberHeader(),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.neonLime),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading posts',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  final isSelf = widget.memberId == widget.currentMemberId;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No posts yet.',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
                        ),
                        if (isSelf) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonLime,
                              foregroundColor: AppColors.backgroundBlack,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/social/create', arguments: {
                                'memberId': widget.currentMemberId,
                                'memberAuthUid': '', // We might not have this, but let's assume it's optional or handled.
                                'memberName': _member?.name ?? '',
                                'branch': _member?.branch ?? '',
                              });
                            },
                            child: const Text('Create your first post'),
                          ),
                        ],
                      ],
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(
                                  postId: post.id,
                                  currentMemberId: widget.currentMemberId,
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
                                  currentMemberId: widget.currentMemberId,
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
          ),
        ],
      ),
    );
  }
}
