// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/home/screens/quick_buy_checkout_service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

/// Shows the quick buy checkout bottom sheet
/// Returns true if order was placed successfully, false otherwise
Future<bool> showQuickBuyCheckoutSheet({
  required BuildContext context,
  required String productId,
  required String shopId,
  required String productName,
  required String? productImageUrl,
  required double price,
  required double? shippingFee,
  required int quantity,
  String? variationId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => _QuickBuyCheckoutSheet(
          productId: productId,
          shopId: shopId,
          productName: productName,
          productImageUrl: productImageUrl,
          price: price,
          shippingFee: shippingFee,
          quantity: quantity,
          variationId: variationId,
        ),
  );

  return result ?? false;
}

class _QuickBuyCheckoutSheet extends StatefulWidget {
  final String productId;
  final String shopId;
  final String productName;
  final String? productImageUrl;
  final double price;
  final double? shippingFee;
  final int quantity;
  final String? variationId;

  const _QuickBuyCheckoutSheet({
    required this.productId,
    required this.shopId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.shippingFee,
    required this.quantity,
    this.variationId,
  });

  @override
  State<_QuickBuyCheckoutSheet> createState() => _QuickBuyCheckoutSheetState();
}

class _QuickBuyCheckoutSheetState extends State<_QuickBuyCheckoutSheet>
    with SingleTickerProviderStateMixin {
  // Theme colors
  static const Color _primaryColor = Colors.teal;
  static const Color _accentColor = Color(0xFFfda730);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFE53935);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _bgColor = Color(0xFFF8F9FA);

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetAddressController;
  late TextEditingController _postalCodeController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // State
  bool _isContactExpanded = true;
  bool _isPlacingOrder = false;
  bool _isUpdatingAddress = false;
  bool _orderPlaced = false;
  String? _orderId;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  void _initControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _streetAddressController = TextEditingController();
    _postalCodeController = TextEditingController();
  }

  void _loadUserData() {
    try {
      final authService = Get.find<AuthService>();
      final user = authService.authCustomer?.user;
      if (user != null) {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _phoneNumber = user.phone ?? '';
      }
    } catch (e) {
      // Auth service not available
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    _postalCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? get _userId {
    try {
      return Get.find<AuthService>().authCustomer?.user?.id;
    } catch (e) {
      return null;
    }
  }

  double get _totalPrice {
    final subtotal = widget.price * widget.quantity;
    final shipping = widget.shippingFee ?? 0;
    return subtotal + shipping;
  }

  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneNumber.isNotEmpty;
  }

  Future<void> _placeOrder() async {
    if (!_isFormValid) {
      _showSnackbar(
        'Missing Information',
        'Please fill all required fields.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    HapticFeedback.mediumImpact();

    final userDetails = QuickBuyUserDetails(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneNumber,
    );

    final response = await QuickBuyCheckoutService.insertOrder(
      productId: widget.productId,
      shopId: widget.shopId,
      quantity: widget.quantity,
      userDetails: userDetails,
      variationId: widget.variationId,
      userId: _userId,
    );

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    if (response.success) {
      HapticFeedback.heavyImpact();
      setState(() {
        _orderPlaced = true;
        _orderId = response.firstOrderId;
      });
    } else {
      _showSnackbar(
        'Order Failed',
        response.errorMessage ?? 'Failed to place order',
        isError: true,
      );
    }
  }

  Future<void> _updateAddress() async {
    if (_orderId == null) return;

    final streetAddress = _streetAddressController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    if (streetAddress.isEmpty) {
      _showSnackbar(
        'Missing Address',
        'Please enter your street address.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isUpdatingAddress = true;
    });

    HapticFeedback.lightImpact();

    final response = await QuickBuyCheckoutService.updateOrderAddress(
      orderId: _orderId!,
      streetAddress: streetAddress,
      postalCode: postalCode,
      userId: _userId,
    );

    if (!mounted) return;

    setState(() {
      _isUpdatingAddress = false;
    });

    if (response.success) {
      HapticFeedback.mediumImpact();
      _showSnackbar(
        'Address Updated',
        'Your shipping address has been saved.',
        isError: false,
      );
      Navigator.of(context).pop(true);
    } else {
      _showSnackbar(
        'Update Failed',
        response.errorMessage ?? 'Failed to update address',
        isError: true,
      );
    }
  }

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? _errorColor : _successColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Opacity(opacity: _slideAnimation.value, child: child),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child:
                    _orderPlaced
                        ? _buildSuccessContent()
                        : _buildCheckoutContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductHeader(),
        const SizedBox(height: 16),
        _buildContactSection(),
        const SizedBox(height: 16),
        _buildShippingSection(),
        const SizedBox(height: 16),
        _buildPaymentSection(),
        const SizedBox(height: 16),
        _buildPriceSummary(),
        const SizedBox(height: 24),
        _buildPlaceOrderButton(),
        const SizedBox(height: 16),
        _buildTermsText(),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                widget.productImageUrl != null
                    ? Image.network(
                      widget.productImageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                    : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${widget.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qty: ${widget.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isContactExpanded = !_isContactExpanded);
            },
            child: Row(
              children: [
                const Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_firstNameController.text} ${_lastNameController.text}'
                        .trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _isContactExpanded ? 'HIDE' : 'SHOW',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
          _isContactExpanded ? _buildContactForm() : const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildPhoneField()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isContactExpanded = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Contact Info',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
            children:
                isRequired
                    ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: _errorColor),
                      ),
                    ]
                    : null,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryColor, width: 1.5),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Phone',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: _errorColor)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryColor, width: 1.5),
            ),
          ),
          onChanged: (phone) {
            _phoneNumber = phone;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildShippingSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Ship to',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Address will be added after order',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Pay with',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments_outlined, size: 18, color: _primaryColor),
                SizedBox(width: 6),
                Text(
                  'Cash On Delivery',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildPriceRow(
              'PRICE:',
              '\$${(widget.price * widget.quantity).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              'DELIVERY:',
              '\$${(widget.shippingFee ?? 0).toStringAsFixed(2)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _buildPriceRow(
              'TOTAL:',
              '\$${_totalPrice.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? _primaryColor : _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isPlacingOrder || !_isFormValid ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child:
              _isPlacingOrder
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                  : const Text(
                    'Place your order',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'By placing your order, you agree to ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            children: [
              const TextSpan(
                text: "Tjara's terms and conditions",
                style: TextStyle(
                  fontSize: 12,
                  color: _primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUCCESS CONTENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccessContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Icon(Icons.close, size: 24, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: _successColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Order Placed!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your order has been confirmed ',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const Text('', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 32),
          _buildAddressForm(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Delivery Address (Required)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _streetAddressController,
            label: 'Street Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'City',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: _errorColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select City',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUpdatingAddress ? null : _updateAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  _isUpdatingAddress
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'Update Shipping Address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
