import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/routes/app_pages.dart';

import '../../../core/widgets/appbar.dart';
import '../../../models/products/single_product_model.dart';
import 'catnavbar.dart';
import 'products_grid.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int selectedSizeIndex = 0;
  int selectedColorIndex = 0;
  int selectedImageIndex = 0;

  List<String> imageUrls = [
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png',
    'assets/images/shoes.png'
  ];
  List<int> sizes = [34, 43, 44, 55, 33, 23];
  List<Color> colorsSubp = [
    Colors.black,
    Colors.teal,
    Colors.purple,
    Colors.green
  ];

  CartService cartService = Get.find<CartService>();

  @override
  void initState() {
    super.initState();
    print('object323');
    cartService.initcall();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(),
          body: StreamBuilder<CartModel>(
            stream: cartService.cartStream,
            builder: (context, snapshot) {
              CartModel cart = snapshot.data ?? CartModel(cartItems: []);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryNavBar(),
                    SizedBox(height: 20),
                    CheckoutScreen(cart: cart),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Find Related Products!",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "View All",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD9183B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProductGrid(),
                    SizedBox(height: 50)
                  ],
                ),
              );
            },
          )),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.cart});
  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (cart.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  shrinkWrap: true,
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem cartItem = cart.cartItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildSellerSection(cartItem, cartItem.items.first),
                            Container(
                              height: 2,
                              color: Colors.grey.shade300,
                            ),
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: cartItem.items.length,
                                itemBuilder: (context, productIndex) {
                                  Item item = cartItem.items[productIndex];
                                  return _buildProductCard(item, cartItem);
                                })
                          ],
                        ),
                      ),
                    );
                  }),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Your Cart is empty",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildOrderSummary(),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure logistics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Package safety\n",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextSpan(
                        text: "Full refund for your damaged or lost package.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Delivery guaranteed\n",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextSpan(
                        text: "Accurate and precise order tracking.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Purchase protection",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Shop confidently on Temu knowing that if something goes wrong, we’ve always got your back.",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 16),
                Text(
                  "Customer service",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Our customer service team is always here if you need help.",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.question_answer,
                              color: Colors.green, size: 32),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "FAQ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(width: 32),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.chat, color: Colors.blue, size: 32),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Contact Us",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ],
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

  Widget _buildSellerSection(CartItem cart, Item product) {
    String getEstimatedDelivery() {
      final currentDate = DateTime.now();
      final shippingTimeFrom = int.tryParse(product.meta.shippingTimeFrom) ?? 0;
      final shippingTimeTo = int.tryParse(product.meta.shippingTimeTo) ?? 0;

      final earliestDelivery =
          currentDate.add(Duration(days: shippingTimeFrom));
      final latestDelivery = currentDate.add(Duration(days: shippingTimeTo));

      final dateFormat = DateFormat('MMM d'); // Format: March 1, 2025
      return 'Estd delivery : ${dateFormat.format(latestDelivery)}';
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 87,
                width: 87,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                      cart.shop.shop.thumbnail.media?.url ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                    return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Center(
                          child: Text(
                              cart.shop.shop.name.toString().substring(0, 1),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32)),
                        ));
                  }),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cart.shop.shop.name.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(cart.freeShippingNotice.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(getEstimatedDelivery())
        ],
      ),
    );
  }

  Widget _buildProductCard(Item product, CartItem cart) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              product.thumbnail.media?.url ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.product.name.toString(),
                    style: defaultTextStyle.copyWith(
                        fontWeight: FontWeight.w400, fontSize: 14)),
                SizedBox(height: 10),
                product.originalPrice != null
                    ? Row(
                        children: [
                          Text('\$${product.originalPrice.toString()}',
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(width: 30),
                          Text(
                              '\$${(product.displayDiscountedPrice ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      )
                    : Row(
                        children: [
                          Text('\$${cart.shopTotal.toString()}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        children: [
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade200),
                            height: 25,
                            width: 25,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.remove, size: 10),
                                onPressed: () async {
                                  CartService cartService =
                                      Get.find<CartService>();

                                  await cartService
                                      .updatecar(
                                          product.id, product.quantity - 1)
                                      .then((val) {});
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(product.quantity.toString(),
                              style: TextStyle(fontSize: 16)),
                          SizedBox(width: 10),
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade200),
                            height: 25,
                            width: 25,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.add, size: 10),
                                onPressed: () async {
                                  CartService cartService =
                                      Get.find<CartService>();

                                  await cartService
                                      .updateCart(
                                          product.product.shopId ?? '',
                                          product.product.id ?? '',
                                          1,
                                          double.tryParse(product.product.price
                                                  .toString()) ??
                                              0.0)
                                      .then((val) {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey),
                      onPressed: () async {
                        CartService cartService = Get.find<CartService>();

                        await cartService.deleteCart(product.id).then((val) {});
                      },
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

  Widget _buildOrderSummary() {
    return Container(
      height: 250,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            "Order Summary",
            style: defaultTextStyle.copyWith(
                fontWeight: FontWeight.w500, fontSize: 14),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tijara Voucher',
                  style: defaultTextStyle.copyWith(
                      fontWeight: FontWeight.w500, fontSize: 14)),
              Text('No Applicable Voucher',
                  style: defaultTextStyle.copyWith(
                      fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (2 Items)',
                style: defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                '\$1,029',
                style: defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Get.toNamed(Routes.CHECKOUT);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Proceed to checkout',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
