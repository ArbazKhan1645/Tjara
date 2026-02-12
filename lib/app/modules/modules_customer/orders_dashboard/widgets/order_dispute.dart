import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/widgets/admin_dashboard_theme.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class OrdersDisputeOverview extends StatefulWidget {
  const OrdersDisputeOverview({super.key});

  @override
  State<OrdersDisputeOverview> createState() => _OrdersDisputeOverviewState();
}

class _OrdersDisputeOverviewState extends State<OrdersDisputeOverview> {
  final OrdersDashboardController _controller =
      Get.find<OrdersDashboardController>();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedReason;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Damaged Item',
    'Wrong Item Sent',
    'Late Delivery',
    'Item Not Received',
    'Quality Issue',
    'Other',
  ];

  // Safe getters
  String get _userId =>
      AuthService.instance.authCustomer?.user?.id?.toString() ?? '';
  String get _orderId => _controller.selectedOrder.value?.id?.toString() ?? '';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReason == null) {
      _showSnackBar('Please select a reason for dispute', isSuccess: false);
      return;
    }
    if (_isSubmitting) return;

    try {
      setState(() => _isSubmitting = true);

      await _controller.addOrderDispute(
        _orderId,
        context,
        _userId,
        _selectedReason ?? '',
        _descriptionController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar('Dispute submitted successfully', isSuccess: true);
      _controller.setisSHowndispute(false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to submit dispute', isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor:
            isSuccess ? AdminDashboardTheme.success : AdminDashboardTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
      ),
    );
  }

  void _navigateBack() {
    _controller.setisSHowndispute(false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AdminDashboardTheme.spacingMd),
          _DisputeReasonCard(
            selectedReason: _selectedReason,
            reasons: _reasons,
            onReasonChanged: (value) {
              setState(() => _selectedReason = value);
            },
          ),
          const SizedBox(height: AdminDashboardTheme.spacingLg),
          _DisputeDetailsCard(controller: _descriptionController),
          const SizedBox(height: AdminDashboardTheme.spacingXl),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AdminDashboardTheme.spacingMd),
        const Text(
          'File a Dispute',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          child: InkWell(
            onTap: _navigateBack,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
            child: const Padding(
              padding: EdgeInsets.all(AdminDashboardTheme.spacingSm),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateBack,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(
                    AdminDashboardTheme.radiusMd,
                  ),
                  border: Border.all(color: AdminDashboardTheme.border),
                ),
                child: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AdminDashboardTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AdminDashboardTheme.spacingMd),
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSubmitting ? null : _submitDispute,
              borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color:
                      _isSubmitting
                          ? AdminDashboardTheme.surfaceSecondary
                          : AdminDashboardTheme.error,
                  borderRadius: BorderRadius.circular(
                    AdminDashboardTheme.radiusMd,
                  ),
                  boxShadow:
                      _isSubmitting
                          ? null
                          : AdminDashboardTheme.shadowColored(
                            AdminDashboardTheme.error,
                          ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AdminDashboardTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Dispute',
                      style: TextStyle(
                        color:
                            _isSubmitting
                                ? AdminDashboardTheme.textSecondary
                                : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
}

/// Dispute Reason Selection Card
class _DisputeReasonCard extends StatelessWidget {
  final String? selectedReason;
  final List<String> reasons;
  final ValueChanged<String?> onReasonChanged;

  const _DisputeReasonCard({
    required this.selectedReason,
    required this.reasons,
    required this.onReasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminDashboardTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.help_outline_rounded,
              title: 'Dispute Reason',
            ),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildRequiredBadge(),
            const SizedBox(height: AdminDashboardTheme.spacingSm),
            const Text(
              'Select the primary reason for filing this dispute. This helps us categorize and prioritize your case.',
              style: AdminDashboardTheme.bodyMedium,
            ),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildReasonDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.errorLight,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: Icon(icon, color: AdminDashboardTheme.error, size: 18),
        ),
        const SizedBox(width: AdminDashboardTheme.spacingMd),
        Text(title, style: AdminDashboardTheme.headingSmall),
      ],
    );
  }

  Widget _buildRequiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDashboardTheme.spacingSm,
        vertical: AdminDashboardTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.warningLight,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 12,
            color: AdminDashboardTheme.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'Required',
            style: AdminDashboardTheme.labelMedium.copyWith(
              color: AdminDashboardTheme.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        border: Border.all(
          color:
              selectedReason != null
                  ? AdminDashboardTheme.primary
                  : AdminDashboardTheme.border,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedReason,
        hint: const Text(
          'Select a reason',
          style: AdminDashboardTheme.bodyMedium,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_rounded,
            color:
                selectedReason != null
                    ? AdminDashboardTheme.primary
                    : AdminDashboardTheme.textTertiary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AdminDashboardTheme.spacingLg,
            vertical: AdminDashboardTheme.spacingMd,
          ),
        ),
        dropdownColor: AdminDashboardTheme.surface,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
        items:
            reasons.map((String reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason, style: AdminDashboardTheme.bodyLarge),
              );
            }).toList(),
        onChanged: onReasonChanged,
      ),
    );
  }
}

