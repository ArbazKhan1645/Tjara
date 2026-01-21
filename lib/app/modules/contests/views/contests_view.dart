import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/contests/model/singlemodel_view.dart';
import 'package:tjara/app/modules/contests/controllers/contests_controller.dart';

class ContestsView extends GetView<ContestController> {
  const ContestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContestScreen();
  }
}

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  final ContestController controller = Get.put(ContestController());
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Theme colors
  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);
  static const Color lightTeal = Color(0xFF00C9C9);
  static const Color darkTeal = Color(0xFF006666);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color orangeAccent = Color(0xFFFFA500);

  // Helper method to get contest status
  _ContestStatus _getContestStatus(dynamic contest) {
    final startTime = contest.startTime;
    final endTime = contest.endTime;

    if (startTime == null || endTime == null) {
      return _ContestStatus.active;
    }

    try {
      final now = DateTime.now();
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);

      if (now.isBefore(start)) {
        return _ContestStatus.upcoming;
      } else if (now.isAfter(end)) {
        return _ContestStatus.expired;
      } else {
        // Check if ending within 24 hours
        final difference = end.difference(now);
        if (difference.inHours < 24) {
          return _ContestStatus.endingSoon;
        }
        return _ContestStatus.active;
      }
    } catch (e) {
      return _ContestStatus.active;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    _searchController.addListener(() {
      _searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<dynamic> get filteredContests {
    if (_searchQuery.value.isEmpty) return controller.contests;
    return controller.contests.where((contest) {
      final name = contest.name?.toLowerCase() ?? '';
      final desc = contest.description?.toLowerCase() ?? '';
      final query = _searchQuery.value.toLowerCase();
      return name.contains(query) || desc.contains(query);
    }).toList();
  }

  void _handleBackPress() {
    if (controller.handleBackNavigation()) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F4),
        body: Obx(() {
          if (controller.selectedModel.value != null) {
            return ContestScreenSingle();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                _buildContent(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfea52d), // top
            const Color(0xFFfea52d), // top Color(0xFFfea52d), // top
            const Color(0xFFfea52d), // top
            const Color(0xFFfea52d), // top Color(0xFFfea52d), // top

            const Color(0xFFfea52d), // top
            const Color(0xFFfea52d), // top
            const Color(0xFFfea52d).withOpacity(0.05), // top
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // Back Button with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: _buildBackButton(),
                  ),
                  const SizedBox(width: 16),
                  // Title with slide animation
                  Expanded(
                    child: TweenAnimationBuilder<Offset>(
                      tween: Tween(
                        begin: const Offset(-0.5, 0),
                        end: Offset.zero,
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, offset, child) {
                        return FractionalTranslation(
                          translation: offset,
                          child: child,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contests',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: goldAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: goldAccent.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      size: 14,
                                      color: goldAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Win amazing prizes!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: goldAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Card with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchCard(),
              ),
            ),

            const SizedBox(height: 20),

            // Wave decoration
            // ClipPath(
            //   clipper: _WaveClipper(),
            //   child: Container(height: 30, color: const Color(0xFFF0F4F4)),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleBackPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contest Count
          Obx(() {
            final count = filteredContests.length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryTeal, accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    text: 'Discover ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '$count',
                        style: const TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      TextSpan(
                        text: ' active contests',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryTeal.withOpacity(0.1), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search contests...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: primaryTeal.withOpacity(0.6),
                  size: 22,
                ),
                suffixIcon: Obx(() {
                  if (_searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      onPressed: () => _searchController.clear(),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      switch (controller.status.value) {
        case LoadingStatus.loading:
          return _buildShimmerLoading();

        case LoadingStatus.loaded:
          final contests = filteredContests;
          if (contests.isEmpty) {
            return SliverFillRemaining(child: _buildEmptyState());
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildContestCard(contests[index], index),
                childCount: contests.length,
              ),
            ),
          );

        case LoadingStatus.error:
          return SliverFillRemaining(child: _buildErrorState());

        default:
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(primaryTeal),
              ),
            ),
          );
      }
    });
  }

  Widget _buildContestCard(contest, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.setSelectedModel(contest);
          controller.fetchContest(
            controller.selectedModel.value?.id.toString() ?? '',
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child:
                        contest.thumbnail?.media?.optimizedMediaUrl != null
                            ? CachedNetworkImage(
                              imageUrl:
                                  contest.thumbnail!.media!.optimizedMediaUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _buildImagePlaceholder(),
                              errorWidget:
                                  (_, __, ___) => _buildImagePlaceholder(),
                            )
                            : _buildImagePlaceholder(),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildStatusBadge(_getContestStatus(contest)),
                  ),

                  // Views Badge
                  if (contest.meta?.views != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${contest.meta!.views}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      contest.name ?? 'Unnamed Contest',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Shop Name
                    if (contest.shop?.shop?.name != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.store_rounded,
                              size: 16,
                              color: primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              contest.shop!.shop!.name!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 14),

                    // Date Range
                    if (contest.startTime != null || contest.endTime != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primaryTeal.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${controller.getFormattedDate(contest.startTime)} - ${controller.getFormattedDate(contest.endTime)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Description
                    if (contest.description != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: Html(
                          data: contest.description!,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(13),
                              color: Colors.grey.shade600,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          },
                        ),
                      ),
                    ],

                    // Prize Section
                    if (contest.meta?.contestPrizeDetails != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              goldAccent.withOpacity(0.15),
                              orangeAccent.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: goldAccent.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    goldAccent.withOpacity(0.3),
                                    orangeAccent.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: orangeAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prize',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    contest.meta!.contestPrizeDetails!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Action Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryTeal, accentTeal],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.setSelectedModel(contest);
                            controller.fetchContest(
                              controller.selectedModel.value?.id.toString() ??
                                  '',
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_ContestStatus status) {
    Color gradientStart;
    Color gradientEnd;
    String statusText;
    IconData? statusIcon;

    switch (status) {
      case _ContestStatus.active:
        gradientStart = primaryTeal;
        gradientEnd = accentTeal;
        statusText = 'Active';
        statusIcon = null;
        break;
      case _ContestStatus.expired:
        gradientStart = Colors.red.shade500;
        gradientEnd = Colors.red.shade700;
        statusText = 'Ended';
        statusIcon = Icons.schedule_rounded;
        break;
      case _ContestStatus.upcoming:
        gradientStart = Colors.blue.shade500;
        gradientEnd = Colors.blue.shade700;
        statusText = 'Upcoming';
        statusIcon = Icons.upcoming_rounded;
        break;
      case _ContestStatus.endingSoon:
        gradientStart = orangeAccent;
        gradientEnd = Colors.orange.shade700;
        statusText = 'Ending Soon';
        statusIcon = Icons.timer_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            Icon(
              statusIcon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
          ] else ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryTeal.withOpacity(0.1), accentTeal.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: primaryTeal.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Contest',
              style: TextStyle(
                color: primaryTeal.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Container(
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryTeal.withOpacity(0.15),
                    accentTeal.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 56,
                color: primaryTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.value.isNotEmpty
                  ? 'No contests found'
                  : 'No active contests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.value.isNotEmpty
                  ? 'Try a different search term'
                  : 'Check back later for new contests',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value,
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
                    color: primaryTeal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.retryFetch,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
    );
  }
}

// Custom Wave Clipper
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 15);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, size.height - 30);
    final secondEndPoint = Offset(size.width, size.height - 10);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Enum for contest status
enum _ContestStatus {
  active,
  expired,
  upcoming,
  endingSoon,
}
