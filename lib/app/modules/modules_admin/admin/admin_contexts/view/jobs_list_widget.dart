import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_contexts/view/job_card.dart';
import 'package:tjara/app/services/dashbopard_services/contests_service.dart';

class AdminContextsList extends StatelessWidget {
  final ContestsService adminProductsService;

  const AdminContextsList({super.key, required this.adminProductsService});

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
                  adminProductsService.contests.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ContestsItemCard(
                      product: adminProductsService.contests[index],
                    ),
                  ),
                ),
              ),
            ),
            if (adminProductsService.contests.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            adminProductsService.currentPage > 1
                                ? adminProductsService.previousPage
                                : null,
                      ),
                      ...adminProductsService.getVisiblePageNumbers().map(
                        (page) => Container(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            adminProductsService.currentPage <
                                    adminProductsService.totalPages
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
