import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/disputes/disputes_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/products_view_widget.dart';

class DisputesItemCard extends StatelessWidget {
  final DisputeData dispute;

  const DisputesItemCard({super.key, required this.dispute});

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
            const SizedBox(width: 10),
            OrderColumnWidget(
              label: 'Order Disputes ID',
              width: 360,
              value: (dispute.id ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Buyer',
              value: (dispute.buyer?.user?.firstName ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Shop',
              value: (dispute.shop?.shop?.name ?? '').toString(),
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'Status',
              value: (dispute.status ?? '').toString(),
              icon: Icons.pending_actions,
              hasIcon: true,
            ),
            const SizedBox(width: 60),
            OrderColumnWidget(
              label: 'created At',
              value: formatDate(DateTime.parse(dispute.createdAt.toString())),
            ),
            const SizedBox(width: 30),

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
