// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/dialogs/payment_security.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/models/wishlists/wishlist_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/home/widgets/attributes.dart';
import 'package:tjara/app/modules/home/widgets/image_slider.dart';
import 'package:tjara/app/modules/home/widgets/product_detail.dart';
import 'package:tjara/app/modules/home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/home/widgets/shopping_cart.dart';
import 'package:tjara/app/modules/wishlist/controllers/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';

class ProductDetailByIdScreen extends StatefulWidget {
  const ProductDetailByIdScreen({super.key, required this.productId});
  final String productId;

  @override
  State<ProductDetailByIdScreen> createState() =>
      _ProductDetailByIdScreenState();
}

class _ProductDetailByIdScreenState extends State<ProductDetailByIdScreen> {
  // Controllers
  final PageController _pageController = PageController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  // Services and controllers
  late final CartService _cartService = Get.find<CartService>();
  late final HomeController _homeController = Get.put(HomeController());
  late final WishlistServiceController _wishlistController = Get.put(
    WishlistServiceController(),
  );

  // State variables
  SingleModelClass? _product;
  bool _isLoading = true;
  String? _errorMessage;
  late List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final product = await _homeController.fetchSingleProducts(
        widget.productId,
      );

      if (product == null) {
        throw Exception('Product not found');
      }

