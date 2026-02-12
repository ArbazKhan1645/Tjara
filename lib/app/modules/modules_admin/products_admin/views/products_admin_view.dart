import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/controllers/ad.dart';

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

    _adminProductsService = Get.put(AdminProductsService());
    _adminProductsService.adminProducts.clear();
    _adminProductsService.fetchProducts(refresh: true, showLoader: true);
  }

  @override
  Widget build(BuildContext context) {
    return const AdminProductsPage();
  }
}
