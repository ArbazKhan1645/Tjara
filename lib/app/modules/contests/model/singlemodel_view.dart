import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/contests/controllers/contests_controller.dart';
import 'package:tjara/app/modules/contests/model/contest_model.dart';
import 'package:tjara/app/modules/contests/service/context_share.dart';
import 'package:tjara/app/modules/contests/views/comment.dart';
import 'package:tjara/app/modules/contests/views/count_down.dart';
import 'package:tjara/app/modules/contests/views/winner_reveal.dart';

class ContestScreenSingle extends StatelessWidget {
  final ContestController controller = Get.find<ContestController>();

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);
  static const Color darkTeal = Color(0xFF006666);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color orangeAccent = Color(0xFFFFA500);

  ContestScreenSingle({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerLoading();
      }

      if (controller.error.value.isNotEmpty) {
        return _buildErrorState();
      }

      final contest = controller.contest.value;
      final isExpired = controller.isContestExpired();
      final hasParticipated = controller.hasUserParticipated();

      return Scaffold(
        backgroundColor: const Color(0xFFF0F4F4),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(contest),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasParticipated && !isExpired)
                      _buildParticipatedBanner(),
                    if (hasParticipated && !isExpired)
                      const SizedBox(height: 10),

                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child:
                          isExpired
                              ? _buildExpiredBanner()
                              : _buildActiveTimer(),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildContestInfo(contest),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildActionButtons(),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child:
                          isExpired
                              ? WinnerReveal(contest: contest)
                              : hasParticipated
                              ? _buildUserResults()
                              : _buildQuestions(contest),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: CommentsSection(contest: contest),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: _buildBottomSheet(isExpired, hasParticipated),
      );
    });
  }

  Widget _buildAppBar(ContestModel contest) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFFfea52d),
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.clearSelectedModel();
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(51), width: 1),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            RewardShareService.showShareDialog(
              context: Get.context!,
              contestName: contest.name ?? '',
              contestUrl: 'https://libanbuy.com/contests/${contest.slug ?? ''}',
              onShare: () => Get.back(),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(77),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(51), width: 1),
            ),
            child: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            contest.thumbnail?.media?.optimizedMediaUrl != null
                ? CachedNetworkImage(
                  imageUrl: contest.thumbnail!.media!.optimizedMediaUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildImagePlaceholder(),
                  errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                )
                : _buildImagePlaceholder(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.transparent],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                contest.name ?? 'Contest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade500, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contest Ended',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View results below',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipatedBanner() {
    final userParticipation = controller.getUserParticipation();
    final score = userParticipation?.correctAnswers ?? 0;
    final total = userParticipation?.totalQuestions ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryTeal, accentTeal]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Already Participated',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your Score: $score/$total',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${((score / (total > 0 ? total : 1)) * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer() {
    return CountdownTimer(
      endTime: controller.contest.value.endTime,
      onExpired:
          () => controller.fetchContest(
            controller.contest.value.slug ?? controller.contest.value.id ?? '',
          ),
    );
  }

  Widget _buildContestInfo(ContestModel contest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contest.description != null) ...[
            Html(
              data: contest.description!,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14),
                  color: Colors.grey.shade700,
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),
            const SizedBox(height: 16),
          ],
          if (contest.meta?.contestPrizeDetails != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    goldAccent.withAlpha(38),
                    orangeAccent.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: goldAccent.withAlpha(77), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          goldAccent.withAlpha(77),
                          orangeAccent.withAlpha(51),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: orangeAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIZE',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contest.meta!.contestPrizeDetails!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.visibility_rounded,
                    contest.meta?.views ?? '0',
                    'Views',
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    Icons.people_rounded,
                    '${contest.participants?.total ?? 0}',
                    'Participants',
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    Icons.favorite_rounded,
                    contest.meta?.likes ?? '0',
                    'Likes',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: primaryTeal),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isLiked = controller.isContestLiked();
      final isLikeLoading = controller.isLikeLoading.value;

      return Row(
        children: [
          Expanded(
            child: _LikeButton(
              isLiked: isLiked,
              isLoading: isLikeLoading,
              count: controller.contest.value.meta?.likes ?? '0',
              onTap: () {
                HapticFeedback.lightImpact();
                controller.toggleLike();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.comment_rounded,
              label: 'Comment',
              count:
                  '${controller.contest.value.comments?.comments?.totalComments ?? 0}',
              color: primaryTeal,
              onTap: () => HapticFeedback.lightImpact(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              color: Colors.blue.shade400,
              onTap: () {
                HapticFeedback.lightImpact();
                RewardShareService.showShareDialog(
                  context: Get.context!,
                  contestName: controller.contest.value.name ?? '',
                  contestUrl:
                      'https://libanbuy.com/contests/${controller.contest.value.slug ?? ''}',
                  onShare: () => Get.back(),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildUserResults() {
    final userParticipation = controller.getUserParticipation();
    if (userParticipation == null) return const SizedBox();

    final percentage = userParticipation.percentageCorrect ?? 0.0;
    final isEligible = userParticipation.isEligibleForPrize == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    percentage >= 70
                        ? Colors.green.shade400
                        : percentage >= 40
                        ? orangeAccent
                        : Colors.red.shade400,
                    percentage >= 70
                        ? Colors.green.shade600
                        : percentage >= 40
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (percentage >= 70
                            ? Colors.green
                            : percentage >= 40
                            ? Colors.orange
                            : Colors.red)
                        .withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildResultRow(
            'Correct Answers',
            '${userParticipation.correctAnswers}/${userParticipation.totalQuestions}',
            Icons.check_circle_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            'Accuracy',
            '${percentage.toStringAsFixed(1)}%',
            Icons.percent_rounded,
            primaryTeal,
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            'Prize Eligible',
            isEligible ? 'Yes' : 'No',
            Icons.emoji_events_rounded,
            isEligible ? goldAccent : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions(ContestModel contest) {
    if (contest.questions == null || contest.questions!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Icons.quiz_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Contest Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contest.questions!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder:
              (_, index) => _QuestionCard(
                question: contest.questions![index],
                index: index,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(bool isExpired, bool hasParticipated) {
    if (isExpired || hasParticipated) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    controller.isSubmitting.value
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : const [primaryTeal, accentTeal],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  controller.isSubmitting.value
                      ? null
                      : [
                        BoxShadow(
                          color: primaryTeal.withAlpha(77),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    controller.isSubmitting.value
                        ? null
                        : () {
                          HapticFeedback.mediumImpact();
                          controller.submitAnswers();
                        },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child:
                      controller.isSubmitting.value
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Submit Answers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFfea52d)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: Colors.white.withAlpha(77),
              size: 64,
            ),
            const SizedBox(height: 8),
            Text(
              'Contest',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFfea52d),
            flexibleSpace: Shimmer.fromColors(
              baseColor: const Color(0xFFfea52d),
              highlightColor: const Color(0xFFfea52d),
              child: Container(color: const Color(0xFFfea52d)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        height: index == 0 ? 100 : 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        backgroundColor: primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => controller.clearSelectedModel(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.error.value,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryTeal, accentTeal],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryTeal.withAlpha(77),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        () => controller.fetchContest(
                          controller.selectedModel.value?.slug ??
                              controller.selectedModel.value?.id ??
                              '',
                        ),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Try Again',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final bool isLoading;
  final String count;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.isLoading,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLiked ? Colors.red.shade500 : Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isLiked ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLiked ? Colors.red.shade200 : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              isLoading
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                  : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isLiked),
                      color: color,
                      size: 24,
                    ),
                  ),
              const SizedBox(height: 6),
              Text(
                count,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
              Text(
                isLiked ? 'Liked' : 'Like',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? count;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              if (count != null)
                Text(
                  count!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;

  const _QuestionCard({required this.question, required this.index});

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContestController>();

    return Obx(() {
      final selectedAnswer = controller.userAnswers[question.id];

      return Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryTeal, accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question ?? 'No Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (question.option1 != null)
              _OptionButton(
                option: question.option1!,
                isSelected: selectedAnswer == question.option1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectAnswer(question.id!, question.option1!);
                },
              ),
            if (question.option2 != null)
              _OptionButton(
                option: question.option2!,
                isSelected: selectedAnswer == question.option2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectAnswer(question.id!, question.option2!);
                },
              ),
            if (question.option3 != null)
              _OptionButton(
                option: question.option3!,
                isSelected: selectedAnswer == question.option3,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectAnswer(question.id!, question.option3!);
                },
              ),
            if (question.option4 != null)
              _OptionButton(
                option: question.option4!,
                isSelected: selectedAnswer == question.option4,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectAnswer(question.id!, question.option4!);
                },
              ),
          ],
        ),
      );
    });
  }
}

class _OptionButton extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryTeal = Color(0xFF008080);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? primaryTeal.withAlpha(26)
                      : const Color(0xFFF5F7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? primaryTeal : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? primaryTeal : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? primaryTeal : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? primaryTeal : Colors.grey.shade800,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