      setState(() {
        _product = product;
        _imageUrls = [
          product.product?.thumbnail?.media?.localUrl ?? '',
          ...(product.product?.gallery ?? [])
              .map((e) => e.media?.localUrl ?? '')
              .where((url) => url.isNotEmpty),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading product: $e');
    }
  }

  Future<void> _addToCart() async {
    if (_product?.product == null) return;

    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    final int quantity = int.tryParse(_quantityController.text) ?? 1;
    final double price =
        double.tryParse(_product!.product!.price.toString()) ?? 0.0;

    final result = await _cartService.updateCart(
      _product!.product!.shopId ?? '',
      _product!.product!.id ?? '',
      quantity,
      price,
    );

    _handleCartUpdateResult(result);
  }

  void _handleCartUpdateResult(dynamic result) {
    if (result is String) {
      NotificationHelper.showError(context, 'Failed', result);
    } else if (result is bool && result) {
      NotificationHelper.showSuccess(
        context,
        'Success',
        'Product Added to Cart',
      );
      _cartService.initcall();
      Get.to(() => const ShoppingCartScreen())?.then((_) {
        if (context.mounted) {
          setState(() {});
        }
      });
    } else {
      NotificationHelper.showError(
        context,
        'Failed',
        'Product Failed to add to cart',
      );
    }
  }

  void _toggleWishlist(WishlistItem? wishlistItem) {
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    if (wishlistItem != null) {
      _wishlistController.removeFromWishlist(
        wishlistItem.id.toString(),
        context,
      );
    } else {
      _wishlistController.addToWishlist(widget.productId, context);
    }
    if (context.mounted) {
      setState(() {});
    }
  }

  void _showLoginDialog() {
    showContactDialog(context, const LoginUi());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _product == null
                ? const Center(child: Text('Product not found'))
                : _buildProductDetail(),
      ),
    );
  }

  Widget _buildProductDetail() {
    final product = _product!;

    return ListView(
      children: [
        _buildImageSlider(product),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildProductHeader(product),
              _buildRatingStars(),
              const SizedBox(height: 5),
              if (product.product?.variation == null)
                Row(
                  children: [
                    if (product.product?.salePrice != null &&
                        product.product!.salePrice != 0 &&
                        product.product!.salePrice != 0.00)
                      Row(
                        children: [
                          Text(
                            "\$${(product.product!.price ?? product.product!.maxPrice ?? 0).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "\$${(product.product!.salePrice ?? 0).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    else
                      Builder(
                        builder: (context) {
                          if (product.product!.minPrice != null &&
                              product.product!.maxPrice != null &&
                              product.product!.minPrice != 0 &&
                              product.product!.maxPrice != 0) {
                            return Text(
                              "\$${product.product!.minPrice!.toStringAsFixed(2)} - \$${product.product!.maxPrice!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            );
                          } else if (product.product!.price != 0.0) {
                            return Text(
                              "\$${product.product!.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            );
                          }

                          return const Text(
                            "Ask the dealer",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              _buildProductVariation(product),
              _buildQuantitySelector(product),
              const SizedBox(height: 20),
              _buildAddToCartButton(product),
              const SizedBox(height: 10),
              _buildWishlistButton(),
              const SizedBox(height: 10),
              _buildEnquireButton(product),
              const SizedBox(height: 30),
              ProductDetailsSection(product: product.product!),
              _buildRelatedProductsHeader(),
            ],
          ),
        ),
        RelatedProductGrid(
          search:
              product.product?.categories?.productAttributeItems.first.id ?? '',
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildImageSlider(SingleModelClass product) {
    return Column(
      children: [
        ImageSlider(
          key: ValueKey('imageSlider_${product.product?.video?.media?.url}'),
          videoUrl: product.product?.video?.media?.localUrl,
          imageUrls: _imageUrls,
          controller: _pageController,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildProductHeader(SingleModelClass product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID:${product.product?.meta?.productId ?? ''}',
          style: defaultTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          product.product?.name.toString() ?? '',
          style: defaultTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Image.asset('assets/images/star.png', height: 14),
        ),
      ),
    );
  }

  Widget _buildProductVariation(SingleModelClass product) {
    if (product.product?.variation == null) return const SizedBox();

    return ProductVariationDisplay(
      variation: product.product!.variation!,
      onAttributesSelected: (attributesData, variationId) {
        // variationId is the ID of the entire selected variation
        if (variationId == null) return;

        // Now you can directly use the variationId
        selectedVariationId = variationId;

        // To get the price, you would use the matching variation
        // The price should come from the variation that matches all selected attributes
        // You could either get it from the attributes data or let ProductVariationDisplay
        // pass the entire matching variation object

        // For now, if you need the price from attributes data:
        // Just take the price from any of the attributes (they all have the same price for the matching variation)
        if (attributesData.isNotEmpty) {
          final String firstKey = attributesData.keys.first;
          if (attributesData[firstKey]?["price"] != null) {
            selectedVariationPrice =
                attributesData[firstKey]!["price"].toString();
          }
        }
      },
    );
  }

  String? selectedVariationPrice;
  String? selectedVariationId;

  Widget _buildQuantitySelector(SingleModelClass product) {
    return Row(
      children: [
        if (product.product?.productGroup != 'car')
          Text(
            "Quantity:",
            style: defaultTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        const SizedBox(width: 10),
        if (product.product?.productGroup != 'car')
          Container(
            width: 67,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: const Color(0xffF7F7F7),
              border: Border.all(color: const Color(0xffDCDCDC)),
            ),
            child: TextField(
              autofocus: false,
              controller: _quantityController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 20, bottom: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        const Spacer(),
        const SizedBox(width: 10),
        Text(
          "${product.product?.stock ?? 0} Item Available",
          style: defaultTextStyle.copyWith(fontSize: 14, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(SingleModelClass product) {
    if (product.product?.productGroup == 'car') {
      if (product.product?.stock == 0) {
        return _buildCartButton(false);
      } else {
        return FutureBuilder<bool>(
          future: CartService.instance.isProductInCart(
            product.product?.id ?? '',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final bool isInCart = snapshot.data ?? false;
            return _buildCartButton(!isInCart);
          },
        );
      }
    } else {
      final bool canPurchase = product.product?.stock != 0;
      return _buildCartButton(canPurchase);
    }
  }

  Widget _buildCartButton(bool canPurchase) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canPurchase ? const Color(0xFF0D9488) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: canPurchase ? _addToCart : null,
        child: Text(
          "Add To Cart",
          style: defaultTextStyle.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWishlistButton() {
    return Obx(() {
      final wishlistItems = _wishlistController.wishlistResponse.wishlistItems;
      final WishlistItem? wishlistItem =
          wishlistItems
              ?.where((e) => e.productId == widget.productId)
              .firstOrNull;
      final bool isInWishlist = wishlistItem != null;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isInWishlist ? Colors.transparent : const Color(0xFF0D9488),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isInWishlist ? Colors.red : const Color(0xFF0D9488),
                width: 1.5,
              ),
            ),
            elevation: 0,
          ),
          onPressed: () => _toggleWishlist(wishlistItem),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isInWishlist ? 'Remove from wishlist' : "Add To Wishlist",
                style: defaultTextStyle.copyWith(
                  color: isInWishlist ? Colors.red : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.favorite,
                color: isInWishlist ? Colors.red : Colors.white,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEnquireButton(SingleModelClass product) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF0D9488)),
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed:
            () => showCustomerServiceDialog(
              context,
              product.product?.shop?.shop?.meta?.phone ?? '',
              product.product?.id ?? '',
              product.product?.shop?.shop?.meta?.whatsappAreaCode,
              product.product?.shop?.shop?.meta?.whatsapp ?? '',
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enquire Now",
              style: defaultTextStyle.copyWith(color: const Color(0xFF0D9488)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.support_agent, color: Color(0xFF0D9488)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProductsHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Related Products",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ProductDetailsSection extends StatelessWidget {
  const ProductDetailsSection({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Shipping",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Shipping Fees: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "Free on all orders",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff0D9488),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text.rich(
                          TextSpan(
                            text: "Delivery: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "4-8 Business days",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff0D9488),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            showContactDialog(
              context,
              PaymentOptionsDialog(shown: true, onPaymentMethodTap: (a) {}),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              const Text(
                "Shopping security",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Security features grid
              _buildSecurityFeature("Safe Payment Options", Icons.payment),
              _buildSecurityFeature("Secure privacy", Icons.privacy_tip),

              // Right column
              _buildSecurityFeature("Secure logistics", Icons.local_shipping),
              _buildSecurityFeature("Purchase protection", Icons.shield),
            ],
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Get.toNamed(
              Routes.STORE_PAGE,
              arguments: {
                'shopid': product.shop?.shop?.id ?? '',
                'ShopShop': product.shop?.shop,
              },
            );
            // Get.toNamed(Routes.STORE_PAGE);
          },
          child: Container(
            height: 157,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration:
                      (() {
                        final thumbUrl =
                            product.shop?.shop?.thumbnail?.media?.localUrl;
                        return BoxDecoration(
                          color:
                              thumbUrl == null
                                  ? const Color(0xff0D9488)
                                  : Colors.transparent,
                          image:
                              thumbUrl == null
                                  ? null
                                  : DecorationImage(
                                    image: NetworkImage(thumbUrl),
                                  ),
                          shape: BoxShape.circle,
                        );
                      })(),
                  child: Center(
                    child: Text(
                      (product.shop?.shop?.name ??
                          'Shop Name not found '.toString())[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
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
                        product.shop?.shop?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.shop?.shop?.description ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Text(
                        "Seller's other items",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Contact seller",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        TabbedContainer(product: product),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSecurityFeature(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff0D9488), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff0D9488),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14),
          ],
        ),
      ),
    );
  }
}

class TabbedContainer extends StatefulWidget {
  final Product product;

  const TabbedContainer({super.key, required this.product});
  @override
  _TabbedContainerState createState() => _TabbedContainerState();
}

class _TabbedContainerState extends State<TabbedContainer> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffF9F9F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [_buildTab("Customer Reviews (0)", 1)]),
          ),
          Container(height: 2, color: Colors.grey.shade300),
          Padding(padding: const EdgeInsets.all(12.0), child: _reviewsWidget()),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (context.mounted) {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border:
                isSelected
                    ? const Border(
                      bottom: BorderSide(color: Colors.red, width: 3),
                    )
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewsWidget() {
    return const Text(
      "No customer reviews yet.",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    );
  }
}
