import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_controller.dart';

class AddCouponPage extends StatelessWidget {
  final EditCouponController controller = Get.put(EditCouponController());

  AddCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? 'Edit Coupon' : 'Add New Coupon',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildCouponTypeCard(),
              const SizedBox(height: 16),
              Obx(
                () => controller.selectedCouponType.value == 'discount'
                    ? Column(
                        children: [
                          _buildDiscountedItemsCard(),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              _buildValidityCard(),
              const SizedBox(height: 16),
              _buildStoreAvailabilityCard(),
              const SizedBox(height: 16),
              if (!controller.isEditMode) ...[
                _buildCodeGenerationCard(),
                const SizedBox(height: 16),
              ],
              _buildUsageLimitsCard(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Header ──

  Widget _buildSectionHeader(String title, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          if (required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              if (required) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ],
      ),
    );
  }

  // ── Card Container ──

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Input Field ──

  Widget _buildInputField({
    required TextEditingController fieldController,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: fieldController,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }

  // ── Radio Option ──

  Widget _buildRadioOption<T>({
    required T value,
    required T groupValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required void Function(T?) onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withValues(alpha: 0.06) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.teal : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 18, color: isSelected ? Colors.teal : Colors.grey[500]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? Colors.teal : Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date Field ──

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[500], size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRequired ? const Color(0xFFEF4444) : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}  ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'Select date & time',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? Colors.grey[800] : Colors.grey[400],
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cards ──

  Widget _buildBasicInfoCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Basic Information', required: true),
        const SizedBox(height: 16),
        _buildFieldLabel('Coupon Name', required: true, subtitle: 'Enter a descriptive name for your coupon campaign.'),
        _buildInputField(
          fieldController: controller.nameController,
          hint: 'e.g., Summer Sale 2024',
          validator: (v) => controller.validateRequired(v, 'Coupon name'),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Description', subtitle: 'Brief description of this coupon campaign.'),
        _buildInputField(
          fieldController: controller.descriptionController,
          hint: 'Optional description for the coupon',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCouponTypeCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Coupon Type & Value', required: true),
        const SizedBox(height: 12),
        _buildFieldLabel('Coupon Type', required: true, subtitle: 'Choose between discount or wallet credit.'),
        Obx(
          () => Column(
            children: [
              _buildRadioOption(
                value: 'discount',
                groupValue: controller.selectedCouponType.value,
                title: 'Discount',
                subtitle: 'Percentage or fixed amount off',
                icon: Icons.percent,
                onChanged: (v) => controller.selectedCouponType.value = v!,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: 'wallet',
                groupValue: controller.selectedCouponType.value,
                title: 'Wallet Credit',
                subtitle: 'Add money to user wallet',
                icon: Icons.account_balance_wallet,
                onChanged: (v) => controller.selectedCouponType.value = v!,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => controller.selectedCouponType.value == 'discount'
              ? _buildDiscountFields()
              : _buildWalletField(),
        ),
      ],
    );
  }

  Widget _buildDiscountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Discount Type', required: true, subtitle: 'Choose percentage or fixed amount.'),
        Obx(
          () => Column(
            children: [
              _buildRadioOption(
                value: 'percentage',
                groupValue: controller.selectedDiscountType.value,
                title: 'Percentage (%)',
                subtitle: 'Percentage off (1-100)',
                icon: Icons.percent,
                onChanged: (v) => controller.selectedDiscountType.value = v!,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: 'fixed',
                groupValue: controller.selectedDiscountType.value,
                title: 'Fixed Amount (\$)',
                subtitle: 'Fixed amount off',
                icon: Icons.attach_money,
                onChanged: (v) => controller.selectedDiscountType.value = v!,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isPercent = controller.selectedDiscountType.value == 'percentage';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel(
                isPercent ? 'Discount Percentage' : 'Discount Amount',
                required: true,
                subtitle: isPercent ? 'Percentage off (1-100)' : 'Fixed discount amount.',
              ),
              _buildInputField(
                fieldController: controller.discountValueController,
                hint: isPercent ? '25' : '10.00',
                keyboardType: TextInputType.number,
                validator: controller.validateDiscountValue,
                prefixIcon: Icon(
                  isPercent ? Icons.percent : Icons.attach_money,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        _buildFieldLabel('Minimum Purchase', subtitle: 'Minimum order amount required (optional).'),
        _buildInputField(
          fieldController: controller.minimumAmountController,
          hint: '0.00',
          keyboardType: TextInputType.number,
          validator: (v) => controller.validateNumeric(v, 'Minimum amount'),
          prefixIcon: Icon(Icons.attach_money, color: Colors.grey[500], size: 20),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Maximum Discount', subtitle: 'Cap the maximum discount amount (optional).'),
        _buildInputField(
          fieldController: controller.maximumDiscountController,
          hint: '100.00',
          keyboardType: TextInputType.number,
          validator: (v) => controller.validateNumeric(v, 'Maximum discount'),
          prefixIcon: Icon(Icons.attach_money, color: Colors.grey[500], size: 20),
        ),
      ],
    );
  }

  Widget _buildWalletField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Wallet Credit Amount', required: true, subtitle: 'Amount to add to user wallet.'),
        _buildInputField(
          fieldController: controller.discountValueController,
          hint: '50.00',
          keyboardType: TextInputType.number,
          validator: controller.validateDiscountValue,
          prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.grey[500], size: 20),
        ),
      ],
    );
  }

  Widget _buildDiscountedItemsCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Discounted Items Settings'),
        const SizedBox(height: 4),
        Text(
          'Control whether this coupon applies to already-discounted items',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: controller.allowOnDiscountedItems.value
                  ? Colors.teal.withValues(alpha: 0.06)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: controller.allowOnDiscountedItems.value ? Colors.teal : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allow on Discounted Items',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Enable to apply coupon on items that already have a discount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.allowOnDiscountedItems.value,
                  onChanged: (val) => controller.allowOnDiscountedItems.value = val,
                  activeTrackColor: Colors.teal,
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => controller.allowOnDiscountedItems.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildFieldLabel(
                      'Discount Price Mode',
                      required: true,
                      subtitle: 'Choose which price the coupon discount applies to.',
                    ),
                    Column(
                      children: [
                        _buildRadioOption<String>(
                          value: 'original',
                          groupValue: controller.discountPriceMode.value,
                          title: 'Original Price',
                          subtitle: 'Apply on full price',
                          icon: Icons.price_check,
                          onChanged: (v) => controller.discountPriceMode.value = v!,
                        ),
                        const SizedBox(height: 12),
                        _buildRadioOption<String>(
                          value: 'discounted',
                          groupValue: controller.discountPriceMode.value,
                          title: 'Discounted Price',
                          subtitle: 'Apply on sale price',
                          icon: Icons.local_offer_outlined,
                          onChanged: (v) => controller.discountPriceMode.value = v!,
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildValidityCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Validity Period', required: true),
        const SizedBox(height: 16),
        Column(
          children: [
            Obx(
              () => _buildDateField(
                label: 'Start Date *',
                value: controller.startDate.value,
                onTap: () => controller.selectStartDate(Get.context!),
                isRequired: true,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildDateField(
                label: 'Expiry Date *',
                value: controller.expiryDate.value,
                onTap: () => controller.selectExpiryDate(Get.context!),
                isRequired: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreAvailabilityCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Store Availability'),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: [
              _buildRadioOption(
                value: true,
                groupValue: controller.isGlobal.value,
                title: 'Global',
                subtitle: 'Valid at all stores',
                icon: Icons.public,
                onChanged: (v) => controller.isGlobal.value = v!,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: false,
                groupValue: controller.isGlobal.value,
                title: 'Specific Stores',
                subtitle: 'Select specific stores',
                icon: Icons.store_outlined,
                onChanged: (v) {
                  controller.isGlobal.value = v!;
                  if (!v) {
                    controller.fetchShops();
                  }
                },
              ),
            ],
          ),
        ),
        Obx(
          () => !controller.isGlobal.value
              ? Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildShopSelection(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildShopSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.shopSearchController,
          decoration: InputDecoration(
            labelText: 'Search stores...',
            labelStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(() {
            if (controller.isLoadingShops.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }

            if (controller.availableShops.isEmpty) {
              return Center(
                child: Text('No stores found', style: TextStyle(color: Colors.grey[500])),
              );
            }

            return ListView.builder(
              itemCount: controller.availableShops.length,
              itemBuilder: (context, index) {
                final shop = controller.availableShops[index];
                return Obx(
                  () => CheckboxListTile(
                    title: Text(shop.name.toString(), style: const TextStyle(fontSize: 14)),
                    subtitle: shop.description != null
                        ? Text(shop.description!, style: TextStyle(fontSize: 12, color: Colors.grey[500]))
                        : null,
                    value: controller.isShopSelected(shop),
                    onChanged: (v) => controller.toggleShopSelection(shop),
                    dense: true,
                    activeColor: Colors.teal,
                  ),
                );
              },
            );
          }),
        ),
        Obx(
          () => controller.selectedShops.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${controller.selectedShops.length} store(s) selected',
                    style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCodeGenerationCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Coupon Code Generation', required: true),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: [
              _buildRadioOption(
                value: true,
                groupValue: controller.isAutoGenerate.value,
                title: 'Auto Generate',
                subtitle: 'Generate random codes',
                icon: Icons.auto_fix_high,
                onChanged: (v) => controller.isAutoGenerate.value = v!,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: false,
                groupValue: controller.isAutoGenerate.value,
                title: 'Manual',
                subtitle: 'Add custom codes',
                icon: Icons.edit,
                onChanged: (v) => controller.isAutoGenerate.value = v!,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => controller.isAutoGenerate.value
              ? _buildAutoGenerateSection()
              : _buildManualCodeSection(),
        ),
        const SizedBox(height: 16),
        _buildCodesList(),
      ],
    );
  }

  Widget _buildAutoGenerateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Number of Codes'),
        _buildInputField(
          fieldController: controller.codeCountController,
          hint: '1',
          keyboardType: TextInputType.number,
          validator: (v) {
            final count = int.tryParse(v ?? '');
            if (count == null || count <= 0 || count > 100) {
              return 'Enter a valid count (1-100)';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.generateCodes,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Generate', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildManualCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Custom Code'),
        _buildInputField(
          fieldController: controller.customCodeController,
          hint: 'e.g., SUMMER25',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final code = v.trim().toUpperCase();
            if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(code)) {
              return 'Only letters, numbers, and hyphens';
            }
            if (code.length < 3 || code.length > 20) {
              return 'Code must be 3-20 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.addCustomCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Code', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodesList() {
    return Obx(() {
      if (controller.generatedCodes.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Text('No codes generated yet', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.generatedCodes.length,
          itemBuilder: (context, index) {
            final code = controller.generatedCodes[index];
            return ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              title: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => controller.removeCode(code),
                color: const Color(0xFFEF4444),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildUsageLimitsCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Usage Limits'),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Total Usage Limit', subtitle: 'Maximum total uses (optional).'),
            _buildInputField(
              fieldController: controller.usageLimitController,
              hint: 'Unlimited',
              keyboardType: TextInputType.number,
              validator: (v) => controller.validateNumeric(v, 'Total usage limit'),
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Per User Limit', subtitle: 'Max uses per user (optional).'),
            _buildInputField(
              fieldController: controller.usageLimitPerUserController,
              hint: 'Unlimited',
              keyboardType: TextInputType.number,
              validator: (v) => controller.validateNumeric(v, 'Per user limit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _buildCardContainer(
      children: [
        _buildSectionHeader('Coupon Status'),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: [
              _buildRadioOption(
                value: 'active',
                groupValue: controller.selectedStatus.value,
                title: 'Active',
                subtitle: 'Coupon is available for use',
                icon: Icons.check_circle_outline,
                onChanged: (v) => controller.selectedStatus.value = v!,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: 'inactive',
                groupValue: controller.selectedStatus.value,
                title: 'Inactive',
                subtitle: 'Coupon is not available',
                icon: Icons.cancel_outlined,
                onChanged: (v) => controller.selectedStatus.value = v!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.grey[300]!),
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isCreatingCoupon.value ? null : controller.createCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: controller.isCreatingCoupon.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      controller.isEditMode ? 'Update Coupon' : 'Create Coupon',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
