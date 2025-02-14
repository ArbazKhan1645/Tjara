import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/routes/app_pages.dart';

import '../../../core/widgets/appbar.dart';
import '../../../models/products/products_model.dart';
import 'products_grid.dart';
import 'shopping_cart.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Datum product; // Assuming Product is your model class

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedSizeIndex = 0;
  int selectedColorIndex = 0;
  int selectedImageIndex = 0;

  late List<String> imageUrls = List.generate(
          7, (index) => widget.product.thumbnail?.media?.url ?? ''.toString())
      .toList();
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
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text("Home", style: defaultTextStyle.copyWith(fontSize: 16)),
                  Text(" / Cart / ",
                      style: defaultTextStyle.copyWith(fontSize: 16)),
                  Text("Electronics",
                      style: defaultTextStyle.copyWith(
                          fontSize: 16, color: Color(0xffD21642))),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(
                          widget.product.thumbnail?.media?.url ??
                              ''.toString()),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Thumbnail List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageUrls.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImageIndex == index
                                ? Colors.red
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(widget.product.name.toString(),
                      style: defaultTextStyle.copyWith(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Image.asset(
                            index < 4
                                ? 'assets/images/star.png'
                                : 'assets/images/star.png',
                            height: 14,
                          ),
                        ),
                      ),
                      Text(" (4) 80 Reviews | 5,000+ sold",
                          style: defaultTextStyle.copyWith(
                              fontWeight: FontWeight.w400, fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      if (widget.product.isDiscountProduct == true)
                        Text("\$${(widget.product.price ?? 0).toString()}",
                            style: defaultTextStyle.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xff374856))),
                      SizedBox(width: 5),
                      Text("\$${(widget.product.price ?? 0).toString()}",
                          style: defaultTextStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 25,
                              color: Color(0xffD21642))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Size:",
                      style: defaultTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: List.generate(sizes.length, (index) {
                      return Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Color(0xffF7F7F7),
                            border: Border.all(
                              color: Color(0xffDCDCDC),
                            )),
                        child: Center(
                          child: Text(sizes[index].toString()),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  Text("Color:",
                      style: defaultTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: List.generate(colorsSubp.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: CircleAvatar(
                            radius: 19,
                            backgroundColor: Colors.grey.shade300,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: colorsSubp[index],
                              child: selectedColorIndex == index
                                  ? Icon(Icons.check, color: Colors.white)
                                  : null,
                            )),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Quantity:",
                          style: defaultTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          )),
                      SizedBox(width: 10),
                      Container(
                        width: 67,
                        height: 43,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Color(0xffF7F7F7),
                            border: Border.all(
                              color: Color(0xffDCDCDC),
                            )),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 20, bottom: 12),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '5',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Spacer(),
                      SizedBox(width: 10),
                      Text("Last One",
                          style: defaultTextStyle.copyWith(
                              fontSize: 14, color: Colors.green)),
                      Text(" / 44 sold",
                          style: defaultTextStyle.copyWith(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Material(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(11),
                    child: MaterialButton(
                        height: 52,
                        minWidth: double.infinity, // Full width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () {
                          Get.to(() => ShoppingCartScreen());
                        },
                        child: Text("Add To Cart",
                            style: defaultTextStyle.copyWith(
                                color: Colors.white))),
                  ),
                  SizedBox(height: 10),
                  Material(
                    color: Color(0xff34A853),
                    borderRadius: BorderRadius.circular(11),
                    child: MaterialButton(
                      height: 52,
                      minWidth: double.infinity, // Full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Add To Wishlist",
                              style: defaultTextStyle.copyWith(
                                  color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.favorite, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Material(
                    color: Color(0xFF4285F4),
                    borderRadius: BorderRadius.circular(11),
                    child: MaterialButton(
                      height: 52,
                      minWidth: double.infinity, // Full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Enquire Now",
                              style: defaultTextStyle.copyWith(
                                  color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.support_agent, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ProductDetailsSection(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Related Products",
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

class ProductDetailsSection extends StatelessWidget {
  const ProductDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.grey.shade700),
                  SizedBox(width: 8),
                  Text(
                    "Shipping",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "Standard: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "Free on all orders",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        text: "Delivery: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "4-8 Business days",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        text: "Courier Company: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: "Royal Mail, Express",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Get a \$4.00 credit for late delivery",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 67,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.grey.shade700),
              SizedBox(width: 8),
              Text(
                "Shopping security",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.STORE_PAGE);
          },
          child: Container(
            height: 157,
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.red,
                  child: Text(
                    "ECS",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ECS Footwear",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "800 Reviews",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      "Seller's other items",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Contact seller",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.red, width: 3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Description",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          "Customer Reviews (4471)",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                color: Colors.grey.shade300,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a gallery of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing.",
                    style: defaultTextStyle.copyWith(
                        fontSize: 14,
                        wordSpacing: 4,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey)),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
