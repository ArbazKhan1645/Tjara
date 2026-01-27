import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/home/pages/homeview_body.dart';
import 'package:tjara/app/modules/home/screens/flash_deal_detail_screen.dart';
import 'package:tjara/app/modules/home/views/banner.dart';
import 'package:tjara/app/modules/home/views/deal_section.dart';
import 'package:tjara/app/modules/home/views/f.dart';
import 'package:tjara/app/modules/home/views/product.dart';
import 'package:tjara/app/modules/home/views/trust_badge.dart';
import 'package:tjara/app/modules/home/widgets/categories.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';

/// Optimized Parallax Home View with TabBar
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return IndexedStack(
          index: controller.selectedCategory != null ? 0 : 1,
          children: [
            controller.selectedCategory == null
                ? Container()
                : CategoryViewBody(
                  scrollController:
                      controller.categoryPaginationScrollController,
                ),
            DefaultTabController(
              length: 9,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.grey.shade100,
                body: _ParallaxTabView(controller: controller),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ParallaxTabView extends StatefulWidget {
  final HomeController controller;

  const _ParallaxTabView({required this.controller});

  @override
  State<_ParallaxTabView> createState() => _ParallaxTabViewState();
}

class _ParallaxTabViewState extends State<_ParallaxTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, ScrollController> _scrollControllers = {};

  // Efficient updates with ValueNotifier
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);
  final ValueNotifier<double> _headerOpacity = ValueNotifier(0.0);
  final ValueNotifier<bool> _isTrustBadgeSticky = ValueNotifier(false);

  static const double _collapseThreshold = 50.0;
  late double _trustBadgeStickyThreshold;

  bool _isHandlingTabChange = false;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);

    // First tab ka scroll controller
    _getOrCreateScrollController(0);

    _tabController.addListener(_onTabControllerChange);

    // Set callback for tab change from other screens (e.g., ProductDetailScreen)
    widget.controller.onTabChangeCallback = (int index) {
      if (mounted && index >= 0 && index == 5) {
        _tabController.animateTo(index);
        _handleTabChange(index);
      }
    };

    // Sticky threshold calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      const appBarHeight = 56.0;
      const tabBarHeight = 42.0;
      final topPadding = MediaQuery.of(context).padding.top;
      _trustBadgeStickyThreshold =
          350.0 - (appBarHeight + tabBarHeight + topPadding);
    });
  }

  @override
  void dispose() {
    // Clear tab change callback
    widget.controller.onTabChangeCallback = null;
    _scrollControllers.forEach((_, controller) => controller.dispose());
    _tabController.removeListener(_onTabControllerChange);
    _tabController.dispose();
    _scrollOffset.dispose();
    _headerOpacity.dispose();
    _isTrustBadgeSticky.dispose();
    super.dispose();
  }

  // Lazy load scroll controllers
  ScrollController _getOrCreateScrollController(int index) {
    return _scrollControllers.putIfAbsent(index, () {
      final controller = ScrollController();
      controller.addListener(() => _onScroll(index));
      return controller;
    });
  }

  void _onTabControllerChange() {
    if (_tabController.indexIsChanging && !_isHandlingTabChange) {
      _handleTabChange(_tabController.index);
    }
  }

  void _onScroll(int tabIndex) {
    // Sirf active tab ke liye update
    if (tabIndex != _currentTab) return;

    final controller = _scrollControllers[tabIndex];
    if (controller == null || !controller.hasClients) return;

    final offset = controller.offset;

    // Header opacity with throttle (performance ke liye)
    final newHeaderOpacity = (offset / _collapseThreshold).clamp(0.0, 1.0);
    if ((_headerOpacity.value - newHeaderOpacity).abs() > 0.02) {
      _headerOpacity.value = newHeaderOpacity;
    }

    // Trust badge sticky check
    final newIsTrustBadgeSticky = offset >= _trustBadgeStickyThreshold;
    if (_isTrustBadgeSticky.value != newIsTrustBadgeSticky) {
      _isTrustBadgeSticky.value = newIsTrustBadgeSticky;
    }

    _scrollOffset.value = offset;

    // ⭐ HOME CONTROLLER KE SCROLL CONTROLLER KO UPDATE KARNA
    _syncWithHomeController(controller);
  }

  /// ⭐ Home controller ki scroll position ko sync karna
  void _syncWithHomeController(ScrollController localController) {
    if (localController.position.pixels >=
        localController.position.maxScrollExtent - 0) {
      if (!widget.controller.isLoading) {
        widget.controller.fetchMoreProducts();
      }
    }
  }

  void _handleTabChange(int index) async {
    if (_isHandlingTabChange) return;
    _isHandlingTabChange = true;

    try {
      // Navigation tabs (Jobs, Services, Contests)
      if (index == 6) {
        await Get.toNamed('/tjara-jobs');
        if (mounted) _tabController.index = _currentTab;
        return;
      } else if (index == 7) {
        await Get.toNamed('/services');
        if (mounted) _tabController.index = _currentTab;
        return;
      } else if (index == 8) {
        await Get.toNamed('/contests');
        if (mounted) _tabController.index = _currentTab;
        return;
      } else if (index == 5) {
        await Get.to(() => const FlashDealDetailScreen());
        if (mounted) _tabController.index = _currentTab;
        return;
      } else {
        // Current tab update
        _currentTab = index;

        // Lazy load scroll controller
        _getOrCreateScrollController(index);

        // Next frame mein updates (blocking prevent karne ke liye)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // Controller state update
          widget.controller.setSelectedIndexProducts(index);

          if (index == 0) {
            // widget.controller.startFilteredLoading();
            // widget.controller.loadFilteredFirstPage(index);
            // widget.controller.update(['product_grid']);
          } else {
            widget.controller.startFilteredLoading();
            widget.controller.loadFilteredFirstPage(index);
          }

          // Scroll state reset/update
          final scrollController = _scrollControllers[index];
          if (scrollController != null && scrollController.hasClients) {
            _onScroll(index);
          } else {
            _scrollOffset.value = 0.0;
            _headerOpacity.value = 0.0;
            _isTrustBadgeSticky.value = false;
          }

          // ⭐ Home controller ke scroll controller ko bhi reset
          if (widget.controller.scrollController.hasClients) {
            widget.controller.scrollController.jumpTo(0);
          }
        });

        // Rebuild after state change
        if (mounted) setState(() {});
      }
    } finally {
      _isHandlingTabChange = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Main Content
        Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _isTrustBadgeSticky,
              builder: (context, isSticky, _) {
                return SizedBox(height: topPadding + (isSticky ? 98 : 80));
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  // Container(
                  //   height: MediaQuery.of(context).size.height / 1.5,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.topCenter,
                  //       end: Alignment.bottomCenter,
                  //       colors: [
                  //         Color(0xFFfea52d), // top
                  //         Color(0xFFfea52d).withOpacity(0.10), // top
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey.shade100,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(9, (index) {
                          return RepaintBoundary(
                            child: _buildTabContent(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Sticky Header (Optimized)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: ValueListenableBuilder<double>(
              valueListenable: _headerOpacity,
              builder: (context, opacity, _) {
                final headerColor = _getHeaderColor(opacity);

                return Container(
                  decoration: BoxDecoration(color: headerColor),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // AppBar
                        Container(
                          color: Colors.transparent,
                          height: 56,
                          child: ValueListenableBuilder<double>(
                            valueListenable: _scrollOffset,
                            builder: (context, offset, _) {
                              return CustomAppBar(
                                showWhitebackground: offset > 10,
                                showActions: true,
                              );
                            },
                          ),
                        ),

                        // TabBar
                        ValueListenableBuilder<bool>(
                          valueListenable: _isTrustBadgeSticky,
                          builder: (context, isSticky, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _scrollOffset,
                              builder: (context, offset, _) {
                                return Container(
                                  height: 42,
                                  color:
                                      offset > 10
                                          ? Colors.white
                                          : const Color(0xFFfda730),
                                  child: _CustomTabBar(
                                    controller: _tabController,
                                    black: offset > 10,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getHeaderColor(double opacity) {
    // if (_currentTab == 0) {
    //   return Color.lerp(const Color(0xFFfda730), Colors.white, opacity)!;
    // }
    return Color.lerp(const Color(0xFFfda730), Colors.white, opacity)!;
  }

  Widget _buildTabContent(int index) {
    final scrollController = _getOrCreateScrollController(index);

    if (index == 0) {
      return _buildAllTabContent(scrollController, index);
    } else {
      return _buildOtherTabContent(scrollController);
    }
  }

  var dashbaordController = Get.find<DashboardController>();

  Widget _buildAllTabContent(ScrollController scrollController, int index) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const PromotionBannerWidget(
            key: Key('Banner_image_optimized_section_home_}'),
          ),

          // FeatureBadgesWidget(),
          // CategorySection(),
          Obx(() {
            if (dashbaordController.selectedIndex.value != 0) {
              return const SizedBox.shrink();
            }
            if (widget.controller.selectedCategory != null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DealSectionsWidget(
                  onViewAllTap: () {
                    Get.to(() => const FlashDealDetailScreen());
                    // _tabController.animateTo(5);
                  },
                ),
                const SizedBox(height: 10),
                AuctionProductsWidget(
                  key: ValueKey(_tabController.index == 0 ? '0' : '1'),
                  onViewAllTap: () {
                    _tabController.animateTo(4);
                  },
                ),

                const SizedBox(height: 15),
                // InfoBarWidget(),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 0, bottom: 12),
                  child: Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const ProductsGridWidget(shownfromcatehoris: false),
                const SizedBox(height: 80),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOtherTabContent(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFfea52d), // top
                  const Color(0xFFfea52d).withOpacity(0.05), // top
                ],
              ),
            ),
            child: Column(
              children: [
                const TrustBadgesWidget(),
                CategorySection(isCarSection: _currentTab == 3),
                if (_currentTab == 5 &&
                    widget
                            .controller
                            .superdealAvailable
                            .value
                            .currentDealProductId ==
                        null) ...[
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'عروض اليوم خلصت. ✨ عروض جديدة رح تنضاف قريبًا\n',
                          style: TextStyle(
                            color: Color(0xFFfea52d), // 🔴 Red line
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              '!شوف العروض التانية لتحت وكمان العروض يلي خلصت👇',
                          style: TextStyle(
                            color: Colors.teal, // 🟢 Green line
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),

          const ProductsGridWidget(shownfromcatehoris: false),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Custom TabBar - Optimized
class _CustomTabBar extends StatefulWidget {
  final TabController controller;
  final bool black;

  const _CustomTabBar({required this.controller, required this.black});

  @override
  State<_CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<_CustomTabBar> {
  late ScrollController _scrollController;
  final List<GlobalKey> _tabKeys = List.generate(9, (_) => GlobalKey());
  int _lastSelectedIndex = 0;
  bool _isScrolling = false;

  static const _tabs = [
    'All',
    'On Sale',
    'Featured',
    'Cars',
    'Auctions',
    'Flash Deals',
    'Jobs',
    'Services',
    'Contests',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.controller.addListener(_onTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_lastSelectedIndex != widget.controller.index) {
      _lastSelectedIndex = widget.controller.index;
      _scrollToSelectedTab();
    }
  }

  void _scrollToSelectedTab() {
    if (_isScrolling || !mounted || !_scrollController.hasClients) return;

    _isScrolling = true;
    final selectedIndex = widget.controller.index;
    final selectedKey = _tabKeys[selectedIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || selectedKey.currentContext == null) {
        _isScrolling = false;
        return;
      }

      final RenderBox? renderBox =
          selectedKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        _isScrolling = false;
        return;
      }

      final tabPosition = renderBox.localToGlobal(Offset.zero);
      final targetScroll = _scrollController.offset + tabPosition.dx - 16;

      _scrollController
          .animateTo(
            targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          )
          .then((_) => _isScrolling = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: _tabs.length,
      separatorBuilder: (_, __) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        return RepaintBoundary(child: _buildTab(index));
      },
    );
  }

  Widget _buildTab(int index) {
    return GestureDetector(
      key: _tabKeys[index],
      onTap: () => widget.controller.animateTo(index),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final isSelected = widget.controller.index == index;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 0,
              right: index == _tabs.length - 1 ? 16 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 120),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        widget.black
                            ? (isSelected ? Colors.black : Colors.grey)
                            : isSelected
                            ? Colors.white
                            : Colors.white70,
                    height: 1.2,
                  ),
                  child: Text(_tabs[index]),
                ),
                const SizedBox(height: 8),
                // Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  height: 3,
                  width:
                      isSelected ? _getTextWidth(_tabs[index], isSelected) : 0,
                  decoration: BoxDecoration(
                    color:
                        widget.black
                            ? (isSelected ? Colors.black : Colors.grey)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Text width cache for performance
  static final Map<String, double> _textWidthCache = {};

  double _getTextWidth(String text, bool isSelected) {
    final key = '$text-$isSelected';
    return _textWidthCache.putIfAbsent(key, () {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.width;
    });
  }
}

/// Compact Trust Badge
class _CompactTrustBadge extends StatelessWidget {
  const _CompactTrustBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xfffeeedf),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done, color: Color(0xff0a8700), size: 16),
          SizedBox(width: 6),
          Text(
            'Free shipping for you',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Text(
            'Limited-time offer',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward_ios, color: Color(0xff0a8700), size: 10),
        ],
      ),
    );
  }
}

/// Info Bar Widget
class InfoBarWidget extends StatelessWidget {
  const InfoBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(color: Color(0xff0a8700)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'تجارة لبنانية',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(' | ', style: TextStyle(color: Colors.white)),
          Text(
            'تدعم الأفراد عبر برنامج الموزعين',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
