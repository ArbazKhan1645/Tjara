// pages/add_coupon_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_admin/admin/coupens/edit_controller.dart';

class AddCouponPage extends StatelessWidget {
  final EditCouponController controller = Get.put(EditCouponController());

  AddCouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add New Coupon'),
        backgroundColor: const Color(0xFFF97316),
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
              _buildBasicInformationCard(),
              const SizedBox(height: 16),
              _buildCouponTypeCard(),
              const SizedBox(height: 16),
              _buildValidityPeriodCard(),
              const SizedBox(height: 16),
              _buildStoreAvailabilityCard(),
              const SizedBox(height: 16),
              _buildCouponCodeGenerationCard(),
              const SizedBox(height: 16),
              _buildUsageLimitsCard(),
              const SizedBox(height: 16),
              _buildCouponStatusCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformationCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: controller.nameController,
              label: 'Coupon Name',
              hint: 'e.g., Summer Sale 2024',
              isRequired: true,
              validator:
                  (value) => controller.validateRequired(value, 'Coupon name'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.descriptionController,
              label: 'Description',
              hint: 'Optional description for the coupon',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponTypeCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Coupon Type & Value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCouponTypeSelector(),
            const SizedBox(height: 16),
            Obx(
              () =>
                  controller.selectedCouponType.value == 'discount'
                      ? _buildDiscountSection()
                      : _buildWalletCreditSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponTypeSelector() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildRadioOption(
              value: 'discount',
              groupValue: controller.selectedCouponType.value,
              title: 'Discount',
              subtitle: 'Percentage or fixed amount off',
              icon: Icons.percent,
              onChanged:
                  (value) => controller.selectedCouponType.value = value!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRadioOption(
              value: 'wallet',
              groupValue: controller.selectedCouponType.value,
              title: 'Wallet Credit',
              subtitle: 'Add money to user wallet',
              icon: Icons.account_balance_wallet,
              onChanged:
                  (value) => controller.selectedCouponType.value = value!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      children: [
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  value: 'percentage',
                  groupValue: controller.selectedDiscountType.value,
                  title: 'Percentage (%)',
                  subtitle: 'Percentage off',
                  icon: Icons.percent,
                  onChanged:
                      (value) => controller.selectedDiscountType.value = value!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  value: 'fixed',
                  groupValue: controller.selectedDiscountType.value,
                  title: 'Fixed Amount (\$)',
                  subtitle: 'Fixed amount off',
                  icon: Icons.attach_money,
                  onChanged:
                      (value) => controller.selectedDiscountType.value = value!,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.discountValueController,
                label: 'Discount Value',
                hint: '25',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: controller.validateDiscountValue,
                prefixIcon: Obx(
                  () => Icon(
                    controller.selectedDiscountType.value == 'percentage'
                        ? Icons.percent
                        : Icons.attach_money,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.maximumDiscountController,
                label: 'Maximum Discount',
                hint: '100.00',
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        controller.validateNumeric(value, 'Maximum discount'),
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.minimumAmountController,
          label: 'Minimum Purchase Amount',
          hint: '0.00',
          keyboardType: TextInputType.number,
          validator:
              (value) => controller.validateNumeric(value, 'Minimum amount'),
          prefixIcon: Icon(Icons.shopping_cart, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWalletCreditSection() {
    return _buildTextField(
      controller: controller.discountValueController,
      label: 'Wallet Credit Amount',
      hint: '50.00',
      keyboardType: TextInputType.number,
      isRequired: true,
      validator: controller.validateDiscountValue,
      prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.grey[600]),
    );
  }

  Widget _buildValidityPeriodCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Validity Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Start Date',
                    value: controller.startDate.value,
                    onTap: () => controller.selectStartDate(Get.context!),
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Expiry Date',
                    value: controller.expiryDate.value,
                    onTap: () => controller.selectExpiryDate(Get.context!),
                    isRequired: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreAvailabilityCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.store, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Store Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildStoreSelector(),
            Obx(
              () =>
                  !controller.isGlobal.value
                      ? Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildShopSelection(),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelector() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildRadioOption(
              value: true,
              groupValue: controller.isGlobal.value,
              title: 'Global',
              subtitle: 'Valid at all stores',
              icon: Icons.public,
              onChanged: (value) => controller.isGlobal.value = value!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRadioOption(
              value: false,
              groupValue: controller.isGlobal.value,
              title: 'Specific Stores',
              subtitle: 'Select specific stores',
              icon: Icons.store_outlined,
              onChanged: (value) {
                controller.isGlobal.value = value!;
                if (!value) {
                  controller.fetchShops();
                }
              },
            ),
          ),
        ],
      ),
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
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() {
            if (controller.isLoadingShops.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.availableShops.isEmpty) {
              return Center(
                child: Text(
                  'No stores found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return ListView.builder(
              itemCount: controller.availableShops.length,
              itemBuilder: (context, index) {
                final shop = controller.availableShops[index];
                return Obx(
                  () => CheckboxListTile(
                    title: Text(shop.name.toString()),
                    subtitle:
                        shop.description != null
                            ? Text(shop.description!)
                            : null,
                    value: controller.isShopSelected(shop),
                    onChanged: (value) => controller.toggleShopSelection(shop),
                    dense: true,
                  ),
                );
              },
            );
          }),
        ),
        Obx(
          () =>
              controller.selectedShops.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${controller.selectedShops.length} store(s) selected',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCouponCodeGenerationCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Coupon Code Generation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCodeGenerationOptions(),
            const SizedBox(height: 16),
            Obx(
              () =>
                  controller.isAutoGenerate.value
                      ? _buildAutoGenerateSection()
                      : _buildManualCodeSection(),
            ),
            const SizedBox(height: 16),
            _buildGeneratedCodesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeGenerationOptions() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildRadioOption(
              value: true,
              groupValue: controller.isAutoGenerate.value,
              title: 'Auto Generate',
              subtitle: 'Generate random codes',
              icon: Icons.auto_fix_high,
              onChanged: (value) => controller.isAutoGenerate.value = value!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildRadioOption(
              value: false,
              groupValue: controller.isAutoGenerate.value,
              title: 'Manual',
              subtitle: 'Add custom codes',
              icon: Icons.edit,
              onChanged: (value) => controller.isAutoGenerate.value = value!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoGenerateSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.codeCountController,
            label: 'Number of Codes',
            hint: '1',
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value ?? '');
              if (count == null || count <= 0 || count > 100) {
                return 'Enter a valid count (1-100)';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: controller.generateCodes,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Generate Codes'),
        ),
      ],
    );
  }

  Widget _buildManualCodeSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller.customCodeController,
            label: 'Custom Code',
            hint: 'e.g., TIAFAID_SUMMER25, etc',
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final code = value.trim().toUpperCase();
              if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(code)) {
                return 'Only letters, numbers, and hyphens allowed';
              }
              if (code.length < 3 || code.length > 20) {
                return 'Code must be 3-20 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: controller.addCustomCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add Code'),
        ),
      ],
    );
  }

