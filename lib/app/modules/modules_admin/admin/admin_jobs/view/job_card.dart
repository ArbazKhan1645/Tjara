import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/jobs/jobs_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/controller/job_attributes_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/view/insert_job.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/products_view_widget.dart';
import 'package:tjara/app/services/dashbopard_services/adminJobs_service.dart';

class JobItemCard extends StatelessWidget {
  final Job product;

  const JobItemCard({super.key, required this.product});

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
            const SizedBox(width: 20),
            OrderColumnWidget(
              label: 'Image',
              value:
                  (product.thumbnail.media != null
                          ? product.thumbnail.media!.cdnUrl
                          : '')
                      .toString(),
              hasImage:
                  product.thumbnail.media != null
                      ? product.thumbnail.media!.cdnUrl.toString()
                      : '',
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Title',
              value: (product.title ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Salery',
              value: (product.salary ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Work Type',
              value: (product.workType ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Country',
              value: (product.country.name ?? '').toString(),
              icon: Icons.pending_actions,
              hasIcon: true,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'created At',
              value: formatDate(product.createdAt),
            ),
            const SizedBox(width: 60),
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
            GestureDetector(
              onTapDown: (details) {
                Get.to(
                  const InsertJobScreen(),
                  arguments: {'job': product},
                )?.then(((value) {
                  final JobAttributeController controller = Get.put(
                    JobAttributeController(),
                  );
                  controller.resetForm();

                  final AdminJobsService adminProductsService =
                      Get.find<AdminJobsService>();
                  adminProductsService.fetchProducts(loaderType: true);
                }));
              },
              child: const Icon(Icons.remove_red_eye, size: 28),
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
}
