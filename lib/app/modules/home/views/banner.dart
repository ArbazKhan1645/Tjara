import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/views/featurebaegs.dart';
import 'package:tjara/app/modules/home/widgets/categories.dart';
import 'package:tjara/app/modules/home/widgets/product_detail.dart';

/// Flash Deals Banner with countdown timer
class PromotionBannerWidget extends StatefulWidget {
  const PromotionBannerWidget({super.key});

  @override
  State<PromotionBannerWidget> createState() => _PromotionBannerWidgetState();
}

class _PromotionBannerWidgetState extends State<PromotionBannerWidget>
    with AutomaticKeepAliveClientMixin {
  DateTime? _endTime;
  DateTime? _startTime;
  Timer? _timer;
  bool _isInitialized = false;

  // ✅ ValueNotifier sirf timer values ke liye - isolated rebuild
  final ValueNotifier<Duration> _remainingNotifier = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<bool> _isExpiredNotifier = ValueNotifier(true);

  void _initializeTimerOnce(HomeController controller) {
    if (_isInitialized) return;

    final dealEndTime = controller.superdealAvailable.value.currentDealEndTime;
    if (dealEndTime == null || dealEndTime.isEmpty) return;

    _isInitialized = true;
    _endTime = _parseTime(dealEndTime);
    _startTime = _parseTime(
      controller.superdealAvailable.value.currentDealStartTime.toString(),
    );

    if (_endTime != null) {
      _updateRemainingTime();

      if (_remainingNotifier.value > Duration.zero) {
        _isExpiredNotifier.value = false;
        _startCountdownTimer();
      } else {
        _isExpiredNotifier.value = true;
      }
    }
  }

  DateTime? _parseTime(String dateString) {
    try {
      DateTime parsedDate;
      if (dateString.contains(' ')) {
        final normalized = dateString.replaceFirst(' ', 'T');
        parsedDate = DateTime.parse(normalized);
      } else {
        parsedDate = DateTime.parse(dateString);
      }
      return parsedDate;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  void _updateRemainingTime() {
    if (_endTime == null) {
      _remainingNotifier.value = Duration.zero;
      _isExpiredNotifier.value = true;
      return;
    }

    final endTimeLocal = _endTime!.toLocal();
    final nowUtc = DateTime.now().toUtc();

    final offset = DateTime.now().timeZoneOffset;

    // Adjust difference by adding offset to align timezones
    final difference = endTimeLocal.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingNotifier.value = Duration.zero;
      _isExpiredNotifier.value = true;
      _timer?.cancel();
    } else {
      _remainingNotifier.value = difference;
      _isExpiredNotifier.value = false;
    }
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateRemainingTime(); // ✅ No setState - sirf ValueNotifier update
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingNotifier.dispose();
    _isExpiredNotifier.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final controller = Get.find<HomeController>();
      _initializeTimerOnce(controller);

      // ✅ ValueListenableBuilder sirf expiry check ke liye
      return ValueListenableBuilder<bool>(
        valueListenable: _isExpiredNotifier,
        builder: (context, isExpired, _) {
          final hasActiveDeal = controller.shouldShowFlashDeals && !isExpired;

          if (hasActiveDeal) {
            return _buildFlashDealsBanner();
          }
          return _buildPromotionBanner();
        },
      );
    });
  }

  Widget _buildFlashDealsBanner() {
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFfea52d), const Color(0xFFfea52d).withOpacity(0.05)],
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
                        const Text(
                          'Flash Deals',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
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

                        // ✅ Sirf yeh portion rebuild hoga har second
                        _CountdownTimerRow(
                          remainingNotifier: _remainingNotifier,
                        ),

                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            final ProductDatum? pro =
                                controller.dealsproducts.value.products?.data
                                    ?.where(
                                      (e) =>
                                          e.id ==
                                          controller
                                              .superdealAvailable
                                              .value
                                              .currentDealProductId,
                                    )
                                    .firstOrNull;
                            if (pro != null) {
                              Get.to(
                                () => ProductDetailScreen(
                                  product: pro,
                                  activeFlashDealProductId: pro.id ?? '',
                                ),
                                preventDuplicates: false,
                              );
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

  Widget _buildPromotionBanner() {
    // ... same as before (no changes needed)
    final controller = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFfea52d), const Color(0xFFfea52d).withOpacity(0.05)],
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
                            controller.setSelectedCategory(
                              ProductAttributeItems(),
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
}

// ✅ Separate StatelessWidget - sirf yeh rebuild hoga
class _CountdownTimerRow extends StatelessWidget {
  final ValueNotifier<Duration> remainingNotifier;

  const _CountdownTimerRow({required this.remainingNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: remainingNotifier,
      builder: (context, remaining, _) {
        final hours = _pad(remaining.inHours);
        final minutes = _pad(remaining.inMinutes % 60);
        final seconds = _pad(remaining.inSeconds % 60);

        return Row(
          children: [
            _buildTimeBox(hours),
            _buildTimeSeparator(),
            _buildTimeBox(minutes),
            _buildTimeSeparator(),
            _buildTimeBox(seconds),
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

  String _pad(int v) => v.toString().padLeft(2, '0');
}
