// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/home/widgets/customer_service.dart';
import 'package:tjara/app/modules/services/model/sevices_model.dart';
import 'package:tjara/app/modules/services/service/service_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class ServicesController extends GetxController {
  final ServicesApiService _apiService = ServicesApiService();

  RxList<ServiceData> services = <ServiceData>[].obs;
  RxInt totalServices = 0.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  TextEditingController searchController = TextEditingController();
  RxList<ServiceData> filteredServices = <ServiceData>[].obs;

  // Filter states
  Rx<double?> minPrice = Rx<double?>(null);
  Rx<double?> maxPrice = Rx<double?>(null);
  RxString sortBy = ''.obs; // 'price', 'name', 'created_at'
  RxString sortOrder = 'asc'.obs; // 'asc' or 'desc'
  RxBool isFiltersApplied = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();

    // Listen to search changes
    searchController.addListener(() {
      filterServices(searchController.text);
    });
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final servicesData = await _apiService.fetchServices(
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        orderBy: sortBy.value.isNotEmpty ? sortBy.value : null,
        order: sortOrder.value,
      );
      update();
      services.value = servicesData.services?.data ?? [];
      totalServices.value = servicesData.services?.total ?? 0;
      filteredServices.value = services;
      update();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      filteredServices.value = services;
    } else {
      filteredServices.value =
          services
              .where(
                (service) => (service.name ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void applyFilters({
    double? newMinPrice,
    double? newMaxPrice,
    String? newSortBy,
    String? newSortOrder,
  }) {
    minPrice.value = newMinPrice;
    maxPrice.value = newMaxPrice;
    sortBy.value = newSortBy ?? '';
    sortOrder.value = newSortOrder ?? 'asc';
    isFiltersApplied.value =
        newMinPrice != null ||
        newMaxPrice != null ||
        (newSortBy != null && newSortBy.isNotEmpty);
    fetchServices();
  }

  void clearFilters() {
    minPrice.value = null;
    maxPrice.value = null;
    sortBy.value = '';
    sortOrder.value = 'asc';
    isFiltersApplied.value = false;
    fetchServices();
  }

  void showServiceDetails(ServiceData service) {
    Get.to(() => ServiceDetailScreen(service: service));
  }

  void showInquiryDialog(ServiceData service) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inquiry',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              service.name ?? 'Service',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  _buildTextField(
                    controller: nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message Field
                  _buildTextField(
                    controller: messageController,
                    label: 'Message',
                    hint: 'Describe what you need...',
                    icon: Icons.message_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting.value
                                ? null
                                : () async {
                                  if (formKey.currentState!.validate()) {
                                    isSubmitting.value = true;
                                    try {
                                      await _apiService.submitEnquiry(
                                        serviceId: service.id ?? '',
                                        fullName: nameController.text,
                                        phoneNumber: phoneController.text,
                                        serviceName: service.name ?? '',
                                        message: messageController.text,
                                      );
                                      Get.back();
                                      Get.snackbar(
                                        'Success',
                                        'Your inquiry has been submitted successfully!',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: 12,
                                      );
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        'Failed to submit inquiry. Please try again.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        margin: const EdgeInsets.all(16),
                                        borderRadius: 12,
                                      );
                                    } finally {
                                      isSubmitting.value = false;
                                    }
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfea52d),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child:
                            isSubmitting.value
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit Inquiry',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // WhatsApp Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        _openWhatsApp(service);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF25D366)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/whatsapp.png',
                            width: 24,
                            height: 24,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.chat,
                                  color: Color(0xFF25D366),
                                  size: 24,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Chat on WhatsApp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF25D366),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFfea52d)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _openWhatsApp(ServiceData service) async {
    // Get WhatsApp number from service shop meta if available
    final String? whatsappNumber =
        service.shop?.shop?.meta?.whatsapp?.toString();
    final String? phoneNumber = service.shop?.shop?.meta?.phone;

    // Use CustomerService helper if available
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      CustomerService.openWhatsApp(
        phoneNumber: phoneNumber ?? '',
        whatsapp: whatsappNumber,
      );
    } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
      CustomerService.openWhatsApp(phoneNumber: phoneNumber);
    } else {
      // Fallback to a default number if none available
      const String defaultNumber = '+96170123456'; // Replace with actual number
      final Uri whatsappUri = Uri.parse('https://wa.me/$defaultNumber');
      try {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void showFilterBottomSheet() {
    final tempMinPrice = TextEditingController(
      text: minPrice.value?.toInt().toString() ?? '',
    );
    final tempMaxPrice = TextEditingController(
      text: maxPrice.value?.toInt().toString() ?? '',
    );
    final tempSortBy = sortBy.value.obs;
    final tempSortOrder = sortOrder.value.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      tempMinPrice.clear();
                      tempMaxPrice.clear();
                      tempSortBy.value = '';
                      tempSortOrder.value = 'asc';
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFFfea52d)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tempMinPrice,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Min',
                        prefixText: '\$ ',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFfea52d),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('to', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: tempMaxPrice,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Max',
                        prefixText: '\$ ',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFfea52d),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sort By
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSortChip('Price', 'price', tempSortBy),
                    _buildSortChip('Name', 'name', tempSortBy),
                    _buildSortChip('Newest', 'created_at', tempSortBy),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sort Order
              Obx(
                () =>
                    tempSortBy.value.isNotEmpty
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildOrderChip(
                                    'Low to High',
                                    'asc',
                                    tempSortOrder,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildOrderChip(
                                    'High to Low',
                                    'desc',
                                    tempSortOrder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    applyFilters(
                      newMinPrice:
                          tempMinPrice.text.isNotEmpty
                              ? double.tryParse(tempMinPrice.text)
                              : null,
                      newMaxPrice:
                          tempMaxPrice.text.isNotEmpty
                              ? double.tryParse(tempMaxPrice.text)
                              : null,
                      newSortBy:
                          tempSortBy.value.isNotEmpty ? tempSortBy.value : null,
                      newSortOrder: tempSortOrder.value,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfea52d),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSortChip(String label, String value, RxString selectedValue) {
    final isSelected = selectedValue.value == value;
    return GestureDetector(
      onTap: () {
        if (selectedValue.value == value) {
          selectedValue.value = '';
        } else {
          selectedValue.value = value;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFfea52d) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderChip(String label, String value, RxString selectedValue) {
    final isSelected = selectedValue.value == value;
    return GestureDetector(
      onTap: () => selectedValue.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFfea52d) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class ServiceDetailScreen extends StatelessWidget {
  final ServiceData service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar with Image
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFFfea52d),
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Service Image
                  service.thumbnail?.media?.url != null
                      ? Image.network(
                        service.thumbnail!.media!.url!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey.shade300,
                              child: Image.asset('assets/images/simple.png'),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey.shade500,
                        ),
                      ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFfea52d),
                                    Color(0xFFf97316),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.miscellaneous_services,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                service.name ?? 'Service',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 20),

                        // Description Section
                        const Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: Color(0xFFfea52d),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Service Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data:
                              service.description ?? 'No description available',
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              color: Colors.grey.shade700,
                              lineHeight: const LineHeight(1.5),
                            ),
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features Card (if applicable)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFFfea52d),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Service Features',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem('Professional Service'),
                        _buildFeatureItem('Verified Provider'),
                        _buildFeatureItem('Quality Guaranteed'),
                        _buildFeatureItem('24/7 Support'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Inquiry Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.showInquiryDialog(service),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfea52d),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Inquire Now',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFfea52d).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFFfea52d), size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