  Widget _buildGeneratedCodesList() {
    return Obx(() {
      if (controller.generatedCodes.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'No codes generated yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => controller.removeCode(code),
                color: Colors.red[600],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildUsageLimitsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Usage Limits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.usageLimitController,
                    label: 'Total Usage Limit',
                    hint: 'Maximum total uses (optional)',
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => controller.validateNumeric(
                          value,
                          'Total usage limit',
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: controller.usageLimitPerUserController,
                    label: 'Per User Limit',
                    hint: 'Maximum uses per user (optional)',
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            controller.validateNumeric(value, 'Per user limit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponStatusCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Separate container with padding from all sides
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.toggle_on, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Coupon Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      value: 'active',
                      groupValue: controller.selectedStatus.value,
                      title: 'Active',
                      subtitle: 'Coupon is available for use',
                      icon: Icons.check_circle,
                      onChanged:
                          (value) => controller.selectedStatus.value = value!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRadioOption(
                      value: 'inactive',
                      groupValue: controller.selectedStatus.value,
                      title: 'Inactive',
                      subtitle: 'Coupon is not available',
                      icon: Icons.cancel,
                      onChanged:
                          (value) => controller.selectedStatus.value = value!,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isCreatingCoupon.value
                      ? null
                      : controller.createCoupon,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  controller.isCreatingCoupon.value
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Create Coupon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: TextStyle(
          color: isRequired ? Colors.red[600] : Colors.grey[600],
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color:
              isSelected
                  ? const Color(0xFFF97316).withOpacity(0.1)
                  : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? const Color(0xFFF97316) : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Radio<T>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFF97316),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFFF97316) : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRequired ? '$label *' : label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRequired ? Colors.red[600] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'Select date and time',
                    style: TextStyle(
                      color: value != null ? Colors.black87 : Colors.grey[500],
                      fontWeight:
                          value != null ? FontWeight.w500 : FontWeight.normal,
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
}
