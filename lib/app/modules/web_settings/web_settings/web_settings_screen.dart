import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/web_settings/web_settings_controller.dart';

class WebSettingsScreen extends StatelessWidget {
  WebSettingsScreen({super.key});

  final controller = Get.put(WebSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer();
        }

        if (controller.errorMessage.value != null) {
          return _buildErrorState();
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: WebSettingsTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Website Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(
          () =>
              controller.isSaving.value
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    onPressed: () => controller.saveSettings(),
                    tooltip: 'Save Settings',
                  ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value ?? 'An error occurred',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchAllSettings(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebSettingsTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Website Basic Info
          _buildWebsiteInfoSection(),
          const SizedBox(height: 20),

          // Contact Information
          _buildContactInfoSection(),
          const SizedBox(height: 20),

          // Reseller Registration
          _buildResellerSection(),
          const SizedBox(height: 20),

          // Flash Deals Settings
          _buildFlashDealsSection(),
          const SizedBox(height: 20),

          // Admin Commission & Limits
          _buildAdminSettingsSection(),
          const SizedBox(height: 20),

          // Lebanon Tech Discount
          _buildLebanonTechSection(),
          const SizedBox(height: 20),

          // Shipping Settings
          _buildShippingSection(),
          const SizedBox(height: 20),

          // WhatsApp Icons
          _buildWhatsAppIconsSection(),
          const SizedBox(height: 20),

          // Other Toggles
          _buildOtherTogglesSection(),
          const SizedBox(height: 20),

          // App Store Links
          _buildAppStoreLinksSection(),
          const SizedBox(height: 24),

          // Save Button
          _buildSaveButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================
  // Website Basic Info Section
  // ============================================

  Widget _buildWebsiteInfoSection() {
    return _buildSectionCard(
      title: 'Website Title',
      icon: Icons.web,
      iconColor: Colors.blue,
      isRequired: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: controller.websiteNameController,
            hint: 'Enter website title',
          ),
        ],
      ),
    );
  }

  // ============================================
  // Contact Information Section
  // ============================================

