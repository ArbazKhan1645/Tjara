import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/const/appColors.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/views/edit_shop/controllers/edit_shop_controller.dart';

class InfoTextWidget extends StatefulWidget {
  const InfoTextWidget({
    super.key,
    required this.uploadCover,
    required this.selectedValue,
    required this.balance,
  });

  final VoidCallback uploadCover;
  final String selectedValue;
  final String balance;

  @override
  State<InfoTextWidget> createState() => _InfoTextWidgetState();
}

class _InfoTextWidgetState extends State<InfoTextWidget> {
  final EditShopController controller = Get.find<EditShopController>();

  @override
  void initState() {
    super.initState();
    controller.selectedStatus.value = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Status",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedStatus.value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                dropdownColor: appcolors.white,
                items:
                    controller.statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: TextStyle(color: appcolors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedStatus.value = value;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Balance : \$${widget.balance}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: widget.uploadCover,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.image_outlined, color: Colors.black87),
              label: const Text(
                "Upload Cover",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
