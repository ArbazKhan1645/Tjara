import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/products_view_widget.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';

class ContestsItemCard extends StatelessWidget {
  final ContestModel product;

  const ContestsItemCard({super.key, required this.product});

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
              value: product.thumbnail?.media?.url ?? '',
              hasImage: product.thumbnail?.media?.url ?? '',
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Product Name',
              value: (product.name ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Salery',
              value: (product.name ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Work Type',
              value: (product.name ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Proposal',
              value: (product.name ?? '').toString(),
              icon: Icons.pending_actions,
              hasIcon: true,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'created At',
              value: formatDate(DateTime.parse(product.createdAt.toString())),
            ),
            const SizedBox(width: 30),
            GestureDetector(
              onTapDown: (details) {
                // Add your popup logic here if needed
              },
              child: const Icon(Icons.more_vert, size: 28),
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
