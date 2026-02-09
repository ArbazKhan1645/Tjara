import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/tjara_videos_section.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/flash_deal_detail_screen.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/featurebadge.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/home_categories.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';

/// Optimized Flash Deals Banner - Independent API management
class PromotionBannerWidget extends StatefulWidget {
  const PromotionBannerWidget({super.key});

  @override
  State<PromotionBannerWidget> createState() => _PromotionBannerWidgetState();
}

class _PromotionBannerWidgetState extends State<PromotionBannerWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // API URL
  static final String _flashDealApiUrl =
      'https://api.libanbuy.com/api/products/flash-deals?with=gallery,attribute_items,rating,video,meta&fetchNewDeals=true&_t=${DateTime.now().microsecondsSinceEpoch}';

  // State management
  Timer? _pollingTimer;
  bool _isDisposed = false;
  bool _isLoadingFlashDeal = false;

  // Deal state
  String _dealStatus =
      'loading'; // loading, active, interval, scheduled, none, error
  String? _productName;
  String? _productId;
  DateTime? _scheduledStartTime;

  // Countdown using ValueNotifier (optimized)
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier(0);
  Timer? _countdownTimer;

  // Previous state for comparison
  String? _previousDealStatus;
  String? _previousProductId;
  int? _previousRemainingSeconds;

  @override
  void initState() {
    super.initState();
    _fetchFlashDealData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // API LOGIC - Isolated from controller
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _fetchFlashDealData() async {
    if (_isDisposed || _isLoadingFlashDeal) return;
    _isLoadingFlashDeal = true;

    try {
      final response = await http
          .get(
            Uri.parse(_flashDealApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-Request-From': 'Application',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (!_isDisposed) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _handleApiResponse(data);
        } else {
          // Non-200: No deal available
          _handleNoDeal();
        }
      }
    } catch (e) {
      debugPrint('Flash deal fetch error: $e');
      if (!_isDisposed) {
        _handleNoDeal();
      }
    } finally {
      _isLoadingFlashDeal = false;
    }
  }

  void _handleApiResponse(Map<String, dynamic> data) {
    final newStatus = data['deal_status'] ?? '';
    final newProductId =
        data['current_deal_product_id'] ??
        data['interval_info']?['next_deal_product_id'];
    final productData = data['product'];

    // Parse scheduled time if exists
    DateTime? newScheduledTime;
    if (data['scheduled_start_time'] != null) {
      try {
        newScheduledTime = DateTime.parse(data['scheduled_start_time']);
      } catch (e) {
        debugPrint('Error parsing scheduled time: $e');
      }
    }

    // Extract product name
    String? newProductName;
    if (productData != null && productData['name'] != null) {
      newProductName = productData['name'];
    }

    // Calculate remaining seconds
    int newRemainingSeconds = 0;
    if (newStatus == 'active') {
      newRemainingSeconds = data['sequence_info']?['seconds_remaining'] ?? 0;
    } else if (newStatus == 'interval') {
      newRemainingSeconds = data['interval_info']?['seconds_remaining'] ?? 0;
    } else if (newStatus == 'scheduled' && newScheduledTime != null) {
      final now = DateTime.now();
      final difference = newScheduledTime.difference(now);
      newRemainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;
    }

    // Check if data actually changed
    bool dataChanged = false;

    if (newStatus != _previousDealStatus ||
        newProductId != _previousProductId ||
        (newRemainingSeconds - (_previousRemainingSeconds ?? 0)).abs() > 2) {
      dataChanged = true;
    }

    // Update tracking variables
    _previousDealStatus = newStatus;
    _previousProductId = newProductId;
    _previousRemainingSeconds = newRemainingSeconds;

    // Only setState if meaningful data changed
    if (dataChanged) {
      if (mounted && !_isDisposed) {
        setState(() {
          _dealStatus = newStatus.isEmpty ? 'none' : newStatus;
          _productName = newProductName;
          _productId = newProductId;
          _scheduledStartTime = newScheduledTime;
        });
      }
    } else {
      // Update without setState
      _dealStatus = newStatus.isEmpty ? 'none' : newStatus;
      _productName = newProductName;
      _productId = newProductId;
      _scheduledStartTime = newScheduledTime;
    }

    // Start countdown
    if (_remainingSecondsNotifier.value != newRemainingSeconds) {
      _startCountdown(newRemainingSeconds);
    }

    // Start or stop polling based on status
    _managePolling(newStatus);
  }

  void _handleNoDeal() {
    // No deal or error - stop everything
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    if (_dealStatus != 'none') {
      if (mounted && !_isDisposed) {
        setState(() {
          _dealStatus = 'none';
          _productName = null;
          _productId = null;
          _scheduledStartTime = null;
        });
      }
      _remainingSecondsNotifier.value = 0;
    }
  }

  void _managePolling(String status) {
    // Only poll when deal is active, interval, or scheduled
    if (status == 'active' || status == 'interval' || status == 'scheduled') {
      if (_pollingTimer == null || !_pollingTimer!.isActive) {
        _startPolling();
      }
    } else {
      // Stop polling for other statuses
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isDisposed) {
        _fetchFlashDealData();
      }
    });
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.value = seconds;

    if (seconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) {
        _countdownTimer?.cancel();
        return;
      }

      if (_remainingSecondsNotifier.value > 0) {
        _remainingSecondsNotifier.value--;
      } else {
        _countdownTimer?.cancel();
        _fetchFlashDealData(); // Fetch new data when countdown ends
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    super.build(context);

    switch (_dealStatus) {
      case 'loading':
        return _buildPromotionBanner(); // Show regular banner while loading
      case 'active':
        return _buildActiveFlashDealBanner();
      case 'interval':
        return _buildIntervalBanner();
      case 'scheduled':
        return _buildScheduledBanner();
      case 'sequence_completed':
      case 'none':
      case 'error':
      default:
        return _buildPromotionBanner();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE FLASH DEAL BANNER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveFlashDealBanner() {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfea52d),
            const Color(0xFFfea52d).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 185,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color.fromARGB(255, 243, 210, 154).withOpacity(0.50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.white, size: 28),
                            SizedBox(width: 4),
                            Text(
                              'Flash Deal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ends in:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CountdownTimerRow(
                          remainingNotifier: _remainingSecondsNotifier,
                          formatTime: _formatTime,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const FlashDealDetailScreen(),
                              preventDuplicates: false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SHOP NOW',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 255, 145, 0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: Image(
                        image: controller.cachedShoeImage,
                        height: 180,
                        width: 180,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FeatureBadgesWidget(),

          const CategorySection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERVAL BANNER (Next deal coming soon)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildIntervalBanner() {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfea52d),
            const Color(0xFFfea52d).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 185,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color.fromARGB(255, 243, 210, 154).withOpacity(0.50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.white, size: 28),
                            SizedBox(width: 4),
                            Text(
                              'Next Deal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Starts in:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CountdownTimerRow(
                          remainingNotifier: _remainingSecondsNotifier,
                          formatTime: _formatTime,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const FlashDealDetailScreen(),
                              preventDuplicates: false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VIEW DEAL',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 255, 145, 0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: Image(
                        image: controller.cachedShoeImage,
                        height: 180,
                        width: 180,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FeatureBadgesWidget(),
          const CategorySection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULED BANNER (Deal scheduled for future)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildScheduledBanner() {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfea52d),
            const Color(0xFFfea52d).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 185,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color.fromARGB(255, 243, 210, 154).withOpacity(0.50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.upcoming, color: Colors.white, size: 28),
                            SizedBox(width: 4),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Deal starts in:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CountdownTimerRow(
                          remainingNotifier: _remainingSecondsNotifier,
                          formatTime: _formatTime,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const FlashDealDetailScreen(),
                              preventDuplicates: false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREVIEW',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 255, 145, 0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: Image(
                        image: controller.cachedShoeImage,
                        height: 180,
                        width: 180,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FeatureBadgesWidget(),
          const CategorySection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGULAR PROMOTION BANNER (No flash deal)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPromotionBanner() {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfea52d),
            const Color(0xFFfea52d).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            height: 185,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color.fromARGB(255, 243, 210, 154).withOpacity(0.50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Offers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Exclusive deals for you',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Up to 50% OFF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            try {
                              DashboardController.instance.reset();
                              final controller = Get.put(HomeController());
                              controller.searchProducts('a');
                              controller.setSelectedCategory(
                                ProductAttributeItems(),
                              );
                            } catch (e) {
                              debugPrint('Error selecting subcategory: $e');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SHOP NOW',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 255, 145, 0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: Image(
                        image: controller.cachedShoeImage,
                        height: 180,
                        width: 180,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FeatureBadgesWidget(),
          const TjaraVideosSection(),
          const CategorySection(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COUNTDOWN TIMER ROW - Isolated widget for efficient rebuilds
// ═══════════════════════════════════════════════════════════════════════════
class _CountdownTimerRow extends StatelessWidget {
  final ValueNotifier<int> remainingNotifier;
  final String Function(int) formatTime;

  const _CountdownTimerRow({
    required this.remainingNotifier,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: remainingNotifier,
      builder: (context, remainingSeconds, _) {
        final timeString = formatTime(remainingSeconds);
        final parts = timeString.split(':');

        return Row(
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              _buildTimeBox(parts[i]),
              if (i < parts.length - 1) _buildTimeSeparator(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF9B3D),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildTimeSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
