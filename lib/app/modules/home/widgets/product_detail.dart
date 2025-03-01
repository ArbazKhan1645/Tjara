// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/modules/home/widgets/attributes.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';
import 'package:tjara/app/modules/home/widgets/shopping_cart.dart';

import 'package:tjara/app/routes/app_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/widgets/appbar.dart';
import '../../../models/products/products_model.dart';
import '../../../models/products/single_product_model.dart';

import '../../my_cart/controllers/my_cart_controller.dart';
import '../controllers/home_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen(
      {super.key, required this.product, this.controller});
  final ProductDatum product;
  final HomeController? controller;

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedSizeIndex = 0;
  int selectedColorIndex = 0;
  int selectedImageIndex = 0;

  late List<String> imageUrls = [widget.product.thumbnail?.media?.url ?? ''];
  List<int> sizes = [34, 43, 44, 55, 33, 23];
  List<Color> colorsSubp = [
    Colors.black,
    Colors.teal,
    Colors.purple,
    Colors.green
  ];
  final PageController _controller = PageController();

  SingleModelClass? cachedProduct;

  @override
  void initState() {
    super.initState();
    _loadCachedProduct();
  }

  Future<void> _loadCachedProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('product_${widget.product.id}');

    if (cachedData != null) {
      setState(() {
        cachedProduct = SingleModelClass.fromJson(json.decode(cachedData));
      });
    }
  }

  Future<void> _cacheProduct(SingleModelClass product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'product_${widget.product.id}', json.encode(product.toJson()));
  }

  CartService cartService = Get.find<CartService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(),
        body: FutureBuilder<SingleModelClass?>(
            future: widget.controller!
                .fetchSingleProducts(widget.product.id.toString()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              SingleModelClass? product = snapshot.data ?? cachedProduct;

              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                _cacheProduct(snapshot.data!);
              }

              return ListView(
                children: [
                  Builder(builder: (context) {
                    // if (product == null || product.product == null) {
                    //   return Container();
                    // }
                    imageUrls.clear();
                    imageUrls = [widget.product.thumbnail?.media?.url ?? ''];

                    for (var e
                        in product?.product?.gallery ?? <ThumbnailElement>[]) {
                      imageUrls.add(e.media!.url.toString().trim());
                    }
                    return Column(
                      children: [
                        ImageSlider(
                            imageUrls: imageUrls, controller: _controller),
                        SizedBox(height: 15),
                        Center(
                          child: SmoothPageIndicator(
                            controller: _controller,
                            count: 3,
                            effect: ExpandingDotsEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              activeDotColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                            'ID:${widget.product.meta?.productId ?? ''.toString()}',
                            style: defaultTextStyle.copyWith(
                                fontSize: 20, fontWeight: FontWeight.w500)),
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
                        // Row(
                        //   children: [
                        //     if (widget.product.isDiscountProduct == true)
                        //       Text("\$${(widget.product.price ?? 0).toString()}",
                        //           style: defaultTextStyle.copyWith(
                        //               fontWeight: FontWeight.w400,
                        //               fontSize: 18,
                        //               decoration: TextDecoration.lineThrough,
                        //               color: Color(0xff374856))),
                        //     SizedBox(width: 5),
                        //     Text("\$${(widget.product.price ?? 0).toString()}",
                        //         style: defaultTextStyle.copyWith(
                        //             fontWeight: FontWeight.w700,
                        //             fontSize: 25,
                        //             color: Color(0xffD21642))),
                        //   ],
                        // ),
                        Builder(
                          builder: (context) {
                            if (product == null) {
                              return Container();
                            }

                            if (product.product == null) {
                              return Container();
                            }
                            final variation = product.product?.variation;

                            if (variation == null) {
                              return SizedBox();
                            }

                            return ProductVariationDisplay(
                              variation: variation,
                              onAttributesSelected: (p) {},
                            );
                          },
                        ),
                        // Text(
                        //   product.product?.categories?.productAttributeItems.first
                        //           .attributeItem?.productAttributeItem?.name ??
                        //       '',
                        // ),
                        // Text("Size:",
                        //     style: defaultTextStyle.copyWith(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 16,
                        //     )),
                        // SizedBox(height: 10),
                        // Wrap(
                        //   spacing: 10,
                        //   children: List.generate(sizes.length, (index) {
                        //     return Container(
                        //       height: 40,
                        //       width: 40,
                        //       decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(7),
                        //           color: Color(0xffF7F7F7),
                        //           border: Border.all(
                        //             color: Color(0xffDCDCDC),
                        //           )),
                        //       child: Center(
                        //         child: Text(sizes[index].toString()),
                        //       ),
                        //     );
                        //   }),
                        // ),
                        // SizedBox(height: 10),
                        // Text("Color:",
                        //     style: defaultTextStyle.copyWith(
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 16,
                        //     )),
                        // SizedBox(height: 10),

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
                                  hintText: '1',
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
                              onPressed: () async {
                                await cartService
                                    .updateCart(
                                        widget.product.shopId ?? '',
                                        widget.product.id ?? '',
                                        1,
                                        double.tryParse(widget.product.price
                                                .toString()) ??
                                            0.0)
                                    .then((val) {
                                  Get.to(() => ShoppingCartScreen());
                                });
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
              );
            }),
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
        TabbedContainer(),
        SizedBox(height: 30),
      ],
    );
  }
}

class TabbedContainer extends StatefulWidget {
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
              color: Color(0xffF9F9F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildTab("Description", 0),
                _buildTab("Customer Reviews (0)", 1),
              ],
            ),
          ),
          Container(
            height: 2,
            color: Colors.grey.shade300,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: selectedIndex == 0 ? _descriptionWidget() : _reviewsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(bottom: BorderSide(color: Colors.red, width: 3))
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

  Widget _descriptionWidget() {
    return Text(
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
      style: TextStyle(
        fontSize: 14,
        wordSpacing: 4,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    );
  }

  Widget _reviewsWidget() {
    return Text(
      "No customer reviews yet.",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final PageController controller;

  const ImageSlider(
      {super.key, required this.imageUrls, required this.controller});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (widget.imageUrls[index].isEmpty) {
                return Container();
              }
              return FutureBuilder<ImageProvider>(
                future: loadCachedImage(widget.imageUrls[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return ClipOval(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/logo.png'),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularImage(ImageProvider imageProvider) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
    ).animate().fade(duration: 100.ms);
  }
}
