import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/models/banners_model.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/widgets/categories_new.dart';
import 'package:tjara/app/modules/home/widgets/categories_products.dart';
import 'package:tjara/app/modules/home/widgets/super_deals.dart';
import 'package:tjara/app/core/widgets/base.dart';
import 'package:tjara/app/modules/home/widgets/notice_promotion.dart';
import 'package:tjara/app/modules/home/widgets/prodnavbar.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return CommonBaseBodyScreen(
      scrollController: scrollController,
      screens: [
        const _SaleSection(),
        const SafePaymentButton(),
        // CategorySection(),
        const SuperDealsWidget(),
        const ProductNavBar(),
        const ProductGrid(),
        const SizedBox(height: 100),
      ],
    );
  }
}

class CategoryViewBody extends StatelessWidget {
  const CategoryViewBody({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color(0xFFfda730),
            ),
            const CustomAppBar(showWhitebackground: false, showActions: false),
            const CategorySectionNew(),
            const CategoriesProductGrid(),
          ],
        ),
      ),
    );
  }
}

class _SaleSection extends StatefulWidget {
  const _SaleSection();

  @override
  State<_SaleSection> createState() => _SaleSectionState();
}

class _SaleSectionState extends State<_SaleSection> {
  DateTime? _endTime;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  final PageController _bannerPageController = PageController();
  Timer? _bannerAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    _updateEndTime();
    _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerAutoScrollTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _updateEndTime() {
    final controller = Get.find<HomeController>();
    final superDeals = controller.superDeals.value;

    if (superDeals.currentDealEndTime != null &&
        superDeals.currentDealEndTime!.isNotEmpty) {
      try {
        // Parse the date string (format: "2025-11-19 19:50:24" or ISO format)
        final dateString = superDeals.currentDealEndTime!;
        DateTime? parsedDate;

        try {
          // Try parsing with space separator first (format: "2025-11-19 19:50:24")
          if (dateString.contains(' ')) {
            // Replace space with 'T' to make it ISO-like, or parse directly
            final normalized = dateString.replaceFirst(' ', 'T');
            parsedDate = DateTime.parse(normalized);
          } else {
            // Try ISO format directly
            parsedDate = DateTime.parse(dateString);
          }
        } catch (e) {
          // If parsing fails, try alternative format
          try {
            // Try with space format directly
            final parts = dateString.split(' ');
            if (parts.length == 2) {
              final datePart = parts[0];
              final timePart = parts[1];
              parsedDate = DateTime.parse('$datePart $timePart');
            }
          } catch (e2) {
            debugPrint('⚠️ Failed to parse date: $dateString - $e2');
          }
        }

        if (parsedDate != null) {
          DateTime localizedDate;
          if (parsedDate.isUtc) {
            localizedDate = parsedDate.toLocal();
          } else {
            localizedDate =
                DateTime.utc(
                  parsedDate.year,
                  parsedDate.month,
                  parsedDate.day,
                  parsedDate.hour,
                  parsedDate.minute,
                  parsedDate.second,
                  parsedDate.millisecond,
                  parsedDate.microsecond,
                ).toLocal();
          }

          _endTime = localizedDate;
          final now = DateTime.now();
          _remaining =
              _endTime!.isAfter(now)
                  ? _endTime!.difference(now)
                  : Duration.zero;
        }
      } catch (e) {
        debugPrint('⚠️ Error parsing deal end time: $e');
        _endTime = null;
        _remaining = Duration.zero;
      }
    } else {
      _endTime = null;
      _remaining = Duration.zero;
    }
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Update end time from controller in case it changed
      _updateEndTime();

      if (_endTime != null) {
        final now = DateTime.now();
        setState(() {
          _remaining =
              _endTime!.isAfter(now)
                  ? _endTime!.difference(now)
                  : Duration.zero;
        });

        if (_remaining <= Duration.zero) {
          timer.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      // Update end time when superDeals changes
      _updateEndTime();

      // Check if timer has reached 00:00:00
      final isTimerExpired = _remaining <= Duration.zero;

      // If timer expired, fetch and show banners
      if (isTimerExpired) {
        // Fetch banners if not already loading/loaded
        if (!controller.isLoadingBanners.value &&
            (controller.homePageBanners.value.posts?.data == null ||
                controller.homePageBanners.value.posts!.data!.isEmpty)) {
          controller.fetchHomePageBanners();
        }

        // Show banners if available
        final banners = controller.homePageBanners.value.posts?.data ?? [];
        if (banners.isNotEmpty) {
          return _buildBannersCarousel(banners);
        }

        // Show loading state while fetching banners
        if (controller.isLoadingBanners.value) {
          return _buildLoadingBanners();
        }

        // If no banners and not loading, hide section
        return const SizedBox.shrink();
      }

      // Only show countdown if there's an active deal
      if (!controller.shouldShowFlashDeals || _endTime == null) {
        return const SizedBox.shrink();
      }

      final hours = _pad(_remaining.inHours);
      final minutes = _pad(_remaining.inMinutes % 60);
      final seconds = _pad(_remaining.inSeconds % 60);

      final size = MediaQuery.of(context).size;
      final isSmall = size.width < 360;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 245, 153, 24),
                Color.fromARGB(255, 243, 195, 105),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              // Text & countdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Biggest Sales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 22 : 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ends In:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _timeBox(hours, isSmall),
                        _colon(),
                        _timeBox(minutes, isSmall),
                        _colon(),
                        _timeBox(seconds, isSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final controller = Get.put(HomeController());
                          controller.searchSuperDealsProducts();
                          controller.setSelectedCategory(
                            ProductAttributeItems(),
                          );
                        },
                        child: const Text(
                          'SHOP NOW',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right-side image
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 8),
                child: Image.asset(
                  'assets/images/Frame.png',
                  height: 150,
                  width: 100,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  Widget _timeBox(String value, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 14,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: const Color(0xFFF97316),
          fontSize: isSmall ? 16 : 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _colon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBannersCarousel(List<dynamic> banners) {
    // Start auto-scroll if not already started
    if (_bannerAutoScrollTimer == null || !_bannerAutoScrollTimer!.isActive) {
      _bannerAutoScrollTimer?.cancel();
      _bannerAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (
        timer,
      ) {
        if (_bannerPageController.hasClients && banners.length > 1) {
          final currentPage = _bannerPageController.page?.round() ?? 0;
          final nextPage = (currentPage + 1) % banners.length;
          _bannerPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _bannerPageController,
          itemCount: banners.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final banner = banners[index] as Datum;
            final imageUrl =
                banner.thumbnail?.media?.url ??
                banner.thumbnail?.media?.optimizedMediaUrl ??
                '';
            final mobileImageUrl =
                banner.mobileThumbnail?.media?.url ??
                banner.mobileThumbnail?.media?.optimizedMediaUrl ??
                imageUrl;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                          mobileImageUrl.isNotEmpty ? mobileImageUrl : imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingBanners() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey[100],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFF97316)),
        ),
      ),
    );
  }
}
