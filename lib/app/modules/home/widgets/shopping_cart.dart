import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/routes/app_pages.dart';

import '../../../core/widgets/appbar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryNavBar(),
            SizedBox(height: 50),
            CheckoutScreen(),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Find Related Products!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [],
              ),
              child: Column(
                children: [
                  _buildSellerSection(),
                  Container(
                    height: 2,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 10),
                  _buildProductCard(),
                  Divider(color: Colors.grey.shade400),
                  _buildProductCard(),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildSellerSection() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Container(
            height: 87,
            width: 87,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/sktech.png',
                fit: BoxFit
                    .cover, // Ensures the image fills the circular area properly
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stylish Collection Wholesellers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("You've got free shipping with specific products!",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
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
            child: Image.asset(
              'assets/images/shoes.png',
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
                Text(
                    'hand bag for girls crossbody & shoulder handbag for women new design handbags',
                    style: defaultTextStyle.copyWith(
                        fontWeight: FontWeight.w400, fontSize: 14)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('\$78',
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
                                onPressed: () {},
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('1', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 10),
                          Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade200),
                            height: 25,
                            width: 25,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.add, size: 10),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                )
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
