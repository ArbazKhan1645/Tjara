import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/shops_admin/view/stories_card.dart';

import 'package:tjara/app/services/dashbopard_services/shops_service.dart';

class ShopsContextsList extends StatelessWidget {
  final AdminShopsService adminProductsService;

  const ShopsContextsList({
    super.key,
    required this.adminProductsService,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            SingleChildScrollView(
              controller: adminProductsService.scrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  adminProductsService.adminProducts!.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ShopItemCard(
                        product: adminProductsService.adminProducts![index]),
                  ),
                ),
              ),
            ),
            if (adminProductsService.adminProducts!.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: adminProductsService.currentPage.value > 1
                            ? adminProductsService.previousPage
                            : null,
                      ),
                      ...adminProductsService
                          .visiblePageNumbers()
                          .map((page) => Container())
                          ,
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: adminProductsService.currentPage.value <
                                adminProductsService.totalPages.value
                            ? adminProductsService.nextPage
                            : null,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}
