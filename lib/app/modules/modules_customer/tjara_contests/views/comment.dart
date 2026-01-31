import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/controllers/contests_controller.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class CommentsSection extends StatefulWidget {
  final ContestModel contest;

  const CommentsSection({super.key, required this.contest});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  final ContestController controller = Get.find<ContestController>();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToId;
  String? _replyingToName;

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showLoginDialog() {
    showContactDialog(context, const LoginUi());
  }

  void _submitComment() {
    if (Get.find<AuthService>().authCustomer == null) {
      _showLoginDialog();
      return;
    }
    if (_commentController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    controller.addComment(
      _commentController.text.trim(),
      parentId: _replyingToId,
    );

    _commentController.clear();
    _cancelReply();
  }

  void _startReply(String commentId, String userName) {
    HapticFeedback.selectionClick();
    setState(() {
      _replyingToId = commentId;
      _replyingToName = userName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.contest.comments?.comments?.comments ?? [];
    final totalComments = widget.contest.comments?.comments?.totalComments ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryTeal, accentTeal],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryTeal.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalComments',
                style: const TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Comment Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withAlpha(20),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Reply indicator
              if (_replyingToId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: primaryTeal.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryTeal.withAlpha(51),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.reply_rounded, size: 18, color: primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Replying to $_replyingToName',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _cancelReply,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryTeal.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input field
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryTeal.withAlpha(26),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              _replyingToId != null
                                  ? 'Write a reply...'
                                  : 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => GestureDetector(
                      onTap:
                          controller.isCommentLoading.value
                              ? null
                              : _submitComment,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                controller.isCommentLoading.value
                                    ? [
                                      Colors.grey.shade400,
                                      Colors.grey.shade500,
                                    ]
                                    : const [primaryTeal, accentTeal],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow:
                              controller.isCommentLoading.value
                                  ? null
                                  : [
                                    BoxShadow(
                                      color: primaryTeal.withAlpha(51),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                        ),
                        child:
                            controller.isCommentLoading.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Comments List
        if (comments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryTeal.withAlpha(15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryTeal.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 40,
                      color: primaryTeal.withAlpha(128),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first to comment!',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return _CommentCard(comment: comment, onReply: _startReply);
            },
          ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final dynamic comment;
  final Function(String, String) onReply;

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);

  const _CommentCard({required this.comment, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final user = comment.user?.user;
    final userName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final createdAt =
        comment.createdAt != null
            ? timeago.format(DateTime.parse(comment.createdAt!))
            : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryTeal, accentTeal],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isNotEmpty ? userName : 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      createdAt,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.description ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap:
                () => onReply(
                  comment.id,
                  userName.isNotEmpty ? userName : 'User',
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryTeal.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.reply_rounded, size: 16, color: primaryTeal),
                  SizedBox(width: 6),
                  Text(
                    'Reply',
                    style: TextStyle(
                      color: primaryTeal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Replies
          if (comment.replies != null && comment.replies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: primaryTeal.withAlpha(51), width: 2),
                ),
              ),
              child: Column(
                children:
                    comment.replies
                        .map<Widget>(
                          (reply) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReplyCard(reply: reply),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final dynamic reply;

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);

  const _ReplyCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    final user = reply.user?.user;
    final userName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final createdAt =
        reply.createdAt != null
            ? timeago.format(DateTime.parse(reply.createdAt!))
            : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryTeal.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: primaryTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isNotEmpty ? userName : 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      createdAt,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reply.description ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
