import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import '../../../models/products/products_model.dart';
import '../controllers/home_controller.dart';

class SuperDealsWidget extends StatefulWidget {
  const SuperDealsWidget({super.key});

  @override
  State<SuperDealsWidget> createState() => _SuperDealsWidgetState();
}

class _SuperDealsWidgetState extends State<SuperDealsWidget>
    with AutomaticKeepAliveClientMixin {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: _bucket,
      child: GetBuilder<HomeController>(builder: (controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.electric_bolt_outlined,
                        size: 25,
                        weight: 20,
                        color: Colors.black,
                      ),
                      Text(
                        "Super Deals",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade900,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red.shade900,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                  key: PageStorageKey<String>('dealsListProducts'),
                  itemCount:
                      controller.products.value.products?.data?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    ProductDatum data =
                        controller.products.value.products?.data![index] ??
                            ProductDatum();
                    return Superdeals(
                        key: PageStorageKey('deal_product_${data.id}'),
                        data: data);
                  }),
            ),
          ],
        );
      }),
    );
  }
}

class Superdeals extends StatelessWidget {
  const Superdeals({super.key, required this.data});
  final ProductDatum data;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (builder) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 10),
        child: SizedBox(
          height: 160,
          width: 140,
          child: Column(
            children: [
              Stack(
                children: [
                  FutureBuilder<ImageProvider>(
                    future: loadCachedImage(
                        (data.thumbnail?.media?.url ?? 'N/A').toString()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          height: 110,
                          width: 140,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: Container(
                              height: 50,
                              width: 10,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          height: 50,
                          width: 10,
                          decoration: BoxDecoration(),
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 20,
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: const Center(
                        child: Text(
                          "19.05% Off",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 140,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$3.50",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    Text(
                      "0Sold",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
