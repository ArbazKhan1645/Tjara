import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/product_detail.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/controllers/product_detail_screen_controller.dart';

class ProductDetailScreenView extends GetView<ProductDetailScreenController> {
  const ProductDetailScreenView({super.key, this.product});
  final ProductDatum? product;

  @override
  Widget build(BuildContext context) {
    return ProductDetailScreen(product: product ?? ProductDatum());
  }
}
