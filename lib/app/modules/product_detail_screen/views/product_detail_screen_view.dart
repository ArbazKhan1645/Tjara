import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import '../../../models/products/products_model.dart';
import '../../home/widgets/product_detail.dart';
import '../controllers/product_detail_screen_controller.dart';

class ProductDetailScreenView extends GetView<ProductDetailScreenController> {
  const ProductDetailScreenView({super.key, this.product});
  final ProductDatum? product;
  @override
  Widget build(BuildContext context) {
    return ProductDetailScreen(
      controller: Get.find<HomeController>(),
      product: product ?? ProductDatum(),
    );
  }
}
