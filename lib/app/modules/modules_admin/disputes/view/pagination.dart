import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/services/dashbopard_services/disputes_service.dart';

class DisputesPaginationWidget extends StatelessWidget {
  final AdminDisputesService service;

  const DisputesPaginationWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Pagination Info
          Obx(
            () => Text(
              service.paginationText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pagination Controls
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Page Button
                IconButton(
                  onPressed:
                      service.currentPage.value > 1
                          ? () => service.goToPage(1)
                          : null,
                  icon: const Icon(Icons.first_page),
                  tooltip: 'First page',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        service.currentPage.value > 1
                            ? Colors.white
                            : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Previous Page Button
                IconButton(
                  onPressed:
                      service.canGoPrevious ? service.previousPage : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous page',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        service.canGoPrevious
                            ? Colors.white
                            : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Page Numbers
                ...service.visiblePageNumbers.map((pageNumber) {
                  final isCurrentPage = pageNumber == service.currentPage.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => service.goToPage(pageNumber),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isCurrentPage ? const Color(0xFFF97316) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isCurrentPage
                                    ? const Color(0xFFF97316)
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            pageNumber.toString(),
                            style: TextStyle(
                              color:
                                  isCurrentPage ? Colors.white : Colors.black87,
                              fontWeight:
                                  isCurrentPage
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 16),

                // Next Page Button
                IconButton(
                  onPressed: service.canGoNext ? service.nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next page',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        service.canGoNext ? Colors.white : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Last Page Button
                IconButton(
                  onPressed:
                      service.currentPage.value < service.totalPages.value
                          ? () => service.goToPage(service.totalPages.value)
                          : null,
                  icon: const Icon(Icons.last_page),
                  tooltip: 'Last page',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        service.currentPage.value < service.totalPages.value
                            ? Colors.white
                            : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Items Per Page Selector
          // Obx(
          //   () => Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         'Items per page:',
          //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          //       ),
          //       const SizedBox(width: 8),

          //       Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 12),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(8),
          //           border: Border.all(color: Colors.grey.shade300),
          //         ),
          //         child: DropdownButton<int>(
          //           value: service.perPage.value,
          //           underline: const SizedBox.shrink(),
          //           items:
          //               [10, 15, 25, 50, 100]
          //                   .map(
          //                     (value) => DropdownMenuItem(
          //                       value: value,
          //                       child: Text(value.toString()),
          //                     ),
          //                   )
          //                   .toList(),
          //           onChanged: (value) {
          //             if (value != null) {
          //               service.perPage.value = value;
          //               service.currentPage.value = 1;
          //               service.loadDisputes(
          //                 showLoader: false,
          //                 userId: Get.arguments,
          //               );
          //             }
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
