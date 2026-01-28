import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/controller/job_attributes_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';
import 'package:http/http.dart' as http;

class AdminJobsList extends StatelessWidget {
  final AdminJobsService adminProductsService;

  const AdminJobsList({super.key, required this.adminProductsService});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          children: [
            // DataTable with horizontal scroll
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  controller: adminProductsService.scrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFF0D9488),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    dataTextStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    columnSpacing: 40,
                    horizontalMargin: 20,
                    headingRowHeight: 50,
                    dataRowHeight: 60,
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Salary')),
                      DataColumn(label: Text('Work Type')),
                      DataColumn(label: Text('Proposals')),
                      DataColumn(label: Text('Country')),
                      DataColumn(label: Text('Created At')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        adminProductsService.adminProducts!.map((job) {
                          return DataRow(
                            cells: [
                              // Title cell with image
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage:
                                          job.thumbnail.media != null &&
                                                  job.thumbnail.media!.cdnUrl !=
                                                      null
                                              ? NetworkImage(
                                                job.thumbnail.media!.cdnUrl ??
                                                    '',
                                              )
                                              : null,
                                      child:
                                          job.thumbnail.media == null ||
                                                  job.thumbnail.media!.cdnUrl ==
                                                      null
                                              ? Icon(
                                                Icons.work,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        job.title ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Salary cell
                              DataCell(
                                Text(
                                  job.salary ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Work Type cell
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getWorkTypeColor(
                                      job.workType ?? '',
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    job.workType ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Proposals cell
                              const DataCell(
                                Text(
                                  '0', // You can replace this with actual proposals count
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              // Country cell
                              DataCell(
                                Text(
                                  job.country.name ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Created At cell
                              DataCell(
                                Text(
                                  formatDate(job.createdAt),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Status cell
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        job.status.toString().toLowerCase() ==
                                                'active'
                                            ? const Color(0xFF0d9488)
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    job.status.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Actions cell
                              DataCell(
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Get.to(
                                        const InsertJobScreen(),
                                        arguments: {'job': job},
                                      )?.then((value) {
                                        final JobAttributeController
                                        controller = Get.put(
                                          JobAttributeController(),
                                        );
                                        controller.resetForm();

                                        final AdminJobsService
                                        adminProductsService =
                                            Get.find<AdminJobsService>();
                                        adminProductsService.fetchProducts(
                                          loaderType: true,
                                        );
                                      });
                                    } else if (value == 'delete') {
                                      // Confirm and delete logic here
                                      // Example: show confirmation dialog
                                      Get.defaultDialog(
                                        title: 'Delete Job',
                                        middleText:
                                            'Are you sure you want to delete this job?',
                                        textConfirm: 'Yes',
                                        textCancel: 'No',
                                        onConfirm: () async {
                                          final uri = Uri.parse(
                                            'https://api.libanbuy.com/api/jobs/${job.id}/delete',
                                          );

                                          final response = await http.delete(
                                            uri,
                                            headers: {
                                              'Accept': 'application/json',
                                              'X-Request-From': 'Application',
                                              'shop-id':
                                                  '0000c539-9857-3456-bc53-2bbdc1474f1a',
                                            },
                                          );

                                          if (response.statusCode == 200 ||
                                              response.statusCode == 204 ||
                                              response.statusCode == 201) {
                                            Get.back();
                                            Get.snackbar(
                                              'Success',
                                              'Job deleted successfully',
                                            );

                                            final AdminJobsService
                                            adminProductsService =
                                                Get.find<AdminJobsService>();
                                            adminProductsService.fetchProducts(
                                              loaderType: true,
                                            );
                                          } else {
                                            Get.snackbar(
                                              'Error',
                                              'Failed to delete job',
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(Icons.edit, size: 18),
                                            title: Text('Edit'),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.delete,
                                              size: 18,
                                            ),
                                            title: Text('Delete'),
                                          ),
                                        ),
                                      ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

            // Pagination controls
            if (adminProductsService.adminProducts!.isNotEmpty)
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                      ...adminProductsService.visiblePageNumbers().map(
                        (page) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed:
                                () => adminProductsService.goToPage(page),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  adminProductsService.currentPage.value == page
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade200,
                              foregroundColor:
                                  adminProductsService.currentPage.value == page
                                      ? Colors.white
                                      : Colors.black87,
                              minimumSize: const Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(page.toString()),
                          ),
                        ),
                      ),
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

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getWorkTypeColor(String workType) {
    switch (workType.toLowerCase()) {
      case 'on-site':
        return Colors.blue;
      case 'remote':
        return Colors.green;
      case 'hybrid':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
