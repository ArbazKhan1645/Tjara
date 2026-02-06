import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/views/widgets/flash_deal_settings_form.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/views/widgets/flash_deal_products_tabs.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealSettingsView extends GetView<FlashDealController> {
  const FlashDealSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AdminTheme.primaryColor),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState();
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Flash Deal Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      controller.flashDealsEnabled.value
                          ? AdminTheme.successColor
                          : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.flashDealsEnabled.value
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.flashDealsEnabled.value
                          ? 'Active'
                          : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AdminTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              style: const TextStyle(
                color: AdminTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AdminPrimaryButton(
              label: 'Retry',
              icon: Icons.refresh,
              width: 150,
              onPressed: () => controller.onInit(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Main scrollable content
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings Form
                FlashDealSettingsForm(),
                SizedBox(height: 24),
                // Products Tabs
                FlashDealProductsTabs(),
                SizedBox(height: 100), // Space for save button
              ],
            ),
          ),
        ),
        // Fixed Save Button
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => AdminPrimaryButton(
            label: 'Save Flash Deal Settings',
            icon: Icons.save_outlined,
            isLoading: controller.isSaving.value,
            onPressed:
                controller.isSaving.value
                    ? null
                    : () => controller.saveFlashDealSettings(),
          ),
        ),
      ),
    );
  }
}