/// Dispute Details Card with text input
class _DisputeDetailsCard extends StatelessWidget {
  final TextEditingController controller;

  const _DisputeDetailsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminDashboardTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.description_rounded,
              title: 'Dispute Details',
            ),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildRequiredBadge(),
            const SizedBox(height: AdminDashboardTheme.spacingSm),
            const Text(
              'Provide a detailed description of the issue. Include relevant information such as dates, communication with the seller, and any attempts to resolve the issue.',
              style: AdminDashboardTheme.bodyMedium,
            ),
            const SizedBox(height: AdminDashboardTheme.spacingLg),
            _buildTextArea(),
            const SizedBox(height: AdminDashboardTheme.spacingSm),
            _buildCharacterCount(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AdminDashboardTheme.spacingSm),
          decoration: BoxDecoration(
            color: AdminDashboardTheme.errorLight,
            borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
          ),
          child: Icon(icon, color: AdminDashboardTheme.error, size: 18),
        ),
        const SizedBox(width: AdminDashboardTheme.spacingMd),
        Text(title, style: AdminDashboardTheme.headingSmall),
      ],
    );
  }

  Widget _buildRequiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDashboardTheme.spacingSm,
        vertical: AdminDashboardTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.warningLight,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 12,
            color: AdminDashboardTheme.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'Required',
            style: AdminDashboardTheme.labelMedium.copyWith(
              color: AdminDashboardTheme.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea() {
    return TextFormField(
      controller: controller,
      maxLines: 6,
      maxLength: 1000,
      style: AdminDashboardTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Describe your issue in detail...',
        hintStyle: AdminDashboardTheme.bodyMedium,
        filled: true,
        fillColor: AdminDashboardTheme.surfaceSecondary,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
          borderSide: const BorderSide(color: AdminDashboardTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
          borderSide: const BorderSide(color: AdminDashboardTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
          borderSide: const BorderSide(
            color: AdminDashboardTheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminDashboardTheme.radiusMd),
          borderSide: const BorderSide(color: AdminDashboardTheme.error),
        ),
        contentPadding: const EdgeInsets.all(AdminDashboardTheme.spacingLg),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please provide a description of your issue';
        }
        if (value.trim().length < 20) {
          return 'Description must be at least 20 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCharacterCount() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final count = value.text.length;
        final isNearLimit = count > 800;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$count / 1000',
              style: AdminDashboardTheme.bodySmall.copyWith(
                color:
                    isNearLimit
                        ? AdminDashboardTheme.warning
                        : AdminDashboardTheme.textTertiary,
              ),
            ),
          ],
        );
      },
    );
  }
}
