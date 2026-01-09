import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/products_view_widget.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class OrderItemCard extends StatelessWidget {
  final AdminProducts product;

  const OrderItemCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 1, spreadRadius: 1),
        ],
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 100,
      child: IntrinsicWidth(
        child: Row(
          children: [
            OrderColumnWidget(
              label: 'Product Id',
              value: (product.meta?.productId ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 20),
            OrderColumnWidget(
              label: 'Image',
              value:
                  (product.thumbnail!.media != null
                          ? product.thumbnail!.media!.url
                          : '')
                      .toString(),
              hasImage:
                  product.thumbnail!.media != null
                      ? product.thumbnail!.media!.url.toString()
                      : '',
            ),
            const SizedBox(width: 30),
            OrderColumnWidget(
              label: 'Product Name',
              value: (product.name ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 30),
            OrderColumnWidget(
              label: 'Shop Name',
              value: product.shop!.shop!.name ?? 'N/Aa',
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 30),
            OrderColumnWidget(
              label: 'Price',
              value: "\$${product.price}",
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 30),
            OrderColumnWidget(
              label: 'Stock',
              value: "${product.stock}",
              icon: Icons.pending_actions,
              hasIcon: true,
            ),

            OrderColumnWidget(
              label: 'Published At',
              value: formatDate(product.createdAt),
            ),
            OrderColumnWidget(
              hasIcon: true,
              icon: Icons.ac_unit,
              label: 'Status',
              iconColor:
                  product.status.toString().toLowerCase() == 'active'
                      ? const Color(0xFF0d9488)
                      : Colors.red,
              textColor:
                  product.status.toString().toLowerCase() == 'active'
                      ? const Color(0xFF0d9488)
                      : Colors.red,
              value: product.status.toString(),
            ),
            const SizedBox(width: 30),
            ProductActionButtons(
              productId: product.id ?? '',
              productName: product.name ?? 'Product Name',
              productSku: product.slug ?? 'N/A',
              isActive: product.status == 'active',
              isFeatured: product.isFeatured == 1,
              isDeal: product.isDeal == 1,
              onDuplicate: () async {
                final response = await Get.put<AddProductAdminController>(
                  AddProductAdminController(),
                ).duplicateProduct(product);
                if (response == true) {
                  Get.delete<AddProductAdminController>();
                  await Get.find<AdminProductsService>().refreshProducts();
                  await Get.find<AdminProductsService>().fetchProducts(
                    refresh: true,
                  );
                }
              },
              onActiveChanged: () async {
                final response = await ProductService.updateActiveStatus(
                  shopId: product.shop?.shop?.id ?? '',
                  productId: product.id ?? '',
                  isActive: product.status == 'active',
                );

                if (response.success) {
                  Get.snackbar(
                    'Success',
                    response.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                  await Get.find<AdminProductsService>().refreshProducts();
                  await Get.find<AdminProductsService>().fetchProducts(
                    refresh: true,
                  );
                } else {
                  _showErrorMessage(response);
                }
              },
              onFeaturedChanged: () async {
                final response = await ProductService.updateFeaturedStatus(
                  shopId: product.shop?.shop?.id ?? '',
                  productId: product.id ?? '',
                  isFeatured: product.isFeatured == 1,
                );

                if (response.success) {
                  Get.snackbar(
                    'Success',
                    response.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                  await Get.find<AdminProductsService>().refreshProducts();
                  await Get.find<AdminProductsService>().fetchProducts(
                    refresh: true,
                  );
                } else {
                  _showErrorMessage(response);
                }
              },
              onDealChanged: () async {
                final response = await ProductService.updateDealStatus(
                  shopId: product.shop?.shop?.id ?? '',
                  productId: product.id ?? '',
                  isDeal: product.isDeal == 1,
                );

                if (response.success) {
                  Get.snackbar(
                    'Success',
                    response.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                  await Get.find<AdminProductsService>().refreshProducts();
                  await Get.find<AdminProductsService>().fetchProducts(
                    refresh: true,
                  );
                } else {
                  _showErrorMessage(response);
                }
              },
              onEdit: () {
                Get.delete<AddProductAdminController>();
                // Navigate to edit page
                Get.toNamed(
                  Routes.ADD_PRODUCT_ADMIN_VIEW,
                  preventDuplicates: false,

                  arguments: {'product': product},
                );
              },
              onDelete: () async {
                final response = await ProductService.deleteProduct(
                  shopId: product.shop?.shop?.id ?? '',
                  productId: product.id ?? '',
                );

                if (response.success) {
                  await Get.find<AdminProductsService>().refreshProducts();
                  await Get.find<AdminProductsService>().fetchProducts(
                    refresh: true,
                  );
                } else {
                  _showErrorMessage(response);
                }
                // Call delete API
                // _deleteProduct();
              },
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showErrorMessage(ApiResponse response) {
    String errorMessage = response.message;

    // If there are validation errors, show them
    if (response.errors != null && response.errors!.isNotEmpty) {
      final List<String> errorList = [];
      response.errors!.forEach((key, value) {
        if (value is List) {
          errorList.addAll(value.map((e) => e.toString()));
        } else {
          errorList.add(value.toString());
        }
      });
      errorMessage = errorList.join('\n');
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      maxWidth: Get.width * 0.9,
    );
  }
}
