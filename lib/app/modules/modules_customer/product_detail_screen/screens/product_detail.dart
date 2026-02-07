// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/dialogs/payment_security.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/models/wishlists/wishlist_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/attributes.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/bids.dart';
import 'package:tjara/app/modules/modules_customer/app_home/service/customer_service.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/image_slider.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/quantity.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/bids_service/bid_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/quick_buy_checkout_sheet.dart';
import 'package:html_unescape/html_unescape.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.activeFlashDealProductId = '',
  });
  final ProductDatum product;
  final String activeFlashDealProductId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
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

  PageController? _pageController;
  TextEditingController? _quantityController;
  ScrollController? _scrollController;

  CartService get _cartService => Get.find<CartService>();
  HomeController get _homeController => Get.find<HomeController>();
  WishlistServiceController get _wishlistController =>
      Get.find<WishlistServiceController>();

  final ValueNotifier<SingleModelClass?> _cachedProductNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<SingleModelClass?> _freshProductNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);
  final ValueNotifier<List<String>> _imageUrlsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _isCartOperationInProgressNotifier = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> _showAppBarTitle = ValueNotifier(false);
  final ValueNotifier<int> _currentImageIndex = ValueNotifier(0);

  String? selectedVariationPrice;
  String? selectedVariationId;
  int? _selectedVariationStock;
  bool _isDisposed = false;
  final bool _isNavigating = false;

  late final String _imageSliderStableKey;
  String? _videoUrl;
  bool isdealProduct = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // FLASH DEAL TIMER VARIABLES
  // ═══════════════════════════════════════════════════════════════════════════
  Timer? _flashDealApiTimer;
  Timer? _countdownTimer;
  bool _isFlashDealActive = false;
  bool _isFlashDealExpired = false;
  bool _hasShownConfetti = false;
  bool _showConfetti = false;
  bool initialized = false;
  DateTime? _dealEndTime;
  Duration _remainingTime = Duration.zero;
  String? _currentFlashDealProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _initializeImageUrls();

    _imageSliderStableKey = 'image_slider_${widget.product.id}';

    _scrollController =
        ScrollController()..addListener(() {
          _showAppBarTitle.value = _scrollController!.offset > 250;
        });

    _loadProductData();

    // Start flash deal timer if activeFlashDealProductId is not empty
    if (widget.activeFlashDealProductId.isNotEmpty) {
      _startFlashDealPolling();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLASH DEAL POLLING & TIMER LOGIC
  // ═══════════════════════════════════════════════════════════════════════════
  void _startFlashDealPolling() async {
    // Initial call
    await _fetchFlashDealData();

    // Start 3-second polling
    _flashDealApiTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isDisposed) {
        _fetchFlashDealData();
      }
    });
  }

  bool _isLoadingFlashDeal = false;

  Future<void> _fetchFlashDealData() async {
    // ❌ Already loading OR disposed → return
    if (_isDisposed || _isLoadingFlashDeal) return;

    _isLoadingFlashDeal = true;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/products/flash-deals?with=gallery,attribute_items,rating,video,meta&fetchNewDeals=true',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200 && !_isDisposed) {
        final data = json.decode(response.body);

        final productId = data['product']?['id']?.toString() ?? '';
        final dealEndTimeStr = data['current_deal_end_time']?.toString() ?? '';

        if (productId == widget.product.id.toString()) {
          _currentFlashDealProductId = productId;

          final endTime = _parseFlashDealTime(dealEndTimeStr);

          if (endTime != null) {
            _dealEndTime = endTime;
            _updateRemainingTime();

            if (_remainingTime > Duration.zero) {
              if (!_isFlashDealActive && !_hasShownConfetti) {
                setState(() {
                  initialized = true;
                  _showConfetti = true;
                  _hasShownConfetti = true;
                  _isFlashDealActive = true;
                  _isFlashDealExpired = false;
                });

                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted && !_isDisposed) {
                    setState(() => _showConfetti = false);
                  }
                });

                _startCountdownTimer();
              } else if (!_isFlashDealActive) {
                setState(() {
                  _isFlashDealActive = true;
                  _isFlashDealExpired = false;
                });
                _startCountdownTimer();
              }
            } else {
              _handleFlashDealExpired();
            }
          }
        } else {
          _handleFlashDealMismatch();
        }
      }
    } catch (e) {
      _isLoadingFlashDeal = false;
      debugPrint('Flash deal API error: $e');
    } finally {
      // ✅ Always reset loading
      _isLoadingFlashDeal = false;
      setState(() {});
    }
  }

  DateTime? _parseFlashDealTime(String dateString) {
    if (dateString.isEmpty) return null;

    try {
      DateTime parsedDate;

      // Handle different date formats
      if (dateString.contains(' ')) {
        final normalized = dateString.replaceFirst(' ', 'T');
        parsedDate = DateTime.parse(normalized);
      } else {
        parsedDate = DateTime.parse(dateString);
      }

      // Convert to UTC for comparison
      return parsedDate.toUtc();
    } catch (e) {
      debugPrint('Error parsing flash deal date: $e');
      return null;
    }
  }

  void _updateRemainingTime() {
    if (_dealEndTime == null) {
      _remainingTime = Duration.zero;
      return;
    }

    final endTimeLocal = _dealEndTime!.toLocal();
    final nowUtc = DateTime.now().toUtc();

    final offset = DateTime.now().timeZoneOffset;

    // Adjust difference by adding offset to align timezones
    final difference = endTimeLocal.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingTime = Duration.zero;
      _handleFlashDealExpired();
    } else {
      _remainingTime = difference;
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposed) {
        setState(() {
          _updateRemainingTime();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleFlashDealExpired() {
    _flashDealApiTimer?.cancel();
    _countdownTimer?.cancel();

    if (mounted && !_isDisposed) {
      setState(() {
        _isFlashDealActive = false;
        _isFlashDealExpired = true;
      });

      // Navigate back and change tab to "All" (index 0) when flash deal expires
      if (widget.activeFlashDealProductId.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted && !_isDisposed) {
            await _homeController.fetchDealsProducts();
            Get.back();
          }
        });
      }
    }
  }

  void _handleFlashDealMismatch() {
    _flashDealApiTimer?.cancel();
    _countdownTimer?.cancel();

    if (mounted && !_isDisposed) {
      setState(() {
        _isFlashDealActive = false;
        _isFlashDealExpired = true;
        _currentFlashDealProductId = null;
      });

      // Navigate back and change tab to "All" (index 0) when flash deal product changes
      if (widget.activeFlashDealProductId.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted && !_isDisposed) {
            await _homeController.fetchDealsProducts();
            Get.back();
          }
        });
      }
    }
  }

  String _formatRemainingTime() {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _initializeControllers() {
    _pageController =
        PageController()..addListener(() {
          _currentImageIndex.value = _pageController!.page?.round() ?? 0;
        });
    _quantityController = TextEditingController(text: '1');
  }

  void _initializeImageUrls() {
    final videoUrl =
        widget.product.video?.message?.url ??
        widget.product.video?.message?.optimizedMediaUrl;
    if (videoUrl?.isNotEmpty == true) {
      _imageUrlsNotifier.value = [];
    } else {
      final thumbnailUrl =
          widget.product.thumbnail?.media?.cdnThumbnailUrl ??
          widget.product.thumbnail?.media?.optimizedMediaCdnUrl ??
          widget.product.thumbnail?.media?.cdnUrl ??
          widget.product.thumbnail?.media?.url ??
          widget.product.thumbnail?.media?.localUrl ??
          widget.product.thumbnail?.media?.optimizedMediaUrl ??
          '';
      _imageUrlsNotifier.value = [thumbnailUrl];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imageUrlsNotifier.value.isNotEmpty) {
      _precacheImages(_imageUrlsNotifier.value);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _pauseVideoIfPlaying();
    _pageController?.dispose();
    _quantityController?.dispose();
    _scrollController?.dispose();
    _cachedProductNotifier.dispose();
    _freshProductNotifier.dispose();
    _isLoadingNotifier.dispose();
    _errorMessageNotifier.dispose();
    _imageUrlsNotifier.dispose();
    _isCartOperationInProgressNotifier.dispose();
    _showAppBarTitle.dispose();
    _currentImageIndex.dispose();
    _timer?.cancel();
    _timer = null;

    // Cancel flash deal timers
    _flashDealApiTimer?.cancel();
    _countdownTimer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseVideoIfPlaying();
    }
  }

  void _pauseVideoIfPlaying() {}

  Future<void> _loadProductData() async {
    if (_isDisposed) return;
    try {
      _loadCachedProduct();
      await _fetchFreshDataWithFallback();
      _initializeTimerofAuction();
    } catch (e) {
      debugPrint('Error loading product data: $e');
      if (!_isDisposed && _cachedProductNotifier.value == null) {
        _errorMessageNotifier.value = 'Failed to load product details.';
      }
    }
  }

  Future<void> _fetchFreshDataWithFallback() async {
    if (_isDisposed) return;
    try {
      final freshProduct = await _homeController.fetchSingleProducts(
        widget.product.id.toString(),
      );
      if (!_isDisposed && freshProduct != null) {
        await _saveFreshDataToCache(freshProduct);
        _cachedProductNotifier.value = freshProduct;
        _freshProductNotifier.value = freshProduct;

        _errorMessageNotifier.value = null;
        _updateImageUrls(freshProduct);
      } else if (!_isDisposed) {
        _handleFreshDataFailure();
      }
    } catch (e) {
      if (!_isDisposed) _handleFreshDataFailure();
    }
  }

  void _handleFreshDataFailure() {
    if (_cachedProductNotifier.value != null) {
      _updateImageUrls(_cachedProductNotifier.value!);
    } else {
      // _errorMessageNotifier.value = 'Failed to load product details.';
    }
  }

  Future<void> _loadCachedProduct() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(
        'product_${widget.product.id}',
      );
      if (cachedData != null && !_isDisposed) {
        _cachedProductNotifier.value = SingleModelClass.fromJson(
          json.decode(cachedData),
        );
      }
    } catch (e) {
      debugPrint('Error loading cached product: $e');
    }
  }

  Future<void> _saveFreshDataToCache(SingleModelClass freshProduct) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'product_${widget.product.id}',
        json.encode(freshProduct.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving product to cache: $e');
    }
  }

  Future<void> _addToCart({SingleModelClass? product}) async {
    if (_isCartOperationInProgressNotifier.value || _isNavigating) return;

    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    // Check if variation is required but not selected
    if (_isVariationRequired(product)) {
      _showVariationRequiredMessage();
      return;
    }

    _isCartOperationInProgressNotifier.value = true;

    try {
      final int quantity = int.tryParse(_quantityController?.text ?? '1') ?? 1;
      final double price =
          double.tryParse(widget.product.price.toString()) ?? 0.0;

      final result = await _cartService.updateCart(
        widget.product.shopId ?? '',
        widget.product.id ?? '',
        quantity,
        price,
        variationId: selectedVariationId,
      );

      if (mounted && !_isDisposed) {
        _handleCartUpdateResult(result);
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to add to cart',
        );
      }
    } finally {
      if (!_isDisposed) {
        _isCartOperationInProgressNotifier.value = false;
      }
    }
  }

  void _handleCartUpdateResult(dynamic result) {
    if (!mounted || _isDisposed) return;
    if (result is String) {
      NotificationHelper.showError(context, 'Failed', result);
    } else if (result is bool && result) {
      NotificationHelper.showSuccess(context, 'Success', 'Added to cart');
      try {
        (Get.isRegistered<DashboardController>()
                ? Get.find<DashboardController>()
                : Get.put(DashboardController()))
            .fetchCartCount();
      } catch (_) {}
    } else {
      NotificationHelper.showError(context, 'Failed', 'Failed to add to cart');
    }
  }

  Future<void> _toggleWishlist(WishlistItem? wishlistItem) async {
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
        widget.product.id.toString(),
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

  bool _issinleAuctionExpired(Product? productData) {
    if (productData == null) return false;

    final auctionEndTime = productData.auctionEndTime;
    if (auctionEndTime == null ||
        auctionEndTime.toString().isEmpty ||
        auctionEndTime.toString() == 'null') {
      return true;
    }

    DateTime? endTime;

    endTime = DateTime.tryParse(auctionEndTime)?.toLocal();

    if (endTime == null) {
      return true;
    }

    // 🔥 SAME APPROACH (UTC + offset)
    final nowUtc = DateTime.now().toUtc();
    final offset = DateTime.now().timeZoneOffset;
    final difference = endTime.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingTime = Duration.zero;
      return true;
    } else {
      return false;
    }
  }

  bool _isAuctionExpired(ProductDatum? productData) {
    if (productData == null) return false;

    final auctionEndTime = productData.auctionEndTime;
    if (auctionEndTime == null ||
        auctionEndTime.toString().isEmpty ||
        auctionEndTime.toString() == 'null') {
      return true;
    }

    DateTime? endTime;

    endTime = DateTime.tryParse(auctionEndTime)?.toLocal();

    if (endTime == null) {
      return true;
    }

    // 🔥 SAME APPROACH (UTC + offset)
    final nowUtc = DateTime.now().toUtc();
    final offset = DateTime.now().timeZoneOffset;
    final difference = endTime.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingTime = Duration.zero;
      return true;
    } else {
      return false;
    }
  }

  bool _isAuctionProduct(dynamic productData) {
    if (productData == null) return false;
    final auctionStartTime = productData.auctionStartTime;
    final auctionEndTime = productData.auctionEndTime;
    return auctionStartTime != null &&
        auctionEndTime != null &&
        auctionStartTime.toString().isNotEmpty &&
        auctionEndTime.toString().isNotEmpty &&
        auctionStartTime.toString() != 'null' &&
        auctionEndTime.toString() != 'null';
  }

  void _updateImageUrls(SingleModelClass product) {
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

    // Empty string ko null banao
    _videoUrl = (videoUrlRaw?.isNotEmpty == true) ? videoUrlRaw : null;

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

    // Fallback: if no images found yet, try to get from widget.product thumbnail
    if (newUrls.isEmpty && _videoUrl == null) {
      final thumbnailUrl =
          widget.product.thumbnail?.media?.optimizedMediaUrl ??
          widget.product.thumbnail?.media!.url?.toString().trim() ??
          widget.product.thumbnail?.media!.optimizedMediaUrl
              ?.toString()
              .trim() ??
          widget.product.thumbnail?.media?.cdnThumbnailUrl ??
          widget.product.thumbnail?.media?.optimizedMediaCdnUrl ??
          widget.product.thumbnail?.media?.cdnUrl ??
          widget.product.thumbnail?.media?.localUrl ??
          '';
      if (thumbnailUrl.isNotEmpty == true) {
        newUrls.add(thumbnailUrl);
      }
    }

    if (newUrls.length != _imageUrlsNotifier.value.length ||
        !newUrls.every((url) => _imageUrlsNotifier.value.contains(url))) {
      _imageUrlsNotifier.value = newUrls;
    }
  }

  /// Scrolls the image slider to show the variation thumbnail
  void _updateImageSliderWithVariationThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.isEmpty) return;

    final currentUrls = _imageUrlsNotifier.value;

    // Find the index of the thumbnail in the image list
    final int imageIndex = currentUrls.indexOf(thumbnailUrl);
    if (imageIndex < 0) return;

    // Calculate the actual slider index accounting for video position
    // For deal products: video is at index 1, for regular products: video is at index 0
    final hasVideo = _videoUrl != null && _videoUrl!.isNotEmpty;
    final videoIndex = widget.product.isDeal == 1 ? 1 : 0;
    final targetIndex =
        hasVideo && imageIndex >= videoIndex
            ? imageIndex +
                1 // Shift by 1 to account for video slot
            : imageIndex;

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

  void _precacheImages(List<String> imageUrls) {
    for (final url in imageUrls) {
      if (url.trim().isEmpty) continue;

      final imageProvider = NetworkImage(url);
      final ImageStream stream = imageProvider.resolve(
        const ImageConfiguration(),
      );

      late final ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          // ✅ Image valid hai → precache
          precacheImage(imageProvider, context);
          stream.removeListener(listener);
        },
        onError: (error, stackTrace) {
          // ❌ Corrupt / broken image → ignore
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);
    }
  }

  bool _hasDiscount() {
    if (widget.product.salePrice == null ||
        widget.product.salePrice == 0 ||
        widget.product.price == null) {
      return false;
    }
    return widget.product.salePrice! < widget.product.price!;
  }

  double _calculateDiscountPercentage() {
    if (!_hasDiscount()) return 0.0;
    final originalPrice = widget.product.price!;
    final salePrice = widget.product.salePrice!;
    if (originalPrice <= 0) return 0.0;
    return ((originalPrice - salePrice) / originalPrice) * 100;
  }

  double _getAverageRating() {
    if (widget.product.rating == null ||
        widget.product.rating is! List ||
        (widget.product.rating as List).isEmpty) {
      return 0.0;
    }
    try {
      final ratingList = widget.product.rating as List;
      double sum = 0.0;
      int count = 0;
      for (var rating in ratingList) {
        if (rating is num && rating > 0) {
          sum += rating.toDouble();
          count++;
        }
      }
      return count > 0 ? sum / count : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Timer? _timer;
  DateTime? _endTime;
  final Duration _remainingTimeofAuction = Duration.zero;
  bool _isExpired = false;

  void _initializeTimerofAuction() {
    try {
      if (!_isAuctionProduct(_freshProductNotifier.value?.product)) {
        return;
      }

      if (_freshProductNotifier.value?.product?.auctionEndTime == null) {
        return;
      }

      if (_freshProductNotifier.value!.product!.auctionEndTime
          .toString()
          .isEmpty) {
        return;
      }

      if (_freshProductNotifier.value!.product!.auctionEndTime.toString() ==
          'null') {
        return;
      }

      if (DateTime.tryParse(
            _freshProductNotifier.value!.product!.auctionEndTime,
          ) ==
          null) {
        return;
      }
      _endTime =
          DateTime.parse(
            _freshProductNotifier.value!.product!.auctionEndTime,
          ).toLocal();
      _updateRemainingTimeofAuction();
      _startTimerofAuction();
    } catch (_) {
      _isExpired = true;
    }
  }

  void _startTimerofAuction() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateRemainingTimeofAuction();
        setState(() {});
      }
    });
  }

  void _updateRemainingTimeofAuction() {
    if (_endTime == null) {
      _remainingTime = Duration.zero;
      _isExpired = true;
      return;
    }

    // 🔥 SAME APPROACH (UTC + offset)
    final nowUtc = DateTime.now().toUtc();
    final offset = DateTime.now().timeZoneOffset;
    final difference = _endTime!.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingTime = Duration.zero;
      _isExpired = true;
      _timer?.cancel();
      _timer = null;
    } else {
      _remainingTime = difference;
      _isExpired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: ValueListenableBuilder<String?>(
          valueListenable: _errorMessageNotifier,
          builder: (context, errorMessage, child) {
            return ValueListenableBuilder<SingleModelClass?>(
              valueListenable: _cachedProductNotifier,
              builder: (context, cachedProduct, child) {
                return ValueListenableBuilder<SingleModelClass?>(
                  valueListenable: _freshProductNotifier,
                  builder: (context, freshProduct, child) {
                    final currentProduct = freshProduct ?? cachedProduct;
                    if (errorMessage != null && currentProduct == null) {
                      return _buildErrorWidget();
                    }
                    return Stack(
                      children: [
                        _buildProductContent(currentProduct),
                        _buildFloatingAppBar(),
                        _buildBottomBar(currentProduct),

                        // Confetti Overlay
                        if (_showConfetti) const ConfettiOverlay(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLASH DEAL BANNER WIDGET
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFlashDealBanner() {
    // Check if this is a deal product
    if (widget.product.isDeal != 1) {
      return const SizedBox.shrink();
    }

    if (widget.activeFlashDealProductId.isNotEmpty && !initialized) {
      return const SizedBox.shrink();
    }

    // If flash deal is active, show countdown
    if (_isFlashDealActive && _remainingTime > Duration.zero) {
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatRemainingTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Deal ended (expired or no sale time)
    if (widget.product.saleStartTime == null &&
        widget.product.saleEndTime == null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xffadb2b6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(width: 10),
            Icon(Icons.add_circle_outline_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'This deal has ended. You missed it!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLOATING APP BAR - Clean & Minimal
  // ══════════════════════════════════════════════════════════════════════════
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
                      widget.product.name ?? '',
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
                const SizedBox(width: 12),

                Obx(() {
                  final wishlistItems =
                      _wishlistController.wishlistResponse.wishlistItems;
                  final isInWishlist =
                      wishlistItems?.any(
                        (e) => e.productId == widget.product.id,
                      ) ??
                      false;
                  return _buildCircleButton(
                    icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
                    iconColor: isInWishlist ? const Color(0xFFfda730) : null,
                    onTap: () {
                      final item =
                          wishlistItems
                              ?.where((e) => e.productId == widget.product.id)
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

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN PRODUCT CONTENT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildProductContent(SingleModelClass? product) {
    return RefreshIndicator(
      onRefresh: _loadProductData,
      color: _primaryColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(),

            // Product Info Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flash Deal Banner (replaces old "This deal has ended" widget)
                  _buildFlashDealBanner(),
                  const SizedBox(height: 10),

                  if (product?.product?.bids == null)
                    // Price Section
                    _buildPriceSection(),
                  if (product?.product?.bids == null) const SizedBox(height: 6),

                  // Product Name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),

                      Builder(
                        builder: (context) {
                          if (widget.product.productGroup != 'car') {
                            return Container();
                          }
                          final int? stock = int.tryParse(
                            widget.product.stock?.toString() ?? '',
                          );

                          return Text(
                            (stock != null && stock > 0) ? 'Available' : '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _primaryColor,
                              height: 1.4,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (widget.product.productGroup != 'car')
                    // Rating & Sold
                    _buildRatingRow(),

                  // Description
                  if (product?.product?.description != null ||
                      widget.product.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: _ExpandableDescription(
                        htmlData:
                            product?.product?.description ??
                            widget.product.description ??
                            '',
                      ),
                    ),
                ],
              ),
            ),
            // Variations
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
                              (widget.product.stock ?? 999).toInt();
                          if (currentQty > maxStock) {
                            _quantityController?.text = maxStock.toString();
                          }
                        });
                      }
                    },
                  ),
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
                startingPrice: widget.product.price ?? 0,
                bidIncrement:
                    num.tryParse(
                      product?.product?.meta?.bidIncrementBy ?? '0',
                    ) ??
                    0,
              ),

            if (widget.product.productGroup?.toLowerCase() != 'car')
              // Delivery Info
              _buildDeliveryCard(),

            // Quantity (for non-car, non-auction)
            if (widget.product.productGroup != 'car' &&
                !(_isAuctionProduct(product?.product) ||
                    _isAuctionProduct(widget.product)))
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
                          (widget.product.stock ?? 999).toInt(),
                      minQuantity: 1,
                      onQuantityChanged: (quantity) {},
                    ),
                  ],
                ),
              ),

            // Security & Trust
            _buildSecurityCard(product),

            const SizedBox(height: 8),

            // Store Info
            _buildStoreCard(product),

            const SizedBox(height: 8),

            // Reviews
            _buildReviewsCard(),

            const SizedBox(height: 8),

            // Related Products
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 12),
                    child: Text(
                      widget.product.isDeal.toString() != '1'
                          ? 'You May Also Like'
                          : 'Ended Deals',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RelatedProductGrid(
                    isdealsection: widget.product.isDeal.toString() == '1',
                    search: product?.product?.name ?? widget.product.name ?? '',
                  ),
                ],
              ),
            ),

            // Bottom padding for sticky bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE GALLERY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildImageGallery() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _imageUrlsNotifier,
      builder: (context, imageUrls, child) {
        return Stack(
          children: [
            SizedBox(
              height: 350,

              child: ImageSlider(
                key: ValueKey(_imageSliderStableKey + _videoUrl.toString()),
                videoUrl:
                    _videoUrl != null
                        ? _videoUrl!.isEmpty
                            ? null
                            : _videoUrl
                        : null,
                imageUrls: imageUrls,
                controller: _pageController!,
                onVideoStateChanged: () {},
                // For deal products: featured image first (index 0), video second (index 1)
                // For regular products: video first (index 0)
                videoIndex: widget.product.isDeal == 1 ? 1 : 0,
              ),
            ),
            // Image Counter
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
            // Discount Badge
            // if (_hasDiscount())
            //   Positioned(
            //     top: MediaQuery.of(context).padding.top + 60,
            //     left: 0,
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 5,
            //       ),
            //       decoration: const BoxDecoration(
            //         color: Color(0xFFE53935),
            //         borderRadius: BorderRadius.only(
            //           topRight: Radius.circular(4),
            //           bottomRight: Radius.circular(4),
            //         ),
            //       ),
            //       child: Text(
            //         '-${_calculateDiscountPercentage().toInt()}%',
            //         style: const TextStyle(
            //           color: Colors.white,
            //           fontSize: 12,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRICE SECTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPriceSection() {
    // Sale price available
    if (widget.product.salePrice != null &&
        widget.product.salePrice != 0 &&
        widget.product.salePrice != 0.00) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${widget.product.salePrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          if (_hasDiscount()) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '\$${widget.product.price!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Price range
    if (widget.product.minPrice != null &&
        widget.product.maxPrice != null &&
        widget.product.minPrice != 0 &&
        widget.product.maxPrice != 0) {
      return const Text(
        '',
        // '\$${widget.product.maxPrice!.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      );
    }

    // Single price
    if (widget.product.price != null && widget.product.price != 0.0) {
      return Text(
        '\$${widget.product.price!.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      );
    }

    // Ask dealer
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

  // ══════════════════════════════════════════════════════════════════════════
  // RATING ROW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRatingRow() {
    final rating = _getAverageRating();
    final soldQuantity = widget.product.meta?.sold ?? 0;
    final stock = widget.product.stock ?? 0;
    final isCarProduct = widget.product.productGroup?.toLowerCase() == 'car';

    return Row(
      children: [
        // Rating stars
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            size: 16,
            color: const Color(0xFFFFB800),
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '0.0',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 1, height: 12, color: Colors.grey.shade300),
        const SizedBox(width: 12),
        if (!isCarProduct) ...[
          Text(
            '$soldQuantity sold',
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
          const Spacer(),
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
              stock > 0 ? '$stock in stock' : 'Out of stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: stock > 0 ? _successColor : const Color(0xFFfda730),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELIVERY CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDeliveryCard() {
    final shippingFrom = widget.product.meta?.shipping_time_from;

    final shippingTo = widget.product.meta?.shipping_time_to;
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
                : widget.product.meta?.shipping_fees != null
                ? Colors.white
                : (widget.product.meta?.shipping_company != null &&
                    widget.product.meta!.shipping_company!.isNotEmpty)
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
            if (widget.product.meta?.shipping_fees != null) ...[
              if (hasShipping) Divider(height: 24, color: Colors.grey.shade300),
              _buildInfoRow(
                icon: Icons.payments_outlined,
                iconColor: Colors.grey,
                title: 'Shipping Fee',
                value: '\$${widget.product.meta?.shipping_fees ?? 0}',
              ),
            ],
            if (widget.product.meta?.shipping_company != null &&
                widget.product.meta!.shipping_company!.isNotEmpty) ...[
              Divider(height: 24, color: Colors.grey.shade300),
              _buildInfoRow(
                icon: Icons.business_outlined,
                iconColor: _textSecondary,
                title: 'Carrier',
                value: widget.product.meta?.shipping_company ?? '',
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

  // ══════════════════════════════════════════════════════════════════════════
  // SECURITY CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSecurityCard(SingleModelClass? product) {
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
                  product?.product?.shop?.shop?.meta?.phone ?? '',
                  product?.product?.id ?? '',
                  product?.product?.shop?.shop?.meta?.whatsappAreaCode,
                  product?.product?.shop?.shop?.meta?.whatsapp ?? '',
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

  // ══════════════════════════════════════════════════════════════════════════
  // STORE CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStoreCard(SingleModelClass? product) {
    final shop = product?.product?.shop?.shop;

    final thumbUrl =
        shop?.thumbnail?.media?.cdnThumbnailUrl ??
        shop?.thumbnail?.media?.optimizedMediaCdnUrl ??
        shop?.thumbnail?.media?.cdnUrl ??
        shop?.thumbnail?.media?.url ??
        shop?.thumbnail?.media?.localUrl ??
        shop?.thumbnail?.media?.optimizedMediaUrl;

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
                    shop?.name ?? widget.product.shop?.shop?.name ?? '',
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

  // ══════════════════════════════════════════════════════════════════════════
  // REVIEWS CARD
  // ══════════════════════════════════════════════════════════════════════════
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

  TextEditingController bidController = TextEditingController();

  bool _isLoading = false;

  // Check if variation selection is required but not selected
  bool _isVariationRequired(SingleModelClass? product) {
    return product?.product?.variation != null && selectedVariationId == null;
  }

  void _showVariationRequiredMessage() {
    NotificationHelper.showError(
      context,
      'Selection Required',
      'Please select product options before proceeding',
    );
  }

  // Place Bid Method
  Future<void> placeBid() async {
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }
    final BidService bidService = BidService(
      userId: currentUser?.user?.id ?? '',
    );
    final bidText = bidController.text.trim();

    if (bidText.isEmpty) {
      _showMessage('Please enter a bid amount', isError: true);
      return;
    }

    final bidAmount = int.tryParse(bidText);
    if (bidAmount == null || bidAmount <= 0) {
      _showMessage('Please enter a valid bid amount', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await bidService.placeBid(
      productId: widget.product.id.toString(),
      bidPrice: bidAmount,
    );

    await _loadProductData();

    setState(() => _isLoading = false);

    if (result.success && result.data != null) {
      _showMessage(result.message, isError: false);
      bidController.clear();

      // Optional: Show winner status
      if (result.data!.isWinner) {
        _showMessage('🎉 You are the highest bidder!', isError: false);
      } else {
        _showMessage(
          'Current highest bid: \$${result.data!.highestBid}',
          isError: false,
        );
      }
    } else {
      _showMessage(result.message, isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUICK BUY CHECKOUT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _openQuickBuySheet(SingleModelClass? product) async {
    if (_isDisposed) return;

    // Check if user is logged in
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    // Check if variation is required but not selected
    if (_isVariationRequired(product)) {
      _showVariationRequiredMessage();
      return;
    }

    final int quantity = int.tryParse(_quantityController?.text ?? '1') ?? 1;
    final double price =
        selectedVariationPrice != null
            ? (double.tryParse(selectedVariationPrice!) ??
                (widget.product.price?.toDouble() ?? 0.0))
            : ((widget.product.salePrice != null &&
                    widget.product.salePrice! > 0)
                ? widget.product.salePrice!.toDouble()
                : (widget.product.price?.toDouble() ?? 0.0));

    final double? shippingFee = double.tryParse(
      widget.product.meta?.shipping_fees ?? '0',
    );

    // Get thumbnail URL
    String? thumbnailUrl;
    if (_imageUrlsNotifier.value.isNotEmpty) {
      thumbnailUrl = _imageUrlsNotifier.value.first;
    } else {
      thumbnailUrl =
          widget.product.thumbnail?.media?.optimizedMediaUrl ??
          widget.product.thumbnail?.media?.url;
    }

    final result = await showQuickBuyCheckoutSheet(
      context: context,
      productId: widget.product.id!,
      shopId: widget.product.shopId ?? '',
      productName: widget.product.name ?? 'Product',
      productImageUrl: thumbnailUrl,
      price: price,
      shippingFee: shippingFee,
      quantity: quantity,
      variationId: selectedVariationId,
    );

    if (result == true && mounted) {
      // Order was placed successfully - refresh data
      _loadProductData();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM BAR (STICKY)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(SingleModelClass? product) {
    final bool isAuction =
        product == null
            ? _isAuctionProduct(widget.product)
            : _isAuctionProduct(product.product);

    final bool isAuctionExpired =
        product == null
            ? _isAuctionExpired(widget.product)
            : _issinleAuctionExpired(product.product);

    // Check stock from both sources - use widget.product.stock as fallback
    // This prevents UI from suddenly changing when fresh data loads
    final num? freshStock = product?.product?.stock;
    final num? widgetStock = widget.product.stock;

    // If fresh data has stock info, use it; otherwise use widget stock
    final bool isOutOfStock =
        freshStock != null
            ? freshStock == 0
            : (widgetStock == null || widgetStock == 0);

    String buttonText = 'Add to Cart';
    // Default canPurchase based on widget.product stock (initial state)
    bool canPurchase = widgetStock != null && widgetStock > 0;

    if (widget.product.productGroup == 'car') {
      // Car products don't use canPurchase for buy buttons
      canPurchase = false;
      if (isOutOfStock) {
        buttonText = 'Out of Stock';
      }
    } else if (isAuction && isAuctionExpired) {
      buttonText = 'Auction Expired';
      canPurchase = false;
    } else if (_isExpired == true) {
      buttonText = 'Auction Expired';
      canPurchase = false;
    } else if (isAuction) {
      buttonText = 'Place Bid';
      canPurchase = false; // Auction uses bid, not purchase
    } else if (isOutOfStock) {
      buttonText = 'Out of Stock';
      canPurchase = false;
    } else {
      // Normal product with stock available
      canPurchase = true;
    }

    if (widget.product.productGroup == 'car') {
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
                              product?.product?.shop?.shop?.meta?.phone ?? '',
                          whatsapp:
                              product
                                  ?.product
                                  ?.shop
                                  ?.shop
                                  ?.meta
                                  ?.whatsappAreaCode,
                          whatsappCode:
                              product
                                  ?.product
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Call Button (Orange - Primary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.makeCall(
                          product?.product?.shop?.shop?.meta?.phone ?? '',
                        );
                      },
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Live Chat Button (Teal - Secondary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.startLiveChat(
                          context: context,
                          productId: product?.product?.id ?? '',
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text("Live Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
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

    if (isAuction && !isAuctionExpired && (_isExpired == false)) {
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  /// Bid Amount Field
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: bidController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // 👈 only 0–9
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter your bid',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  /// Place Bid Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : placeBid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Place Bid',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
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
                              product?.product?.shop?.shop?.meta?.phone ?? '',
                          whatsapp:
                              product
                                  ?.product
                                  ?.shop
                                  ?.shop
                                  ?.meta
                                  ?.whatsappAreaCode,
                          whatsappCode:
                              product
                                  ?.product
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Call Button (Orange - Primary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.makeCall(
                          product?.product?.shop?.shop?.meta?.phone ?? '',
                        );
                      },
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text("Call"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Live Chat Button (Teal - Secondary)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CustomerService.startLiveChat(
                          context: context,
                          productId: product?.product?.id ?? '',
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text("Live Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
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

    // Check if buy now should be enabled (same conditions as add to cart)
    final bool isDealEnded =
        widget.product.isDeal == 1 &&
        widget.product.saleStartTime == null &&
        widget.product.saleEndTime == null &&
        !_isFlashDealActive;

    final bool canBuyNow = canPurchase && !isDealEnded;

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
            // Chat Button
            GestureDetector(
              onTap: () {
                showCustomerServiceDialog(
                  context,
                  product?.product?.shop?.shop?.meta?.phone ?? '',
                  product?.product?.id ?? '',
                  product?.product?.shop?.shop?.meta?.whatsappAreaCode,
                  product?.product?.shop?.shop?.meta?.whatsapp ?? '',
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Iconsax.message,
                  color: _textSecondary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Add to Cart Button
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isCartOperationInProgressNotifier,
                builder: (context, isLoading, child) {
                  return GestureDetector(
                    onTap:
                        isDealEnded
                            ? null
                            : canPurchase && !isLoading
                            ? () => _addToCart(product: product)
                            : null,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isDealEnded
                                ? Colors.grey.shade400
                                : canPurchase
                                ? _primaryColor
                                : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
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
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      buttonText == 'Add to Cart'
                                          ? 'Add to Cart'
                                          : buttonText,
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
                  );
                },
              ),
            ),
            // Buy Now Button - only show when canPurchase is true
            if (canPurchase) ...[
              const SizedBox(width: 4),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isCartOperationInProgressNotifier,
                  builder: (context, isLoading, child) {
                    return GestureDetector(
                      onTap:
                          canBuyNow && !isLoading
                              ? () => _openQuickBuySheet(product)
                              : null,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient:
                              canBuyNow
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFFfda730),
                                      Color(0xFFf59320),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                  : null,
                          color: canBuyNow ? null : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Buy Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR WIDGET
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _errorMessageNotifier,
              builder: (context, errorMessage, child) {
                return Text(
                  errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: _textSecondary),
                );
              },
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadProductData,
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
    );
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
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFFE66D), // Yellow
    const Color(0xFF95E1D3), // Mint
    const Color(0xFFF38181), // Coral
    const Color(0xFFAA96DA), // Purple
    const Color(0xFF00B4D8), // Cyan
    const Color(0xFFFF9F43), // Orange
    const Color(0xFF6BCB77), // Green
    const Color(0xFFE056FD), // Pink
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
        y: random.nextDouble() * -1, // Start above screen
        velocityX: (random.nextDouble() - 0.5) * 0.02,
        velocityY: random.nextDouble() * 0.015 + 0.005,
        rotation: random.nextDouble() * 360,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        size: random.nextDouble() * 10 + 6,
        shape: random.nextInt(3), // 0: square, 1: rectangle, 2: circle
      );
    });
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y += particle.velocityY;
      particle.x += particle.velocityX;
      particle.rotation += particle.rotationSpeed;

      // Add slight swaying motion
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
      // Calculate opacity (fade out near the end)
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
        case 0: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 1: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.5,
              height: particle.size * 0.6,
            ),
            paint,
          );
          break;
        case 2: // Circle
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

    // 1️⃣ Remove HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // 2️⃣ Decode HTML entities (&nbsp; &amp; etc)
    text = _unescape.convert(text);

    // 3️⃣ Fix non-breaking spaces
    text = text.replaceAll('\u00A0', ' ');

    // 4️⃣ Remove extra spaces
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
