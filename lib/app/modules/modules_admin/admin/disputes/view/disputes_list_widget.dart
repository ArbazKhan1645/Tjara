import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/disputes/view/disputes_card.dart';

import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesContextsList extends StatelessWidget {
  final AdminDisputesService adminProductsService;

  const DisputesContextsList({super.key, required this.adminProductsService});

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
                  adminProductsService.disputes.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DisputesItemCard(
                      dispute: adminProductsService.disputes[index],
                    ),
                  ),
                ),
              ),
            ),
            if (adminProductsService.disputes.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            adminProductsService.currentPage.value > 1
                                ? adminProductsService.previousPage
                                : null,
                      ),
                      // ...adminProductsService
                      //     .visiblePageNumbers()
                      //     .map((page) => Container()),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            adminProductsService.currentPage.value <
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
