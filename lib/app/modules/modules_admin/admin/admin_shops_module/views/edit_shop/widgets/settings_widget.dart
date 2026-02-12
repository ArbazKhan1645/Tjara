import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/const/appColors.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/views/edit_shop/controllers/edit_shop_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/views/edit_shop/widgets/shop_info_Widget.dart';

class SettingsMenu extends StatelessWidget {
  final EditShopController controller = Get.put(EditShopController());

  final isActive;
  final Balance;
  final shopName;
  final shopDescription;
  final shopContact;
  final shopId;

  SettingsMenu({
    super.key,

    required this.isActive,
    required this.Balance,
    required this.shopName,
    required this.shopDescription,
    required this.shopContact,
    required this.shopId,
  });

  Widget buildContent(int index) {
    switch (index) {
      case 0:
        return Center(
          child: ShopInfoImagesWidget(
            shopId: shopId,
            Balance: Balance,
            shopName: shopName,
            shopDescription: shopDescription,
            shopContact: shopContact,
            isActive: isActive,
          ),
        );
      case 1:
        return const Center(child: Text("Shipping Settings Content"));
      case 2:
        return const Center(child: Text("Shop Meta Settings Content"));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sidebar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: appcolors.grey.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(controller.titles.length, (index) {
                  final isSelected = index == controller.selectedIndex.value;
                  return InkWell(
                    onTap: () {
                      controller.selectedIndex.value = index;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            controller.icons[index],
                            color:
                                isSelected ? Colors.red : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.titles[index],
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.red
                                      : Colors.grey.shade800,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Content Area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => buildContent(controller.selectedIndex.value)),
          ),
        ),
      ],
    );
  }
}
