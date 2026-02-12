// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/modules/authentication_module/screens/contact_us.dart';
import 'package:tjara/app/modules/authentication_module/screens/login.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/product_detail_by_id.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late final CartService cartService;

  @override
  void initState() {
    super.initState();
    cartService = Get.find<CartService>();
    cartService.initcall();
  }

  @override
  Widget build(BuildContext context) {
    final isUserLoggedIn = AuthService.instance.authCustomer != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFfda730),
        actions: [
          if (!isUserLoggedIn)
            TextButton.icon(
              onPressed: () {
                showContactDialog(Get.context!, const LoginUi());
              },
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Sign in',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
        title: StreamBuilder<CartModel>(
          stream: cartService.cartStream,
          builder: (context, snapshot) {
            return const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tjara Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<CartModel>(
        stream: cartService.cartStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFfda730)),
            );
          }

          final cart = snapshot.data!;
          final hasItems = cart.cartItems.isNotEmpty;

          if (!hasItems) {
            return _EmptyCartState(isUserLoggedIn: isUserLoggedIn);
          }

          return Stack(
            children: [
              // Gradient background at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFfda730).withValues(alpha: 0.12),
                        Colors.grey.shade100,
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Shop grouped items
                    ...cart.cartItems.map(
                      (cartItem) => _ShopSection(
                        cartItem: cartItem,
                        cartService: cartService,
                      ),
                    ),

                    // Reseller Levels Section
                    // if (cart.resellerTiers.isNotEmpty)
                    _ResellerLevelsSection(cart: cart),

                    // Order Summaries per Shop
                    _OrderSummariesSection(cart: cart),

                    // Notices Section
                    _NoticesSection(cart: cart),

                    // Safe Payment Options
                    const _SafePaymentSection(),

                    const SizedBox(height: 20),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 12, left: 12),
                            child: Text(
                              'You May Also Like',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          RelatedProductGrid(search: ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Checkout Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomCheckoutBar(cart: cart),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getTotalItemCount(CartModel? cart) {
    if (cart == null) return 0;
    int count = 0;
    for (var cartItem in cart.cartItems) {
      for (var item in cartItem.items) {
        count += item.quantity;
      }
    }
    return count;
  }
}

// ========================================
// Shop Section - Groups items by shop
// ========================================
class _ShopSection extends StatelessWidget {
  final CartItem cartItem;
  final CartService cartService;

  const _ShopSection({required this.cartItem, required this.cartService});

  @override
  Widget build(BuildContext context) {
    final shop = cartItem.shop.shop;
    final hasDiscount = cartItem.shopDiscount > 0;
    final hasBonus = cartItem.shopBonus > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFFfda730).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient accent bar at top
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFfda730), Color(0xFFf59e0b)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Shop Header
            _ShopHeader(
              shop: shop,
              freeShippingNotice: cartItem.freeShippingNotice,
              estimatedDelivery: cartItem.getEstimatedDelivery(),
              freeShipping: cartItem.freeShipping,
            ),

            const Divider(height: 1),

            // Products List
            ...cartItem.items.map(
              (item) => _ProductCard(
                item: item,
                cartItem: cartItem,
                cartService: cartService,
              ),
            ),

            const Divider(height: 1),

            // Shop Summary
            _ShopSummary(
              shopTotal: cartItem.shopTotal,
              shopDiscount: cartItem.shopDiscount,
              shopBonus: cartItem.shopBonus,
              hasDiscount: hasDiscount,
              hasBonus: hasBonus,
              discountBreakdown: cartItem.discountBreakdown,
              shopFinalTotal: cartItem.shopFinalTotal,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Shop Header
// ========================================
class _ShopHeader extends StatelessWidget {
  final ShopDetails shop;
  final String freeShippingNotice;
  final String estimatedDelivery;
  final bool freeShipping;

  const _ShopHeader({
    required this.shop,
    required this.freeShippingNotice,
    required this.estimatedDelivery,
    required this.freeShipping,
  });

  @override
  Widget build(BuildContext context) {
    final hasShopImage = shop.thumbnail.media?.optimizedMediaUrl != null;
    final firstLetter = shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Shop Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasShopImage ? null : const Color(0xFFfda730),
              shape: BoxShape.circle,
            ),
            child:
                hasShopImage
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: shop.thumbnail.media!.optimizedMediaUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                _buildAvatarPlaceholder(firstLetter),
                        errorWidget:
                            (context, url, error) =>
                                _buildAvatarPlaceholder(firstLetter),
                      ),
                    )
                    : Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ),
          const SizedBox(width: 12),

          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (freeShippingNotice.isNotEmpty)
                  Text(
                    freeShippingNotice,
                    style: TextStyle(
                      fontSize: 12,
                      color: freeShipping ? Colors.green : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // Estimated Delivery
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Est. Delivery :',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                estimatedDelivery,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String letter) {
    return Container(
      color: const Color(0xFFfda730),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Product Card with +/- Controls
// ========================================
class _ProductCard extends StatelessWidget {
  final Item item;
  final CartItem cartItem;
  final CartService cartService;

  const _ProductCard({
    required this.item,
    required this.cartItem,
    required this.cartService,
  });

  void _navigateToProduct() {
    Get.to(
      () => ProductDetailByIdScreen(productId: item.productId),
      preventDuplicates: false,
    );
  }

  Future<void> _updateQuantity(int newQuantity, BuildContext context) async {
    if (newQuantity <= 0) {
      await cartService.deleteCart(item.id, context);
    } else {
      await cartService.updatecar(item.id, newQuantity, context);
    }
  }

  Future<void> _removeFromCart(BuildContext context) async {
    await cartService.deleteCart(item.id, context);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.getDisplayThumbnailUrl() ?? '';
    final hasDiscount = item.hasDiscount;
    final effectivePrice = item.getEffectivePrice();
    final originalPrice = item.price;
    final attributes = item.getAttributeDisplayStrings();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          GestureDetector(
            onTap: _navigateToProduct,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                GestureDetector(
                  onTap: _navigateToProduct,
                  child: Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Attributes (Colors, Sizes, etc.)
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...attributes.map(
                    (attr) => Text(
                      attr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Price Row
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            hasDiscount
                                ? const Color(0xFFfda730)
                                : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => _updateQuantity(item.quantity - 1, context),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => _updateQuantity(item.quantity + 1, context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button

                  // Delete Button
                  IconButton(
                    onPressed: () => _removeFromCart(context),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

// ========================================
// Shop Summary
// ========================================
class _ShopSummary extends StatelessWidget {
  final double shopTotal;
  final double shopDiscount;
  final double shopBonus;
  final bool hasDiscount;
  final bool hasBonus;
  final List<DiscountBreakdown> discountBreakdown;
  final double shopFinalTotal;

  const _ShopSummary({
    required this.shopTotal,
    required this.shopDiscount,
    required this.shopBonus,
    required this.hasDiscount,
    required this.hasBonus,
    required this.discountBreakdown,
    required this.shopFinalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Shop Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Subtotal',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                '\$${shopTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Discount Breakdown
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            ...discountBreakdown.map(
              (discount) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_box,
                          size: 16,
                          color: Color(0xFFfda730),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${discount.name} (${discount.percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFfda730),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-\$${discount.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFfda730),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Bonus Amount
          if (hasBonus) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Colors.teal),
                    SizedBox(width: 4),
                    Text(
                      'Bonus Amount',
                      style: TextStyle(fontSize: 13, color: Colors.teal),
                    ),
                  ],
                ),
                Text(
                  '+\$${shopBonus.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Shop Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${shopFinalTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========================================
// Reseller Levels Section
// ========================================
class _ResellerLevelsSection extends StatelessWidget {
  final CartModel cart;

  const _ResellerLevelsSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    // Get global reseller tiers from cart API
    final resellerTiers = cart.resellerTiers;
    if (resellerTiers.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get current tier and next tier from API
    final currentTier = cart.currentTier;
    final nextTierInfo = cart.nextTier;

    // Get current tier data
    final currentTierData = resellerTiers.firstWhere(
      (t) => t.tier == currentTier,
      orElse: () => resellerTiers.first,
    );

    // Use progress value directly from API (e.g., 27.7 means 27.7%)
    final double progress = nextTierInfo?.progress ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Level Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Level : $currentTier',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentTierData.discountRate.toStringAsFixed(0)}% discount + \$${currentTierData.bonusAmount.toStringAsFixed(0)} bonus',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (nextTierInfo != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Next Level Benefits:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${nextTierInfo.discountRate.toStringAsFixed(0)}% discount + \$${nextTierInfo.bonusAmount.toStringAsFixed(0)} bonus',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFfda730),
                ),
                minHeight: 8,
              ),
            ),
          ),

          // Next Level Message
          if (nextTierInfo != null && nextTierInfo.message.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nextTierInfo.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Reseller Levels Grid
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Reseller Levels & Benefits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Available discounts and bonuses for each level',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 12),

          // Levels Grid - 3 columns like web
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: resellerTiers.length,
              itemBuilder: (context, index) {
                final tier = resellerTiers[index];
                final isCurrentTier = currentTier == tier.tier;
                return _ResellerLevelCard(
                  tier: tier,
                  isCurrentTier: isCurrentTier,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ResellerLevelCard extends StatelessWidget {
  final ResellerTier tier;
  final bool isCurrentTier;

  const _ResellerLevelCard({required this.tier, required this.isCurrentTier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            isCurrentTier
                ? const Color(0xFFfda730).withValues(alpha: 0.05)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentTier ? const Color(0xFFfda730) : Colors.grey.shade200,
          width: isCurrentTier ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level ${tier.tier}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCurrentTier ? const Color(0xFFfda730) : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Minimum Purchase',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '\$${tier.minPurchase.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discount Rate',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '${tier.discountRate.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bonus Amount',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '\$${tier.bonusAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFfda730),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Order Summaries Section
// ========================================
class _OrderSummariesSection extends StatelessWidget {
  final CartModel cart;

  const _OrderSummariesSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children:
            cart.cartItems
                .map((cartItem) => _OrderSummaryCard(cartItem: cartItem))
                .toList(),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartItem cartItem;

  const _OrderSummaryCard({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final shop = cartItem.shop.shop;
    final hasDiscount = cartItem.shopDiscount > 0;
    final hasBonus = cartItem.shopBonus > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Name
          Center(
            child: Text(
              shop.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Sub-total
          _SummaryRow(
            label: 'Sub-total',
            value: '\$${cartItem.shopTotal.toStringAsFixed(2)}',
          ),

          // Delivery Fee
          _SummaryRow(
            label: 'Delivery Fee',
            value:
                cartItem.freeShipping
                    ? 'Free'
                    : '\$${cartItem.maxShippingFee.toStringAsFixed(2)}',
            valueColor: cartItem.freeShipping ? Colors.green : null,
          ),

          // Reseller Discount
          if (hasDiscount)
            ...cartItem.discountBreakdown.map(
              (discount) => _SummaryRow(
                label:
                    '${discount.name} (${discount.percentage.toStringAsFixed(0)}%)',
                value: '- \$${discount.amount.toStringAsFixed(2)}',
                valueColor: const Color(0xFFfda730),
              ),
            ),

          const Divider(height: 20),

          // Total
          _SummaryRow(
            label: 'Total',
            value: '\$${cartItem.shopGrandTotal.toStringAsFixed(2)}',
            isBold: true,
          ),

          // Bonus Message
          if (hasBonus) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('🎁 ', style: TextStyle(fontSize: 14)),
                Text(
                  'Bonus: \$${cartItem.shopBonus.toStringAsFixed(0)} (Gets Added to your wallet after checkout)',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Notices Section
// ========================================
class _NoticesSection extends StatelessWidget {
  final CartModel cart;

  const _NoticesSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final notices = <String>[];

    // Collect discount messages
    if (cart.discountMessages != null) {
      for (var msg in cart.discountMessages!) {
        if (msg != null && msg.isNotEmpty) {
          notices.add(msg);
        }
      }
    }

    // Add tier messages from cart items
    for (var cartItem in cart.cartItems) {
      if (cartItem.nextTierMessageCheckout != null) {
        notices.add(cartItem.nextTierMessageCheckout!);
      }
    }

    if (notices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notices',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFfda730),
            ),
          ),
          const SizedBox(height: 8),
          ...notices.map(
            (notice) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Safe Payment Section
// ========================================
class _SafePaymentSection extends StatelessWidget {
  const _SafePaymentSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFfda730).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFFfda730),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Safe Payment Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tjara is committed to protecting your payment information. We follow PCI DSS standards, use strong encryption, and perform regular reviews of its system to protect your privacy.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Payment methods',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PaymentIcon(icon: Icons.credit_card, label: 'Card'),
              _PaymentIcon(icon: Icons.account_balance_wallet, label: 'Wallet'),
              _PaymentIcon(icon: Icons.payment, label: 'PayPal'),
              _PaymentIcon(icon: Icons.credit_card, label: 'Visa'),
              _PaymentIcon(icon: Icons.credit_card, label: 'MasterCard'),
              _PaymentIcon(icon: Icons.apple, label: 'Apple Pay'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaymentIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 24, color: const Color(0xFFfda730)),
    );
  }
}

// ========================================
// Bottom Checkout Bar
// ========================================
class _BottomCheckoutBar extends StatelessWidget {
  final CartModel cart;

  const _BottomCheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: const Color(0xFFfda730).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFfda730), Color(0xFFf59e0b)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFfda730).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.toNamed(Routes.CHECKOUT),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// Empty Cart State
// ========================================
class _EmptyCartState extends StatelessWidget {
  final bool isUserLoggedIn;

  const _EmptyCartState({required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFfda730).withValues(alpha: 0.15),
            Colors.grey.shade50,
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated cart icon with gradient background
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFfda730).withValues(alpha: 0.2),
                      const Color(0xFFfda730).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfda730).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 70,
                  color: Color(0xFFfda730),
                ),
              ),
              const SizedBox(height: 32),

              // Main card with content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFFfda730).withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isUserLoggedIn
                          ? 'Discover amazing products and add them to your cart!'
                          : 'Sign in to sync your cart or start shopping now!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!isUserLoggedIn) ...[
                      // Sign in button with gradient
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfda730), Color(0xFFf59e0b)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFfda730,
                              ).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            showContactDialog(Get.context!, const LoginUi());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Sign in / Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Start Shopping button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFfda730),
                          width: 2,
                        ),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          DashboardController.instance.reset();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 22,
                              color: Color(0xFFfda730),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Start Shopping',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFfda730),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Additional info section for non-logged in users
              if (!isUserLoggedIn) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFfda730).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFFfda730),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Why sign in?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sync your cart across devices and get exclusive offers!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
