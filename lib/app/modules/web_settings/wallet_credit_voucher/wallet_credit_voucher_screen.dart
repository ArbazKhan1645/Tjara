import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/wallet_credit_voucher/wallet_credit_voucher_controller.dart';
import 'package:tjara/app/modules/web_settings/wallet_credit_voucher/wallet_credit_voucher_service.dart';

class WalletCreditVoucherScreen extends StatelessWidget {
  const WalletCreditVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletCreditVoucherController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: WebSettingsAppBar(
        title: 'Wallet Credit Voucher',
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: controller.saveSettings,
                    tooltip: 'Save Settings',
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ShimmerLoading();
        }

        if (controller.errorMessage.value != null) {
          return WebSettingsErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.fetchSettings,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSettings,
          color: WebSettingsTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                const WebSettingsHeaderCard(
                  title: 'Wallet Credit Voucher',
                  description: 'Configure automatic wallet credit application and notification settings for orders.',
                  icon: Icons.account_balance_wallet_rounded,
                  badge: 'Optional',
                ),

                // Main Settings Card
                _buildMainSettingsCard(controller),

                // Disabled Message
                Obx(() {
                  if (!controller.isEnabled.value) {
                    return _buildDisabledMessage();
                  }
                  return const SizedBox.shrink();
                }),

                // Save Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => WebSettingsPrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.save_rounded,
                      isLoading: controller.isSaving.value,
                      onPressed: controller.saveSettings,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMainSettingsCard(WalletCreditVoucherController controller) {
    return WebSettingsSectionCard(
      title: 'Voucher Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable Toggle
          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Automatic Wallet Credit Voucher',
              subtitle: 'Automatically apply vouchers to eligible orders',
              value: controller.isEnabled.value,
              onChanged: (value) => controller.isEnabled.value = value,
              icon: Icons.toggle_on_rounded,
            ),
          ),

          // Show other settings only when enabled
          Obx(() {
            if (!controller.isEnabled.value) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),

                // Select Wallet Credit Voucher
                const Text(
                  'Select Wallet Credit Voucher',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WebSettingsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _CouponSearchableDropdown(controller: controller),

                // Selected coupons chips
                Obx(() {
                  if (controller.selectedCoupons.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedCoupons
                          .map(
                            (coupon) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: WebSettingsTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: WebSettingsTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coupon.displayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: WebSettingsTheme.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => controller.removeCoupon(coupon.id),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: WebSettingsTheme.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Applied Notification Section
                _buildNotificationSection(controller),

                const SizedBox(height: 16),

                // Placeholders Info Card
                _buildPlaceholdersCard(controller),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(WalletCreditVoucherController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebSettingsTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: WebSettingsTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Applied Notification',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification Message
          WebSettingsTextField(
            label: 'Notification Message',
            controller: controller.notificationTextController,
            hint: 'Enter notification message...',
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Email Subject
          WebSettingsTextField(
            label: 'Email Subject',
            controller: controller.emailSubjectController,
            hint: 'Voucher Received - You\'ve received a voucher!',
          ),

          const SizedBox(height: 16),

          // Email Body
          WebSettingsTextField(
            label: 'Email Body',
            controller: controller.emailBodyController,
            hint: 'Enter email body...',
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          // Notification Type
          Obx(
            () => WebSettingsRadioGroup(
              label: 'Send Notification Via',
              value: controller.notificationSendBy.value,
              options: controller.notificationOptions,
              onChanged: (value) => controller.notificationSendBy.value = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholdersCard(WalletCreditVoucherController controller) {
    return WebSettingsInfoCard(
      title: 'Available Voucher Placeholders',
      items: controller.placeholders,
    );
  }

  Widget _buildDisabledMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: WebSettingsTheme.warningColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable Automatic Wallet Credit Voucher to configure voucher and notification settings.',
              style: TextStyle(
                color: WebSettingsTheme.warningColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer Loading Widget
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Card shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Button shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coupon Searchable Dropdown
class _CouponSearchableDropdown extends StatefulWidget {
  final WalletCreditVoucherController controller;

  const _CouponSearchableDropdown({required this.controller});

  @override
  State<_CouponSearchableDropdown> createState() =>
      _CouponSearchableDropdownState();
}

class _CouponSearchableDropdownState extends State<_CouponSearchableDropdown> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isOpen = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isOpen) {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isOpen = true);
    widget.controller.searchCoupons('');
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
      _searchController.clear();
    });
  }

  void _search(String query) {
    widget.controller.searchCoupons(query);
  }

  void _selectCoupon(CouponItem coupon) {
    widget.controller.addCoupon(coupon);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display current selection
        InkWell(
          onTap: () {
            if (_isOpen) {
              _closeDropdown();
            } else {
              _openDropdown();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: WebSettingsTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen
                    ? WebSettingsTheme.primaryColor
                    : WebSettingsTheme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select a coupon...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: WebSettingsTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Dropdown content
        if (_isOpen) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: WebSettingsTheme.dividerColor),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search coupons...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: WebSettingsTheme.textSecondary,
                      ),
                      suffixIcon: Obx(
                        () => widget.controller.isSearchingCoupons.value
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: WebSettingsTheme.primaryColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: WebSettingsTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: _search,
                  ),
                ),

                const Divider(height: 1, color: WebSettingsTheme.dividerColor),

                // Results list
                Flexible(
                  child: Obx(
                    () => ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        // Search results
                        ...widget.controller.couponSearchResults.map((coupon) {
                          final isSelected =
                              widget.controller.isCouponSelected(coupon.id);
                          return ListTile(
                            dense: true,
                            title: Text(
                              coupon.displayName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? WebSettingsTheme.textSecondary
                                    : WebSettingsTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: coupon.discountValue != null
                                ? Text(
                                    '${coupon.discountType == 'percentage' ? '${coupon.discountValue}%' : '\$${coupon.discountValue}'} discount',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: WebSettingsTheme.textSecondary,
                                    ),
                                  )
                                : null,
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: WebSettingsTheme.successColor,
                                    size: 20,
                                  )
                                : null,
                            onTap: isSelected
                                ? null
                                : () => _selectCoupon(coupon),
                          );
                        }),

                        // Empty state
                        if (widget.controller.couponSearchResults.isEmpty &&
                            !widget.controller.isSearchingCoupons.value)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  color: WebSettingsTheme.textSecondary,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No coupons found',
                                  style: TextStyle(
                                    color: WebSettingsTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