  Widget _buildContactInfoSection() {
    return _buildSectionCard(
      title: 'Contact Information',
      icon: Icons.contact_mail_outlined,
      iconColor: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Description',
            isRequired: true,
            child: _buildTextField(
              controller: controller.websiteDescriptionController,
              hint: 'Enter website description',
              maxLines: 5,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Whatsapp Number',
            isRequired: true,
            description:
                'Enter the whatsapp number for website related enquiries.',
            child: _buildTextField(
              controller: controller.whatsappNumberController,
              hint: 'e.g., 71439117',
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Support Team Email',
            isRequired: true,
            description: 'Enter the email for support related enquiries.',
            child: _buildTextField(
              controller: controller.supportEmailController,
              hint: 'support@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Sales Team Email',
            isRequired: true,
            description: 'Enter the email for sales related enquiries.',
            child: _buildTextField(
              controller: controller.salesEmailController,
              hint: 'sales@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Reseller Registration Section
  // ============================================

  Widget _buildResellerSection() {
    return _buildSectionCard(
      title: 'Enable Reseller Registration?',
      icon: Icons.people_outline,
      iconColor: Colors.purple,
      isRequired: true,
      description:
          'Configure the automatic reseller account creation of newly registered users.',
      child: Obx(
        () => _buildCheckboxTile(
          title: 'Enable Automatic Reseller Account Creation',
          value: controller.resellerRegistrationEnabled.value,
          onChanged:
              (val) =>
                  controller.resellerRegistrationEnabled.value = val ?? false,
        ),
      ),
    );
  }

  // ============================================
  // Flash Deals Section
  // ============================================

  Widget _buildFlashDealsSection() {
    return _buildSectionCard(
      title: 'Flash Deals Purchase Limits',
      icon: Icons.flash_on_outlined,
      iconColor: Colors.orange,
      isRequired: true,
      description:
          'Configure purchase limits for flash deals to prevent users from buying all deals from one store.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _buildCheckboxTile(
              title: 'Enable Flash Deals Purchase Limits',
              value: controller.flashDealsLimitEnabled.value,
              onChanged:
                  (val) =>
                      controller.flashDealsLimitEnabled.value = val ?? false,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Purchase Limit Per Store',
                  child: _buildTextField(
                    controller: controller.flashDealsLimitPerStoreController,
                    hint: '100',
                    keyboardType: TextInputType.number,
                  ),
                  description:
                      'Maximum flash deals a user can purchase from each store',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLabeledField(
                  label: 'Time Limit (Hours)',
                  child: _buildTextField(
                    controller: controller.flashDealsTimeLimitController,
                    hint: '24',
                    keyboardType: TextInputType.number,
                  ),
                  description: 'Time period for the purchase limit (in hours)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // Admin Settings Section
  // ============================================

  Widget _buildAdminSettingsSection() {
    return _buildSectionCard(
      title: 'Admin Settings',
      icon: Icons.admin_panel_settings_outlined,
      iconColor: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Admin order commission in %',
            isRequired: true,
            description:
                'The admin commission in percentage specified here will be deducted from each order created on the Tjara Platform.',
            child: _buildTextField(
              controller: controller.adminCommissionController,
              hint: '10',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Minimum Discount in % on product for Deals Eligibility',
            isRequired: true,
            description:
                'This sets the minimum percentage discount a product must have to be eligible for the deals section.',
            child: _buildTextField(
              controller: controller.minDiscountForDealsController,
              hint: '30',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Vendors maximum products listing limit',
            isRequired: true,
            description:
                'This sets the maximum number of products a vendor can publish before verification.',
            child: _buildTextField(
              controller: controller.vendorsMaxProductsController,
              hint: '10',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Vendors maximum car listings limit',
            isRequired: true,
            description:
                'This sets the maximum number of cars a vendor can publish before verification.',
            child: _buildTextField(
              controller: controller.vendorsMaxCarsController,
              hint: '2',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Lebanon Tech Discount Section
  // ============================================

  Widget _buildLebanonTechSection() {
    return _buildSectionCard(
      title: 'Lebanon Tech Discount Settings',
      icon: Icons.local_offer_outlined,
      iconColor: Colors.teal,
      isRequired: true,
      description:
          'Configure the special discount for Lebanon Tech products when customers shop at Tjara Store.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _buildCheckboxTile(
              title: 'Enable Lebanon Tech Discount',
              value: controller.lebanonTechDiscountEnabled.value,
              onChanged:
                  (val) =>
                      controller.lebanonTechDiscountEnabled.value =
                          val ?? false,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Minimum Purchase Amount at Tjara Store (\$)',
                  child: _buildTextField(
                    controller: controller.lebanonTechMinAmountController,
                    hint: '50',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLabeledField(
                  label: 'Discount Percentage (%)',
                  child: _buildTextField(
                    controller: controller.lebanonTechDiscountPercentController,
                    hint: '10',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Referral Earnings Percentage (%)',
            child: _buildTextField(
              controller: controller.lebanonTechReferralPercentController,
              hint: '10',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Shipping Settings Section
  // ============================================

  Widget _buildShippingSection() {
    return _buildSectionCard(
      title: 'Shipping Settings',
      icon: Icons.local_shipping_outlined,
      iconColor: Colors.brown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _buildCheckboxTile(
              title: 'Enable Global Free Shipping',
              value: controller.globalFreeShippingEnabled.value,
              onChanged:
                  (val) =>
                      controller.globalFreeShippingEnabled.value = val ?? false,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'LibanPost Default Shipping Cost',
            isRequired: true,
            child: _buildTextField(
              controller: controller.libanpostShippingCostController,
              hint: '4',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Shipping Days From',
                  isRequired: true,
                  description:
                      'This sets the default shipping days from for LibanPost shipping method.',
                  child: _buildTextField(
                    controller: controller.libanpostShippingDaysFromController,
                    hint: '1',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLabeledField(
                  label: 'LibanPost Default Shipping Days To',
                  isRequired: true,
                  description:
                      'This sets the default shipping days to for LibanPost shipping method.',
                  child: _buildTextField(
                    controller: controller.libanpostShippingDaysToController,
                    hint: '3',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // WhatsApp Icons Section
  // ============================================

  Widget _buildWhatsAppIconsSection() {
    return _buildSectionCard(
      title: 'WhatsApp Icon Settings',
      icon: Icons.chat_outlined,
      iconColor: Colors.green.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Cars Page Whatsapp Icon URL',
            isRequired: true,
            description: 'Add the WhatsApp icon URL for the cars page here.',
            child: _buildTextField(
              controller: controller.carsPageWhatsappUrlController,
              hint: 'https://www.tjara.com',
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Cars Page Whatsapp Icon Text',
            isRequired: true,
            description: 'Add the WhatsApp icon text for the cars page here.',
            child: _buildTextField(
              controller: controller.carsPageWhatsappTextController,
              hint: 'Enter text',
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'HomePage Whatsapp Icon URL',
            isRequired: true,
            description: 'Add the WhatsApp icon URL for the homepage here.',
            child: _buildTextField(
              controller: controller.homePageWhatsappUrlController,
              hint: 'https://www.tjara.com',
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'HomePage Whatsapp Icon Text',
            isRequired: true,
            description: 'Add the WhatsApp icon text for the homepage here.',
            child: _buildTextField(
              controller: controller.homePageWhatsappTextController,
              hint: 'Enter text',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Other Toggles Section
  // ============================================

  Widget _buildOtherTogglesSection() {
    return _buildSectionCard(
      title: 'Other Settings',
      icon: Icons.settings_outlined,
      iconColor: Colors.grey.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Enable First Order Discount?',
            isRequired: true,
            description:
                'Enable or disable the first order discount feature for new customers (Tjara Store only).',
            child: Obx(
              () => _buildCheckboxTile(
                title: 'Enable First Order Discount',
                value: controller.firstOrderDiscountEnabled.value,
                onChanged:
                    (val) =>
                        controller.firstOrderDiscountEnabled.value =
                            val ?? false,
              ),
            ),
          ),
          const Divider(height: 32),
          _buildLabeledField(
            label: 'Auto Check Mark Product inventory When Stock is Updated?',
            isRequired: true,
            description:
                'This sets the settings to auto check mark product inventory when stock is updated.',
            child: Obx(
              () => _buildCheckboxTile(
                title: 'Auto Check Mark Inventory Upon Stock Update',
                value: controller.autoCheckInventoryEnabled.value,
                onChanged:
                    (val) =>
                        controller.autoCheckInventoryEnabled.value =
                            val ?? false,
              ),
            ),
          ),
          const Divider(height: 32),
          _buildLabeledField(
            label: 'Enable auto contest winner selection?',
            isRequired: true,
            description:
                'This sets the settings to enable auto select contest winner.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => _buildCheckboxTile(
                    title: 'Enable Auto Contest Winner Selection',
                    value: controller.contestWinnerSelectionEnabled.value,
                    onChanged:
                        (val) =>
                            controller.contestWinnerSelectionEnabled.value =
                                val ?? false,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabeledField(
                  label: 'Contest Winner Selection Time',
                  description:
                      'Set the time of day when the contest winner should be selected (24-hour format).',
                  child: _buildTextField(
                    controller: controller.contestWinnerTimeController,
                    hint: '09:02 PM',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // App Store Links Section
  // ============================================

  Widget _buildAppStoreLinksSection() {
    return _buildSectionCard(
      title: 'App Store Links',
      icon: Icons.phone_android_outlined,
      iconColor: Colors.deepPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'Tjara Google Play store link',
            isRequired: true,
            description: 'Add the google play store link of Tjara app here.',
            child: _buildTextField(
              controller: controller.googlePlayLinkController,
              hint: 'https://play.google.com/store/apps/...',
            ),
          ),
          const SizedBox(height: 16),
          _buildLabeledField(
            label: 'Tjara Apple App store link',
            isRequired: true,
            description: 'Add the Apple app store link of Tjara app here.',
            child: _buildTextField(
              controller: controller.appleStoreLinkController,
              hint: 'https://apps.apple.com/us/app/...',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Common Widgets
  // ============================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    bool isRequired = false,
    String? description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Required',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
    bool isRequired = false,
    String? description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextDirection? textDirection,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textAlign:
          textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: WebSettingsTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              value
                  ? WebSettingsTheme.primaryColor.withOpacity(0.05)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                value
                    ? WebSettingsTheme.primaryColor.withOpacity(0.3)
                    : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? WebSettingsTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      value
                          ? WebSettingsTheme.primaryColor
                          : Colors.grey.shade300,
                ),
              ),
              child:
                  value
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      value
                          ? WebSettingsTheme.primaryColor
                          : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed:
              controller.isSaving.value
                  ? null
                  : () => controller.saveSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: WebSettingsTheme.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              controller.isSaving.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
