import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/controllers/ad.dart';

import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class ProductsAdminView extends StatefulWidget {
  const ProductsAdminView({super.key});

  @override
  State<ProductsAdminView> createState() => _ProductsAdminViewState();
}

class _ProductsAdminViewState extends State<ProductsAdminView> {
  late AdminProductsService _adminProductsService;

  @override
  void initState() {
    super.initState();

    _adminProductsService = Get.find<AdminProductsService>();
    _adminProductsService.fetchProducts(refresh: true, showLoader: true);
    _adminProductsService.refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: const AdminProductsPage(),
    );
  }
}
