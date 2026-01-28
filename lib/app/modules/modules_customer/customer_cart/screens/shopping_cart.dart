// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/other_product_grid.dart';
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
  bool selectAll = true;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
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
            final itemCount = snapshot.data?.cartItems.length ?? 0;
            return Text(
              textAlign: TextAlign.center,
              itemCount > 0 ? 'Shopping Cart ($itemCount)' : 'Shopping Cart',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // ✨ Subtle gradient background (top portion only)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFfea52d),
                    const Color(0xFFfea52d).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              Expanded(
                child: StreamBuilder<CartModel>(
                  stream: cartService.cartStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cart = snapshot.data!;
                    final hasItems = cart.cartItems.isNotEmpty;

                    return Stack(
                      children: [
                        CustomScrollView(
                          slivers: [
                            // Free Shipping Banner
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),

                            // Cart Content
                            if (hasItems)
                              SliverToBoxAdapter(
                                child: _CartContent(
                                  cart: cart,
                                  selectAll: selectAll,
                                ),
                              )
                            else
                              SliverToBoxAdapter(
                                child: _EmptyCartState(
                                  isUserLoggedIn: isUserLoggedIn,
                                ),
                              ),

                            // Trust Badges
                            SliverToBoxAdapter(child: _TrustBadges()),

                            // Recommended Products
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                                child: Text(
                                  "Recommended for You",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: ProductsGridWidget(
                                shownfromcatehoris: false,
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: SizedBox(height: hasItems ? 120 : 20),
                            ),
                          ],
                        ),

                        // Bottom Checkout Button
                        if (hasItems)
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Enhanced Free Shipping Banner
// ========================================
class _FreeShippingBanner extends StatelessWidget {
  final bool hasItems;

  const _FreeShippingBanner({required this.hasItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0a8700).withOpacity(0.12),
            const Color(0xFF0a8700).withOpacity(0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFF0a8700).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0a8700).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF0a8700),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free Shipping & Returns',
                  style: TextStyle(
                    color: Color(0xFF0a8700),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasItems)
                  Text(
                    'Limited-time offer',
                    style: TextStyle(
                      color: const Color(0xFF0a8700).withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF0a8700), size: 20),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Premium Empty Cart State
// ========================================
class _EmptyCartState extends StatelessWidget {
  final bool isUserLoggedIn;

  const _EmptyCartState({required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          // Gradient circle with icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFfea52d).withOpacity(0.2),
                  const Color(0xFFf97316).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFfea52d).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 50,
                  color: Color(0xFFfea52d),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // Buttons
          if (!isUserLoggedIn) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showContactDialog(Get.context!, const LoginUi());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfda730),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFFfda730).withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 8),
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
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFfda730), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFfda730),
                    size: 20,
                  ),
                  SizedBox(width: 8),
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
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartModel cart;
  final bool selectAll;

  const _CartContent({required this.cart, required this.selectAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cart Items with white card background
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.cartItems.length,
            separatorBuilder:
                (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final cartItem = cart.cartItems[index];
              return Column(
                children:
                    cartItem.items.map((item) {
                      return _ProductCard(item: item, cartItem: cartItem);
                    }).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        _InfoMessages(),

        const SizedBox(height: 16),

        _OrderSummary(cart: cart),
      ],
    );
  }
}

// ========================================
// ✨ Enhanced Product Card
// ========================================
class _ProductCard extends StatefulWidget {
  final Item item;
  final CartItem cartItem;

  const _ProductCard({required this.item, required this.cartItem});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool isSelected = true;

  Future<void> _updateQuantity(int newQuantity) async {
    final cartService = Get.find<CartService>();
    await cartService.updatecar(widget.item.id, newQuantity, context);
  }

  Future<void> _removeFromCart() async {
    final cartService = Get.find<CartService>();
    await cartService.deleteCart(widget.item.id, context);
  }

  void _navigateToProduct() {
    Get.to(
      () => ProductDetailByIdScreen(productId: widget.item.productId),
      preventDuplicates: false,
    );
  }

  void _showQuantityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _QuantityBottomSheet(
            currentQuantity: widget.item.quantity,
            maxQuantity: 10,
            onQuantitySelected: (quantity) {
              _updateQuantity(quantity);
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.item.displayDiscountedPrice != null;

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  isSelected = value ?? false;
                });
              },
              activeColor: const Color(0xFFfda730),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Product Image with enhanced design
          GestureDetector(
            onTap: _navigateToProduct,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl:
                          widget.item.thumbnail.media?.optimizedMediaUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                            ),
                          ),
                    ),
                  ),
                ),
                // Stock badge
                if (widget.item.quantity <= 3)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFE85D30)],
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.item.quantity} LEFT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.getSizeName(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _removeFromCart,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Big Sale badge
                if (hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Big Sale',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Price and quantity
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '\$${(widget.item.price ?? 0).toStringAsFixed(0)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '\$${(widget.item.displayDiscountedPrice ?? widget.item.price ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Quantity selector
                    GestureDetector(
                      onTap: _showQuantityBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qty: ${widget.item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
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
}

// ========================================
// ✨ Quantity Bottom Sheet (Unchanged but themed)
// ========================================
class _QuantityBottomSheet extends StatelessWidget {
  final int currentQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantitySelected;

  const _QuantityBottomSheet({
    required this.currentQuantity,
    required this.maxQuantity,
    required this.onQuantitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Select quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDADADA), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFDADADA),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter quantity',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBDBDBD),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        final qty = int.tryParse(value);
                        if (qty != null && qty >= 0 && qty <= maxQuantity) {
                          onQuantitySelected(qty);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: maxQuantity + 1,
                separatorBuilder:
                    (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                itemBuilder: (context, index) {
                  final isSelected = index == currentQuantity;

                  return InkWell(
                    onTap: () => onQuantitySelected(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            index == 0 ? '0 (Delete)' : index.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              size: 22,
                              color: Color(0xFFfda730),
                            ),
                        ],
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
}

// ========================================
// ✨ Info Messages (Enhanced)
// ========================================
class _InfoMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoCard(
            icon: Icons.info_outline,
            message: 'Availability and pricing confirmed at checkout.',
            iconColor: Colors.blue.shade400,
            bgColor: Colors.blue.shade50,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showContactDialog(Get.context!, const LoginUi()),
            child: _InfoCard(
              icon: Icons.person_outline,
              message: "Can't find your items? Sign in to check your cart",
              iconColor: const Color(0xFFfda730),
              bgColor: const Color(0xFFfda730).withOpacity(0.1),
              hasAction: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;
  final Color bgColor;
  final bool hasAction;

  const _InfoCard({
    required this.icon,
    required this.message,
    required this.iconColor,
    required this.bgColor,
    this.hasAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          if (hasAction) Icon(Icons.chevron_right, size: 18, color: iconColor),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Order Summary (Enhanced)
// ========================================
class _OrderSummary extends StatelessWidget {
  final CartModel cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final itemTotal = cart.cartTotal ?? 0;
    final discount = cart.totalDiscounts ?? 0;
    final total = cart.grandTotal ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Item total:',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              Text(
                '\$${itemTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  decoration: discount > 0 ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),

          if (discount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_offer, size: 16, color: Color(0xFFFF6B35)),
                    SizedBox(width: 6),
                    Text(
                      'Discount:',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
                Text(
                  '-\$${discount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Final amount confirmed at checkout',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
// ✨ Trust Badges (Enhanced)
// ========================================
class _TrustBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why shop with us?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TrustBadge(icon: Icons.verified_user, label: 'Safe\nPayment'),
              _TrustBadge(icon: Icons.lock_outline, label: 'Secure\nPrivacy'),
              _TrustBadge(
                icon: Icons.shield_outlined,
                label: 'Purchase\nProtection',
              ),
              _TrustBadge(
                icon: Icons.local_shipping_outlined,
                label: 'Delivery\nGuarantee',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFfea52d), Color(0xFFf97316)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFfea52d).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ========================================
// ✨ Bottom Checkout Bar (Enhanced)
// ========================================
class _BottomCheckoutBar extends StatelessWidget {
  final CartModel cart;

  const _BottomCheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final total = cart.grandTotal ?? 0;
    final originalTotal = cart.cartTotal ?? 0;
    final discount = cart.totalDiscounts ?? 0;
    final discountPercent =
        originalTotal > 0
            ? ((discount / originalTotal) * 100).toStringAsFixed(0)
            : '0';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (discount > 0)
                    Text(
                      '\$${originalTotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        '\$${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.toNamed(Routes.CHECKOUT),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfda730),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout (${cart.cartItems.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
