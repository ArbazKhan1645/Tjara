import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/order_item_widget.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class AdminCarsList extends StatelessWidget {
  final AdminCarsService adminProductsService;

  const AdminCarsList({super.key, required this.adminProductsService});

  List<Widget> _buildPageButtons(AdminCarsService service, int maxButtons) {
    final currentPage = service.currentPage.value;
    final totalPages = service.totalPages.value;
    final List<Widget> buttons = [];

    if (totalPages <= maxButtons) {
      // Show all pages if they fit
      for (int page = 1; page <= totalPages; page++) {
        buttons.add(_buildPageButton(service, page));
      }
    } else {
      // Smart pagination with ellipsis
      buttons.add(_buildPageButton(service, 1));

      if (currentPage > 3) {
        buttons.add(_buildEllipsis());
      }

      // Show pages around current page
      final start = (currentPage - 1).clamp(2, totalPages - maxButtons + 3);
      final end = (currentPage + 1).clamp(
        start + maxButtons - 4,
        totalPages - 1,
      );

      for (int page = start; page <= end && page < totalPages; page++) {
        if (page > 1 && page < totalPages) {
          buttons.add(_buildPageButton(service, page));
        }
      }

      if (currentPage < totalPages - 2) {
        buttons.add(_buildEllipsis());
      }

      if (totalPages > 1) {
        buttons.add(_buildPageButton(service, totalPages));
      }
    }

    return buttons;
  }

  Widget _buildPageButton(AdminCarsService service, int page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          minimumSize: const Size(32, 32),
          backgroundColor:
              page == service.currentPage.value
                  ? Colors.blue
                  : Colors.grey[300],
          foregroundColor:
              page == service.currentPage.value ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          await service.goToPage(page);
          service.fetchProducts(loaderType: false);
        },
        child: Text(page.toString(), style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print for development
    debugPrint("AdminCarsService type: ${adminProductsService.runtimeType}");
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
                    child: OrderItemCard(
                      product: adminProductsService.adminProducts![index],
                    ),
                  ),
                ),
              ),
            ),
            if (adminProductsService.adminProducts!.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate how many page buttons can fit on screen
                      final maxButtons = (constraints.maxWidth / 40)
                          .floor()
                          .clamp(3, 10);

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                            const SizedBox(width: 8),
                            ..._buildPageButtons(
                              adminProductsService,
                              maxButtons,
                            ),
                            const SizedBox(width: 8),
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
                    },
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}
