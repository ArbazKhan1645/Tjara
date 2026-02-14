// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/dialogs/payment_security.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/media_model/media_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart'
    hide Thumbnail;
import 'package:tjara/app/models/wishlists/wishlist_model.dart';
import 'package:tjara/app/modules/authentication_module/screens/contact_us.dart';
import 'package:tjara/app/modules/authentication_module/screens/login.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/deal_section.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/attributes.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/bids.dart';
import 'package:tjara/app/modules/modules_customer/app_home/service/customer_service.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/image_slider.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/quantity.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/products/single_product_model.dart'
    hide ShopShop;
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:tjara/app/models/superdeals_temp_model.dart' as superdeals;
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/flash_deal_checkout_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

// Top-level function required for compute() - cannot be inside a class
Map<String, dynamic> _decodeJsonMap(String source) {
  return json.decode(source) as Map<String, dynamic>;
}

class FlashDealDetailScreen extends StatefulWidget {
  const FlashDealDetailScreen({super.key});

  @override
  State<FlashDealDetailScreen> createState() => _FlashDealDetailScreenState();
}

class _FlashDealDetailScreenState extends State<FlashDealDetailScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Theme Colors
  static const Color _primaryColor = Colors.teal;
  static const Color _successColor = Colors.teal;
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _dividerColor = Color(0xFFF0F0F0);
  static const Color _bgColor = Color(0xFFF5F5F5);

  // API URL
  static final String _flashDealApiUrl =
      'https://api.libanbuy.com/api/products/flash-deals?with=gallery,attribute_items,rating,video,meta&fetchNewDeals=true&_t=${DateTime.now().microsecondsSinceEpoch}';

  // Controllers
  PageController? _pageController;
  TextEditingController? _quantityController;
  ScrollController? _scrollController;

  HomeController get _homeController => Get.find<HomeController>();
  WishlistServiceController get _wishlistController =>
      Get.find<WishlistServiceController>();

  // State Variables
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  bool _isDisposed = false;
  bool _isLoadingFlashDeal = false;

  // Deal State
  String _dealStatus = 'loading';
  superdeals.SuperDeals? _flashDealData;
  ProductDatum? _currentProduct;
  SingleModelClass? _fullProductDetails;
  String? _errorMessage;
  int? _httpStatusCode;

  // Countdown using ValueNotifier for optimization
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _showConfetti = ValueNotifier(false);
  bool _hasShownConfetti = false;
  String? _previousProductId;
  String? _previousDealStatus;
  DateTime? _scheduledStartTime;

  // UI State
  final ValueNotifier<List<String>> _imageUrlsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _showAppBarTitle = ValueNotifier(false);
  final ValueNotifier<int> _currentImageIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isCartOperationInProgressNotifier = ValueNotifier(
    false,
  );

  String? selectedVariationPrice;
  String? selectedVariationId;
  int? _selectedVariationStock;
  String? _videoUrl;
  String? _imageSliderKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();

    _scrollController =
        ScrollController()..addListener(() {
          final shouldShow = _scrollController!.offset > 250;
          if (_showAppBarTitle.value != shouldShow) {
            _showAppBarTitle.value = shouldShow;
          }
        });

    _startPolling();
  }

  void _initializeControllers() {
    _pageController =
        PageController()..addListener(() {
          final newIndex = _pageController!.page?.round() ?? 0;
          if (_currentImageIndex.value != newIndex) {
            _currentImageIndex.value = newIndex;
          }
        });
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pageController?.dispose();
    _quantityController?.dispose();
    _scrollController?.dispose();
    _imageUrlsNotifier.dispose();
    _showAppBarTitle.dispose();
    _currentImageIndex.dispose();
    _isCartOperationInProgressNotifier.dispose();
    _remainingSecondsNotifier.dispose();
    _showConfetti.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchFlashDealData();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLLING & API LOGIC
  // ═══════════════════════════════════════════════════════════════════════════
  void _startPolling() {
    _fetchFlashDealData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isDisposed) {
        _fetchFlashDealData();
      }
    });
  }

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
          .timeout(const Duration(seconds: 15));

      if (!_isDisposed) {
        if (response.statusCode == 200) {
          final data = await compute(_decodeJsonMap, response.body);
          final newFlashDeal = superdeals.SuperDeals.fromMap(data);
          _handleStateChange(newFlashDeal);
        } else {
          // Handle non-200 status
          _handleNon200Status(response.statusCode);
        }
      }
    } catch (e) {
      debugPrint('Flash deal fetch error: $e');
      if (!_isDisposed && _dealStatus == 'loading') {
        setState(() {
          _dealStatus = 'error';
          _errorMessage = 'Failed to load flash deals: $e';
          _httpStatusCode = null;
        });
      }
    } finally {
      _isLoadingFlashDeal = false;
    }
  }

  void _handleNon200Status(int statusCode) {
    if (_httpStatusCode != statusCode) {
      setState(() {
        _dealStatus = 'non_200_error';
        _httpStatusCode = statusCode;
        _errorMessage = 'Server returned status code: $statusCode';
      });
    }
  }

  void _handleStateChange(superdeals.SuperDeals data) {
    if (_isDisposed) return;

    final newStatus = data.dealStatus ?? '';
    final newProductId =
        data.currentDealProductId ?? data.intervalInfo?.nextDealProductId;

    // Check if data actually changed
    bool dataChanged = false;
    bool shouldTriggerConfetti = false;

    // Check if status changed
    if (newStatus != _previousDealStatus) {
      dataChanged = true;

      // Trigger confetti when transitioning TO active state (from interval, scheduled, etc.)
      if (newStatus == 'active' && _previousDealStatus != 'active') {
        _hasShownConfetti = false; // Reset for new active deal
        shouldTriggerConfetti = true;
      }
    }

    // Check if product changed
    if (newProductId != _previousProductId) {
      dataChanged = true;

      // Trigger confetti when a NEW product becomes active
      // This covers: interval ended -> new product is now active
      if (newStatus == 'active') {
        // Trigger if coming from interval OR if product actually changed (not first load)
        if (_previousDealStatus == 'interval' || _previousProductId != null) {
          _hasShownConfetti = false; // Reset for new product
          shouldTriggerConfetti = true;
        }
      }
    }

    // Trigger confetti once after all checks (prevents double animation)
    if (shouldTriggerConfetti && !_hasShownConfetti) {
      _triggerConfetti();
    }

    // Update tracking variables
    _previousDealStatus = newStatus;
    _previousProductId = newProductId;

    // Parse scheduled start time if available
    DateTime? newScheduledTime;
    if (data.dealScheduleTime != null) {
      try {
        newScheduledTime = DateTime.parse(data.dealScheduleTime!);
      } catch (e) {
        debugPrint('Error parsing scheduled time: $e');
      }
    }

    if (newScheduledTime != _scheduledStartTime) {
      dataChanged = true;
      _scheduledStartTime = newScheduledTime;
    }

    // Only setState if data changed
    if (dataChanged || _dealStatus != newStatus) {
      setState(() {
        _flashDealData = data;
        _dealStatus = newStatus.isEmpty ? 'error' : newStatus;
        _errorMessage = null;
        _httpStatusCode = null;
      });
    } else {
      // Update data without setState
      _flashDealData = data;
    }

    // Handle product data
    if (data.product != null) {
      final newProduct = _convertToProductDatum(data.product!);

      // Check if product actually changed
      if (_currentProduct?.id != newProduct.id ||
          _currentProduct?.name != newProduct.name ||
          _currentProduct?.price != newProduct.price ||
          _currentProduct?.salePrice != newProduct.salePrice ||
          _currentProduct?.stock != newProduct.stock) {
        _currentProduct = newProduct;
        _updateImageUrls(data.product!);
        _fetchFullProductDetails(_currentProduct!.id!);

        // Generate new key for image slider when product changes
        _imageSliderKey =
            'flash_deal_${newProduct.id}_${DateTime.now().millisecondsSinceEpoch}';
      }
    } else if (_currentProduct != null) {
      // Product was removed
      setState(() {
        _currentProduct = null;
        _fullProductDetails = null;
        _imageUrlsNotifier.value = [];
        _videoUrl = null;
      });
    }

    // Start local countdown
    final newSecondsRemaining = _getSecondsRemaining(data);
    if (_remainingSecondsNotifier.value != newSecondsRemaining) {
      _startCountdown(newSecondsRemaining);
    }
  }

  int _getSecondsRemaining(superdeals.SuperDeals data) {
    if (data.dealStatus == 'active') {
      return data.sequenceInfo?.secondsRemaining ?? 0;
    } else if (data.dealStatus == 'interval') {
      return data.intervalInfo?.secondsRemaining ?? 0;
    } else if (data.dealStatus == 'scheduled' && _scheduledStartTime != null) {
      final now = DateTime.now();
      final difference = _scheduledStartTime!.difference(now);
      return difference.inSeconds > 0 ? difference.inSeconds : 0;
    }
    return 0;
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.value = seconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) {
        _countdownTimer?.cancel();
        return;
      }

      if (_remainingSecondsNotifier.value > 0) {
        _remainingSecondsNotifier.value--;
      } else {
        _countdownTimer?.cancel();
        _fetchFlashDealData();
      }
    });
  }

  void _triggerConfetti() {
    if (_hasShownConfetti) return;
    _hasShownConfetti = true;

    _showConfetti.value = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isDisposed) {
        _showConfetti.value = false;
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
  // PRODUCT CONVERSION
  // ═══════════════════════════════════════════════════════════════════════════
  ProductDatum _convertToProductDatum(superdeals.Product product) {
    DatumMeta? meta;
    if (product.meta != null && product.meta!.isNotEmpty) {
      String? shippingTimeFrom;
      String? shippingTimeTo;
      String? shippingCompany;
      String? shippingFees;
      String? shippingMethod;
      String? shippingTimeUnit;

      for (var m in product.meta!) {
        switch (m.key) {
          case 'shipping_time_from':
            shippingTimeFrom = m.value;
            break;
          case 'shipping_time_to':
            shippingTimeTo = m.value;
            break;
          case 'shipping_company':
            shippingCompany = m.value;
            break;
          case 'shipping_fees':
            shippingFees = m.value;
            break;
          case 'shipping_method':
            shippingMethod = m.value;
            break;
          case 'shipping_time_unit':
            shippingTimeUnit = m.value;
            break;
        }
      }

      meta = DatumMeta(
        shipping_time_from: shippingTimeFrom,
        shipping_time_to: shippingTimeTo,
        shipping_company: shippingCompany,
        shipping_fees: shippingFees,
        shipping_method: shippingMethod,
        shipping_time_unit: shippingTimeUnit,
      );
    }

    Thumbnail? thumbnail;
    if (product.thumbnail?.media != null) {
      thumbnail = Thumbnail(
        media: MediaUniversalModel(
          id: product.thumbnail!.media!.id,
          url: product.thumbnail!.media!.url,
          optimizedMediaUrl: product.thumbnail!.media!.optimizedMediaUrl,
          cdnUrl: product.thumbnail!.media!.cdnUrl,
          optimizedMediaCdnUrl: product.thumbnail!.media!.optimizedMediaCdnUrl,
          cdnThumbnailUrl: product.thumbnail!.media!.cdnThumbnailUrl,
        ),
      );
    }

    DatumShop? shop;
    if (product.shop != null) {
      shop = DatumShop(
        shop: ShopShop(
          id: product.shop!.id,
          name: product.shop!.name,
          slug: product.shop!.slug,
          description: product.shop!.description,
          isVerified: product.shop!.isVerified,
          isFeatured: product.shop!.isFeatured,
          status: product.shop!.status,
        ),
      );
    }

    return ProductDatum(
      id: product.id,
      shopId: product.shopId,
      slug: product.slug,
      name: product.name,
      productType: product.productType,
      productGroup: product.productGroup,
      description: product.description,
      stock: product.stock?.toDouble(),
      isFeatured: product.isFeatured,
      isDeal: product.isDeal,
      price: product.price?.toDouble(),
      salePrice: product.salePrice?.toDouble(),
      status: product.status,
      thumbnail: thumbnail,
      shop: shop,
      meta: meta,
      auctionStartTime: product.auctionStartTime?.toString(),
      auctionEndTime: product.auctionEndTime?.toString(),
      saleStartTime: product.saleStartTime?.toString(),
      saleEndTime: product.saleEndTime?.toString(),
    );
  }

  void _updateImageUrls(superdeals.Product product) {
    final newUrls = <String>[];

    final videoUrlRaw =
        product.video is Map
            ? (product.video['media']?['url']?.toString().trim() ??
                product.video['media']?['optimized_media_url']
                    ?.toString()
                    .trim())
            : null;
    final newVideoUrl = (videoUrlRaw?.isNotEmpty == true) ? videoUrlRaw : null;

    // Only update if video URL changed
    if (_videoUrl != newVideoUrl) {
      _videoUrl = newVideoUrl;
    }

    // Always add thumbnail if available (even when video exists)
    if (product.thumbnail?.media != null) {
      final thumbUrl =
          product.thumbnail!.media!.cdnThumbnailUrl ??
          product.thumbnail!.media!.optimizedMediaCdnUrl ??
          product.thumbnail!.media!.cdnUrl ??
          product.thumbnail!.media!.url ??
          product.thumbnail!.media!.optimizedMediaUrl ??
          '';
      if (thumbUrl.isNotEmpty) {
        newUrls.add(thumbUrl);
      }
    }

    // Only update if URLs changed
    if (_imageUrlsNotifier.value.toString() != newUrls.toString()) {
      _imageUrlsNotifier.value = newUrls;
    }
  }

  Future<void> _fetchFullProductDetails(String productId) async {
    if (_isDisposed) return;
    try {
      final freshProduct = await _homeController.fetchSingleProducts(productId);
      if (!_isDisposed && freshProduct != null) {
        // Only update if product details actually changed
        if (_fullProductDetails?.product?.id != freshProduct.product?.id) {
          setState(() {
            _fullProductDetails = freshProduct;
          });
          _updateImageUrlsFromFullProduct(freshProduct);
        }
      }
    } catch (e) {
      debugPrint('Error fetching full product details: $e');
    }
  }

  void _updateImageUrlsFromFullProduct(SingleModelClass product) {
    if (product.product?.gallery == null) return;
    final gallery = product.product!.gallery;
    final newUrls = <String>[];

    final videoUrlRaw =
        product.product?.video?.media?.url?.toString().trim() ??
        product.product?.video?.media?.optimizedMediaUrl?.toString().trim() ??
        product.product?.video?.media?.cdnThumbnailUrl ??
        product.product?.video?.media?.optimizedMediaCdnUrl ??
        product.product?.video?.media?.cdnUrl ??
        product.product?.video?.media?.localUrl;

    final newVideoUrl = (videoUrlRaw?.isNotEmpty == true) ? videoUrlRaw : null;

    if (_videoUrl != newVideoUrl) {
      _videoUrl = newVideoUrl;
    }

    // Always add the first image (thumbnail) if available (even when video exists)
    if (_imageUrlsNotifier.value.isNotEmpty) {
      newUrls.add(_imageUrlsNotifier.value.first);
    }

    // Add gallery images
    for (var item in gallery) {
      if (item.media?.url != null || item.media?.optimizedMediaUrl != null) {
        final url =
            item.media!.url?.toString().trim() ??
            item.media!.optimizedMediaUrl?.toString().trim() ??
            item.media?.cdnThumbnailUrl ??
            item.media?.optimizedMediaCdnUrl ??
            item.media?.cdnUrl ??
            item.media?.localUrl ??
            '';
        if (url.isNotEmpty && !newUrls.contains(url)) {
          newUrls.add(url);
        }
      }
    }

    // Add all variation thumbnails
    final variations = product.product?.variation?.shop;
    if (variations != null) {
      for (var variation in variations) {
        final variationThumbUrl = variation.thumbnailUrl;
        if (variationThumbUrl != null &&
            variationThumbUrl.isNotEmpty &&
            !newUrls.contains(variationThumbUrl)) {
          newUrls.add(variationThumbUrl);
        }
      }
    }

    if (newUrls.isNotEmpty &&
        _imageUrlsNotifier.value.toString() != newUrls.toString()) {
      _imageUrlsNotifier.value = newUrls;
    }
  }

  /// Scrolls the image slider to show the variation thumbnail
  void _updateImageSliderWithVariationThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.isEmpty) return;

    final currentUrls = _imageUrlsNotifier.value;

    // Find the index of the thumbnail in the list
    int targetIndex = currentUrls.indexOf(thumbnailUrl);

    // If video exists, account for video being at index 0
    if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      targetIndex = targetIndex + 1; // Shift by 1 because video is at index 0
    }

    if (targetIndex >= 0) {
      // Scroll to the variation thumbnail
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController != null && _pageController!.hasClients && mounted) {
          _pageController!.animateToPage(
            targetIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _toggleWishlist(WishlistItem? wishlistItem) async {
    if (_currentProduct == null) return;

    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    if (wishlistItem != null) {
      await _wishlistController.removeFromWishlist(
        wishlistItem.id.toString(),
        context,
      );
    } else {
      await _wishlistController.addToWishlist(
        _currentProduct!.id.toString(),
        context,
      );
    }

    try {
      (Get.isRegistered<DashboardController>()
              ? Get.find<DashboardController>()
              : Get.put(DashboardController()))
          .fetchWishlistCount();
    } catch (_) {}
  }

  void _showLoginDialog() {
    showContactDialog(context, const LoginUi());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(backgroundColor: _bgColor, body: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_dealStatus) {
      case 'loading':
        return _buildLoadingUI();
      case 'active':
        return _buildActiveUI();
      case 'interval':
        return _buildIntervalUI();
      case 'scheduled':
        return _buildScheduledUI();
      case 'sequence_completed':
        return _buildSequenceCompletedUI();
      case 'non_200_error':
        return _buildNon200ErrorUI();
      case 'error':
        return _buildErrorUI();
      default:
        return _buildErrorUI();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING UI - Shimmer Skeleton
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLoadingUI() {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Skeleton
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),

              // Product Info Skeleton
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flash Deal Banner Skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Row(
                        children: [
                          Container(
                            height: 28,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 18,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title Skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 18,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 18,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating & Stock Skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 14,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Skeleton
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 14,
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Delivery Card Skeleton
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Column(
                    children: [
                      _buildShimmerInfoRow(),
                      const SizedBox(height: 16),
                      _buildShimmerInfoRow(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Quantity Skeleton
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 36,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Security Card Skeleton
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 16,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Container(
                              height: 14,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Store Card Skeleton
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 14,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
        _buildFloatingAppBar(),
        // Bottom Bar Skeleton
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Spacer(),
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NON-200 ERROR UI (ARABIC MESSAGE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildNon200ErrorUI() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'عروض اليوم خلصت. ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'عروض جديدة رح تنضاف قريبًا!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: _textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شوف العروض التانية لتحت وكمان العروض يلي خلصت 👇',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: _textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const DealSectionsWidget(isEndedDeals: true),
            ],
          ),
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR UI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildErrorUI() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: _textSecondary),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    setState(() => _dealStatus = 'loading');
                    _fetchFlashDealData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULED UI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildScheduledUI() {
    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule,
                      size: 50,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Flash Deal Starting Soon',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<int>(
                    valueListenable: _remainingSecondsNotifier,
                    builder: (context, remainingSeconds, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatTime(remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Get Ready',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentProduct != null) _buildProductPreviewCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Be ready when the timer hits zero!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERVAL UI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildIntervalUI() {
    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer,
                      size: 50,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Next Flash Deal Starts In',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<int>(
                    valueListenable: _remainingSecondsNotifier,
                    builder: (context, remainingSeconds, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatTime(remainingSeconds),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Coming Up Next',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentProduct != null) _buildProductPreviewCard(),
                  const SizedBox(height: 24),
                  if (_flashDealData?.dealPosition != null)
                    Text(
                      'Deal ${_flashDealData!.dealPosition!.current} of ${_flashDealData!.dealPosition!.total}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  Widget _buildProductPreviewCard() {
    final thumbnailUrl =
        _currentProduct?.thumbnail?.media?.optimizedMediaUrl ??
        _currentProduct?.thumbnail?.media?.optimizedMediaUrl ??
        _currentProduct?.thumbnail?.media!.url?.toString().trim() ??
        _currentProduct?.thumbnail?.media!.optimizedMediaUrl
            ?.toString()
            .trim() ??
        _currentProduct?.thumbnail?.media?.cdnThumbnailUrl ??
        _currentProduct?.thumbnail?.media?.optimizedMediaCdnUrl ??
        _currentProduct?.thumbnail?.media?.cdnUrl ??
        _currentProduct?.thumbnail?.media?.localUrl ??
        '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                thumbnailUrl.isNotEmpty
                    ? Image.network(
                      thumbnailUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                    )
                    : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentProduct?.name ?? 'Product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_currentProduct?.salePrice != null &&
                        _currentProduct!.salePrice! > 0)
                      Text(
                        '\$${_currentProduct!.salePrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    if (_currentProduct?.salePrice != null &&
                        _currentProduct!.salePrice! > 0 &&
                        _currentProduct?.price != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '\$${_currentProduct!.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    if (_currentProduct?.salePrice == null ||
                        _currentProduct!.salePrice == 0)
                      Text(
                        '\$${_currentProduct?.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEQUENCE COMPLETED UI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSequenceCompletedUI() {
    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'All Flash Deals Completed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Check back tomorrow for more amazing deals',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Browse Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildFloatingAppBar(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE UI (Product Detail)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveUI() {
    return Stack(
      children: [
        _buildProductContent(),
        _buildFloatingAppBar(),
        _buildBottomBar(),
        ValueListenableBuilder<bool>(
          valueListenable: _showConfetti,
          builder: (context, show, child) {
            return show ? const ConfettiOverlay() : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildProductContent() {
    final product = _fullProductDetails;

    return RefreshIndicator(
      onRefresh: _fetchFlashDealData,
      color: _primaryColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlashDealBanner(),
                  const SizedBox(height: 10),
                  _buildPromotionBadge(product),
                  _buildPriceSection(),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _currentProduct?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),

                      _buildRatingRow(),
                    ],
                  ),

                  if (product?.product?.description != null ||
                      _currentProduct?.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: _ExpandableDescription(
                        htmlData:
                            product?.product?.description ??
                            _currentProduct?.description ??
                            '',
                      ),
                    ),
                ],
              ),
            ),

            if (product?.product?.bids != null)
              BidderTable(
                key: Key(product.hashCode.toString()),
                auction_start_time: product?.product?.auctionStartTime ?? '',
                auction_end_time: product?.product?.auctionEndTime ?? '',
                winnerID:
                    product?.product?.winnerId is String
                        ? product?.product?.winnerId
                        : '',
                productBids: product?.product?.bids ?? ProductBids(),
                startingPrice: _currentProduct?.price ?? 0,
                bidIncrement:
                    num.tryParse(
                      product?.product?.meta?.bidIncrementBy ?? '0',
                    ) ??
                    0,
              ),

            if (_currentProduct?.productGroup?.toLowerCase() != 'car')
              _buildDeliveryCard(),

            if (product?.product?.variation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: ProductVariationDisplay(
                    variation: product!.product!.variation!,
                    onAttributesSelected: (
                      attributesData,
                      variationId,
                      thumbnailUrl,
                    ) {
                      if (variationId == null) return;
                      selectedVariationId = variationId;
                      if (attributesData.isNotEmpty) {
                        final String firstKey = attributesData.keys.first;
                        if (attributesData[firstKey]?["price"] != null) {
                          selectedVariationPrice =
                              attributesData[firstKey]!["price"].toString();
                        }
                      }
                      // Update image slider with variation thumbnail
                      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
                        _updateImageSliderWithVariationThumbnail(thumbnailUrl);
                      }
                      // Find selected variation and update stock
                      final variations = product.product!.variation!.shop;
                      if (variations != null) {
                        final selectedVariation = variations.firstWhere(
                          (v) => v.id == variationId,
                          orElse: () => variations.first,
                        );
                        setState(() {
                          _selectedVariationStock = selectedVariation.stock;
                          // Reset quantity if it exceeds variation stock
                          final currentQty =
                              int.tryParse(_quantityController?.text ?? '1') ??
                              1;
                          final maxStock =
                              _selectedVariationStock ??
                              (_currentProduct?.stock ?? 999).toInt();
                          if (currentQty > maxStock) {
                            _quantityController?.text = maxStock.toString();
                          }
                        });
                      }
                    },
                  ),
                ),
              ),

            if (_currentProduct?.productGroup != 'car')
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    QuantitySelector(
                      controller: _quantityController!,
                      maxQuantity:
                          _selectedVariationStock ??
                          (_currentProduct?.stock ?? 999).toInt(),
                      minQuantity: 1,
                      onQuantityChanged: (quantity) {},
                    ),
                  ],
                ),
              ),

            _buildSecurityCard(),

            const SizedBox(height: 8),

            _buildStoreCard(),

            const SizedBox(height: 8),

            _buildReviewsCard(),

            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12, left: 12),
                    child: Text(
                      'Ended Deals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RelatedProductGrid(
                    isdealsection: true,
                    search:
                        product?.product?.name ?? _currentProduct?.name ?? '',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROMOTION BANNER WIDGETS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPromotionBadge(SingleModelClass? product) {
    final promotions = product?.product?.appliedPromotions;
    if (promotions == null || promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final promo = promotions.last;
    final discountValue = double.tryParse(promo.discountValue ?? '0') ?? 0;
    if (discountValue <= 0) return const SizedBox.shrink();

    final isPercentage = promo.discountType == 'percentage';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00897B)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            isPercentage
                ? '${discountValue.toStringAsFixed(1)}% Discount'
                : '\$${discountValue.toStringAsFixed(2)} Off',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildPromotionRibbon(product),
        ],
      ),
    );
  }

  Widget _buildPromotionRibbon(SingleModelClass? product) {
    final promotions = product?.product?.appliedPromotions;
    if (promotions == null || promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final promo = promotions.last;

    final name = (promo.name ?? '').toUpperCase();
    if (name.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFfda730), Color(0xFFfda730)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            name,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashDealBanner() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.flash_on, color: Colors.white),
          const SizedBox(width: 10),
          const Text(
            'Flash Deal ends in: ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _remainingSecondsNotifier,
            builder: (context, remainingSeconds, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _imageUrlsNotifier,
      builder: (context, imageUrls, child) {
        return Stack(
          children: [
            SizedBox(
              height: 350,
              child: ImageSlider(
                key: ValueKey(_imageSliderKey ?? 'default_slider'),
                videoUrl: _videoUrl,
                imageUrls: imageUrls,
                controller: _pageController!,
                onVideoStateChanged: () {},
                // Show thumbnail first, then video at index 1
                videoIndex: imageUrls.isNotEmpty ? 1 : 0,
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: _currentImageIndex,
                builder: (context, index, child) {
                  final total =
                      (_videoUrl != null)
                          ? imageUrls.length + 1
                          : imageUrls.length;

                  if (total <= 1) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}/$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceSection() {
    if (_currentProduct?.salePrice != null &&
        _currentProduct!.salePrice != 0 &&
        _currentProduct!.salePrice != 0.00) {
      final hasDiscount =
          _currentProduct!.price != null &&
          _currentProduct!.salePrice! < _currentProduct!.price!;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasDiscount)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '\$${_currentProduct!.price!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          if (hasDiscount) const SizedBox(width: 6),
          Text(
            '\$${_currentProduct!.salePrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ],
      );
    }

    if (_currentProduct?.price != null && _currentProduct!.price != 0.0) {
      return Text(
        '\$${_currentProduct!.price!.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Contact for Price',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _successColor,
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    final soldQuantity = _currentProduct?.meta?.sold ?? 0;
    final stock = _currentProduct?.stock ?? 0;

    return Row(
      children: [
        // ...List.generate(5, (index) {
        //   return const Icon(
        //     Icons.star_border,
        //     size: 16,
        //     color: Color(0xFFFFB800),
        //   );
        // }),
        // const SizedBox(width: 4),
        // const Text(
        //   '0.0',
        //   style: TextStyle(
        //     fontSize: 13,
        //     fontWeight: FontWeight.w600,
        //     color: _textPrimary,
        //   ),
        // ),
        // const SizedBox(width: 12),
        // Container(width: 1, height: 12, color: Colors.grey.shade300),
        // const SizedBox(width: 12),
        // Text(
        //   '$soldQuantity sold',
        //   style: const TextStyle(fontSize: 13, color: _textSecondary),
        // ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                stock > 0
                    ? _successColor.withOpacity(0.1)
                    : const Color(0xFFfda730).withOpacity(0.10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            stock > 0 ? '${stock.toInt()} in stock' : 'Out of stock',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: stock > 0 ? _successColor : const Color(0xFFfda730),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard() {
    final shippingFrom = _currentProduct?.meta?.shipping_time_from;
    final shippingTo = _currentProduct?.meta?.shipping_time_to;
    final hasShipping =
        shippingFrom != null &&
        shippingTo != null &&
        shippingFrom.toString().isNotEmpty &&
        shippingTo.toString().isNotEmpty;

    if (shippingTo == null && shippingFrom == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: SizedBox.shrink(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        color:
            hasShipping
                ? Colors.white
                : _currentProduct?.meta?.shipping_fees != null
                ? Colors.white
                : (_currentProduct?.meta?.shipping_company != null &&
                    _currentProduct!.meta!.shipping_company!.isNotEmpty)
                ? Colors.white
                : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasShipping)
              _buildInfoRow(
                icon: Icons.local_shipping_outlined,
                iconColor: _successColor,
                title: 'Delivery',
                value: '$shippingFrom - $shippingTo business days',
              ),
            if (_currentProduct?.meta?.shipping_fees != null) ...[
              if (hasShipping) Divider(height: 24, color: Colors.grey.shade300),
              _buildInfoRow(
                icon: Icons.payments_outlined,
                iconColor: Colors.grey,
                title: 'Shipping Fee',
                value: '\$${_currentProduct?.meta?.shipping_fees ?? 0}',
              ),
            ],
            if (_currentProduct?.meta?.shipping_company != null &&
                _currentProduct!.meta!.shipping_company!.isNotEmpty) ...[
              Divider(height: 24, color: Colors.grey.shade300),
              _buildInfoRow(
                icon: Icons.business_outlined,
                iconColor: _textSecondary,
                title: 'Carrier',
                value: _currentProduct?.meta?.shipping_company ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: _textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          showContactDialog(
            context,
            PaymentOptionsDialog(
              shown: true,
              onPaymentMethodTap: (a) {
                showCustomerServiceDialog(
                  context,
                  _fullProductDetails?.product?.shop?.shop?.meta?.phone ?? '',
                  _fullProductDetails?.product?.id ?? '',
                  _fullProductDetails
                      ?.product
                      ?.shop
                      ?.shop
                      ?.meta
                      ?.whatsappAreaCode,
                  _fullProductDetails?.product?.shop?.shop?.meta?.whatsapp ??
                      '',
                );
              },
            ),
          );
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: _successColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Buyer Protection',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildSecurityBadge(Icons.payment, 'Safe Payment'),
                  _buildSecurityBadge(Icons.lock_outline, 'Secure Privacy'),
                  _buildSecurityBadge(
                    Icons.shield_outlined,
                    'Purchase Protection',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _successColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildStoreCard() {
    final shop = _currentProduct?.shop?.shop;
    final thumbUrl = shop?.thumbnail?.message?.cdnUrl;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.STORE_PAGE,
          arguments: {'shopid': shop?.id ?? '', 'ShopShop': shop},
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: thumbUrl == null ? _primaryColor : null,
                image:
                    thumbUrl != null
                        ? DecorationImage(
                          image: NetworkImage(thumbUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
                shape: BoxShape.circle,
              ),
              child:
                  thumbUrl == null
                      ? Center(
                        child: Text(
                          (shop?.name ?? 'S')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop?.name ?? 'Store',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'View Store',
                    style: TextStyle(
                      fontSize: 13,
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: _primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Visit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right, color: _primaryColor, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.inbox_outlined, size: 32, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              const Text(
                'No reviews yet',
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showAppBarTitle,
        builder: (context, showTitle, child) {
          return Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: showTitle ? Colors.white : Colors.transparent,
              boxShadow:
                  showTitle
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Get.back(),
                  showBackground: !showTitle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: showTitle ? 1.0 : 0.0,
                    child: Text(
                      _currentProduct?.name ?? 'Flash Deal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                if (_currentProduct != null)
                  Obx(() {
                    final wishlistItems =
                        _wishlistController.wishlistResponse.wishlistItems;
                    final isInWishlist =
                        wishlistItems?.any(
                          (e) => e.productId == _currentProduct!.id,
                        ) ??
                        false;
                    return _buildCircleButton(
                      icon:
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                      iconColor: isInWishlist ? const Color(0xFFfda730) : null,
                      onTap: () {
                        final item =
                            wishlistItems
                                ?.where(
                                  (e) => e.productId == _currentProduct!.id,
                                )
                                .firstOrNull;
                        _toggleWishlist(item);
                      },
                      showBackground: !showTitle,
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBackground = true,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: showBackground ? Colors.black.withOpacity(0.4) : null,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? (showBackground ? Colors.white : _textPrimary),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_dealStatus != 'active' || _currentProduct == null) {
      return const SizedBox.shrink();
    }

    final bool isOutOfStock = _currentProduct!.stock == 0;
    String buttonText = 'Buy Now';
    bool canPurchase = true;

    if (isOutOfStock) {
      buttonText = 'Out of Stock';
      canPurchase = false;
    }

    if (_currentProduct?.productGroup == 'car') {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 12,
                top: 12,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _openWhatsAppGroup();
                      },
                      child: Container(
                        width: 40,
                        padding: const EdgeInsets.all(6),

                        child: Image.asset('assets/icons/whatsapp.png'),
                      ),
                    ),

                    const Text(
                      'انضم لمجموعتنا لتوصلك السيارات المعروضة يوميًّا',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  // WhatsApp Button (Teal - Secondary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.openWhatsApp(
                          phoneNumber:
                              _currentProduct?.shop?.shop?.meta?.phone ?? '',
                          whatsapp:
                              _currentProduct
                                  ?.shop
                                  ?.shop
                                  ?.meta
                                  ?.whatsappAreaCode,
                          whatsappCode:
                              _currentProduct
                                  ?.shop
                                  ?.shop
                                  ?.meta
                                  ?.whatsappAreaCode,
                        );
                        // WhatsApp action
                      },
                      icon: Image.asset(
                        'assets/icons/whatsapp.png',
                        height: 20,
                      ),
                      label: const Text("WhatsApp"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // Call Button (Orange - Primary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.makeCall(
                          _currentProduct?.shop?.shop?.meta?.phone ?? '',
                        );
                      },
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  // Live Chat Button (Teal - Secondary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.startLiveChat(
                          context: context,
                          productId: _currentProduct?.id ?? '',
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text("Live Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                showCustomerServiceDialog(
                  context,
                  _fullProductDetails?.product?.shop?.shop?.meta?.phone ?? '',
                  _fullProductDetails?.product?.id ?? '',
                  _fullProductDetails
                      ?.product
                      ?.shop
                      ?.shop
                      ?.meta
                      ?.whatsappAreaCode,
                  _fullProductDetails?.product?.shop?.shop?.meta?.whatsapp ??
                      '',
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: _dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: _textSecondary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isCartOperationInProgressNotifier,
                builder: (context, isLoading, child) {
                  return GestureDetector(
                    onTap:
                        canPurchase && !isLoading ? _openCheckoutSheet : null,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient:
                            canPurchase
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFFfda730),
                                    Color(0xFFfda730),
                                  ],
                                )
                                : null,
                        color: canPurchase ? null : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  buttonText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsAppGroup() async {
    final Uri url = Uri.parse(
      'https://chat.whatsapp.com/H4zhsjX17z5LV60lwtagR7?mode=r_c',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp link';
    }
  }

  /// Opens the flash deal checkout bottom sheet
  Future<void> _openCheckoutSheet() async {
    if (_currentProduct == null || _isDisposed) return;

    // Check if user is logged in
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    // Check if deal is still active
    if (_dealStatus != 'active') {
      NotificationHelper.showError(
        context,
        'Deal Ended',
        'This flash deal is no longer available.',
      );
      return;
    }

    final int quantity = int.tryParse(_quantityController?.text ?? '1') ?? 1;
    final double price =
        ((_currentProduct?.salePrice != null && _currentProduct!.salePrice! > 0)
                ? _currentProduct!.salePrice!
                : (_currentProduct?.price ?? 0))
            .toDouble();

    final double? shippingFee = double.tryParse(
      _currentProduct!.meta?.shipping_fees ?? '0',
    );

    // Get thumbnail URL
    String? thumbnailUrl;
    if (_imageUrlsNotifier.value.isNotEmpty) {
      thumbnailUrl = _imageUrlsNotifier.value.first;
    } else {
      thumbnailUrl =
          _currentProduct!.thumbnail?.media?.optimizedMediaUrl ??
          _currentProduct!.thumbnail?.media?.url;
    }

    final result = await showFlashDealCheckoutSheet(
      context: context,
      productId: _currentProduct!.id!,
      productName: _currentProduct!.name ?? 'Flash Deal Product',
      productImageUrl: thumbnailUrl,
      price: price,
      shippingFee: shippingFee,
      quantity: quantity,
      isDealActive: () => _dealStatus == 'active' && !_isDisposed,
      onDealExpired: () {
        // Deal expired while checkout sheet was open
        if (mounted) {
          _fetchFlashDealData();
        }
      },
    );

    if (result == true && mounted) {
      // Order was placed successfully
      // Refresh the deal data
      _fetchFlashDealData();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONFETTI OVERLAY WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with TickerProviderStateMixin {
  late List<ConfettiParticle> _particles;
  late AnimationController _animationController;

  final List<Color> _confettiColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFF95E1D3),
    const Color(0xFFF38181),
    const Color(0xFFAA96DA),
    const Color(0xFF00B4D8),
    const Color(0xFFFF9F43),
    const Color(0xFF6BCB77),
    const Color(0xFFE056FD),
  ];

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {
        _updateParticles();
      });
    });
    _animationController.forward();
  }

  void _initializeParticles() {
    final random = Random();
    _particles = List.generate(100, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * -1,
        velocityX: (random.nextDouble() - 0.5) * 0.02,
        velocityY: random.nextDouble() * 0.015 + 0.005,
        rotation: random.nextDouble() * 360,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        size: random.nextDouble() * 10 + 6,
        shape: random.nextInt(3),
      );
    });
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y += particle.velocityY;
      particle.x += particle.velocityX;
      particle.rotation += particle.rotationSpeed;
      particle.velocityX += (Random().nextDouble() - 0.5) * 0.001;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _animationController.value,
          ),
        ),
      ),
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  int shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      double opacity = 1.0;
      if (progress > 0.7) {
        opacity = 1.0 - ((progress - 0.7) / 0.3);
      }

      final paint =
          Paint()
            ..color = particle.color.withOpacity(opacity.clamp(0.0, 1.0))
            ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation * pi / 180);

      switch (particle.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.5,
              height: particle.size * 0.6,
            ),
            paint,
          );
          break;
        case 2:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

// ══════════════════════════════════════════════════════════════════════════════
// EXPANDABLE DESCRIPTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class _ExpandableDescription extends StatefulWidget {
  final String htmlData;
  const _ExpandableDescription({required this.htmlData});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  bool _needsExpansion = false;

  final HtmlUnescape _unescape = HtmlUnescape();

  String _cleanHtml(String html) {
    String text = html;
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = _unescape.convert(text);
    text = text.replaceAll('\u00A0', ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfExpansionNeeded();
    });
  }

  void _checkIfExpansionNeeded() {
    final cleanText = _cleanHtml(widget.htmlData);
    setState(() {
      _needsExpansion = cleanText.length > 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cleanText = _cleanHtml(widget.htmlData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
          firstChild: Text(
            cleanText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          secondChild: Text(
            cleanText,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
        if (_needsExpansion)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _isExpanded ? 'Show less' : 'Show more',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFF6B00),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CUSTOMER SERVICE DIALOG
// ══════════════════════════════════════════════════════════════════════════════
void showCustomerServiceDialog(
  BuildContext context,
  String phoneNumber,
  String productid,
  String? whatsAppCode,
  String whatsapp,
) {
  showDialog(
    context: context,
    builder:
        (context) => CustomerServiceDialog(
          whatsapp: whatsapp,
          phoneNumber: phoneNumber,
          whatsappCode: whatsAppCode,
          productid: productid,
        ),
  );
}
