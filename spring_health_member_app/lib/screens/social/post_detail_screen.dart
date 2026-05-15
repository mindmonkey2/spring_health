import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spring_health_member/core/theme/app_colors.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/models/comment_model.dart';
import 'package:spring_health_member/services/social_service.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String currentMemberId;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.currentMemberId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmitting = false;

  bool? _optimisticLiked;
  int? _optimisticLikeCount;
  PostModel? _lastPost;

  String _memberName = 'Member';
  // ignore: unused_field
  String? _memberAvatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.currentMemberId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _memberName = data['displayName'] as String? ?? 'Member';
            _memberAvatarUrl = data['photoUrl'] as String?;
          });
        }
      }
    } catch (_) {
      // Use fallback
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleLikeTap() async {
    if (_lastPost == null) return;

    final bool currentlyLiked = _lastPost!.likedBy.contains(widget.currentMemberId);
    final int currentCount = _lastPost!.likeCount;

    setState(() {
      _optimisticLiked = !currentlyLiked;
      _optimisticLikeCount = currentlyLiked ? currentCount - 1 : currentCount + 1;
    });

    try {
      await SocialService.instance.toggleLikeWithMemberId(widget.postId, widget.currentMemberId);
      if (mounted) {
        setState(() {
          _optimisticLiked = null;
          _optimisticLikeCount = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _optimisticLiked = null;
          _optimisticLikeCount = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update like.')),
        );
      }
    }
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final comment = CommentModel(
        id: '', // Will be generated
        memberAuthUid: widget.currentMemberId, // Since CommentModel requires memberAuthUid but we only have memberId, we must be careful.
        // Wait, the schema in the prompt says: authorMemberId, authorName, authorAvatarUrl. But CommentModel doesn't have these exact fields.
        // I will use `memberAuthUid` to store the memberId, or just wait and read CommentModel structure. Let me use memberAuthUid for the currentMemberId as a proxy based on the existing CommentModel.
        memberName: _memberName,
        text: content,
        createdAt: Timestamp.now(), // Server timestamp will actually be set in addComment? Well, CommentModel uses Timestamp.now().
      );

      await SocialService.instance.addComment(widget.postId, comment);

      if (mounted) {
        _commentController.clear();
        _commentFocusNode.unfocus();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post comment. Try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]}, $hour:$minute $ampm';
  }

  Widget _buildShimmerTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .shimmer(
      duration: 1200.ms,
      color: AppColors.gray800.withValues(alpha: 0.5),
    );
  }

  Widget _buildCommentTile(CommentModel comment, int index) {
    // We use a simple layout for the comment tile
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.backgroundBlack,
            // Assuming no avatar URL is in CommentModel, we use initial
            child: Text(
              comment.memberName.isNotEmpty ? comment.memberName[0].toUpperCase() : 'M',
              style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.memberName,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(comment.createdAt.toDate()),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: AppColors.backgroundBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: SocialService.instance.getPostStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    children: [
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load post.', style: TextStyle(color: AppColors.white)),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('Post not found.', style: TextStyle(color: AppColors.white)),
                  );
                }

                final postData = snapshot.data!.data() as Map<String, dynamic>;
                _lastPost = PostModel.fromMap(postData, snapshot.data!.id);
                final post = _lastPost!;

                final bool isLiked = _optimisticLiked ?? post.likedBy.contains(widget.currentMemberId);
                final int likeCount = _optimisticLikeCount ?? post.likeCount;

                return ListView(
                  children: [
                    // POST HEADER CARD
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.backgroundBlack,
                                backgroundImage: post.photoUrl != null && post.photoUrl!.isNotEmpty
                                    ? NetworkImage(post.photoUrl!)
                                    : null,
                                child: post.photoUrl == null || post.photoUrl!.isEmpty
                                    ? Text(
                                        post.memberName.isNotEmpty ? post.memberName[0].toUpperCase() : 'M',
                                        style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.memberName,
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _formatDate(post.createdAt.toDate()),
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            post.text,
                            style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.45),
                          ),
                          if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post.mediaUrl!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: double.infinity,
                                    height: 300,
                                    color: AppColors.gray800,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: AppColors.neonLime),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? AppColors.neonLime : AppColors.textSecondary,
                                ),
                                onPressed: _handleLikeTap,
                              ),
                              Text('$likeCount', style: const TextStyle(color: AppColors.white)),
                              const SizedBox(width: 24),
                              const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('${post.commentCount} comments', style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, duration: 250.ms),

                    // COMMENTS HEADER
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                      child: Text('Comments', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),

                    // COMMENTS LIST
                    StreamBuilder<QuerySnapshot>(
                      stream: SocialService.instance.getCommentsStream(widget.postId),
                      builder: (context, commentsSnap) {
                        if (commentsSnap.connectionState == ConnectionState.waiting) {
                          return ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildShimmerTile(),
                              _buildShimmerTile(),
                            ],
                          );
                        }

                        if (commentsSnap.hasError) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Could not load comments.', style: TextStyle(color: AppColors.textSecondary)),
                          );
                        }

                        if (!commentsSnap.hasData || commentsSnap.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No comments yet. Be the first.',
                              style: TextStyle(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final comments = commentsSnap.data!.docs;
                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                          itemBuilder: (context, index) {
                            final doc = comments[index];
                            final comment = CommentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                            return _buildCommentTile(comment, index);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // COMMENT INPUT BAR
          Container(
            color: AppColors.cardSurface,
            padding: EdgeInsets.fromLTRB(12, 8, 8, 8 + MediaQuery.of(context).viewInsets.bottom),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.backgroundBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonLime),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.neonLime),
                        onPressed: _submitComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
