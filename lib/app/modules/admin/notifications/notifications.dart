import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';

// Controller for managing notification form state
class NotificationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var selectedUserType = 'Send to all users'.obs;

  // User type options
  final userTypes = [
    'Send to all users',
    'Only Sellers',
    'Only Admins',
    'Only Customers',
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize URL placeholder
    urlController.text = 'https://www.tjara.com/';
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    super.dispose();
  }

  // Method to submit notification
  Future<void> submitNotification() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'url': urlController.text.trim(),
        'status': _getStatusFromUserType(),
      };

      // Make API call
      final response = await http.post(
        Uri.parse('https://api.libanbuy.com/api/notification/insert'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final responseData = json.decode(response.body);

        Get.snackbar(
          'Success',
          'Notification created successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Clear form
        _clearForm();
      } else {
        // Server error
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to create notification';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          // Handle validation errors
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.first ?? errorMessage;
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Network or other errors
      String errorMessage = 'Network error occurred';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response format';
      } else {
        errorMessage = 'An unexpected error occurred';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel and clear form
  void cancelForm() {
    _clearForm();
    Get.back();
  }

  // Private helper methods
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    urlController.text = 'https://www.tjara.com/';
    selectedUserType.value = 'Send to all users';
  }

  String _getStatusFromUserType() {
    switch (selectedUserType.value) {
      case 'Only Sellers':
        return 'sellers';
      case 'Only Admins':
        return 'admins';
      case 'Only Customers':
        return 'customers';
      default:
        return 'all';
    }
  }
}

// Main notification form screen
class NotificationFormScreen extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Send notification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Notification Information Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header - Separate container with padding from all sides
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Notification Information',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Form content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: controller.formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Notification Title
                                      _buildFormField(
                                        label: 'Notification Title',
                                        isRequired: true,
                                        hint:
                                            'Enter the unique name of your notification. Make it them descriptive and easy to remember for customers.',
                                        child: TextFormField(
                                          controller:
                                              controller.titleController,
                                          decoration: InputDecoration(
                                            hintText: 'Notification Title',
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFF97316),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Notification title is required';
                                            }
                                            if (value.length > 1000) {
                                              return 'Title must be less than 1000 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Redirection URL
                                      _buildFormField(
                                        label: 'Redirection Url',
                                        hint:
                                            'Add the redirection url here, where users will be redirected to, when notification is clicked.',
                                        child: TextFormField(
                                          controller: controller.urlController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'https://www.tjara.com/*******',
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFF97316),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value != null &&
                                                value.trim().isNotEmpty) {
                                              if (value.length > 1000) {
                                                return 'URL must be less than 1000 characters';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Send to dropdown
                                      _buildFormField(
                                        label: 'Send to',
                                        hint:
                                            'Select type of users you want to send this notification to.',
                                        child: Obx(
                                          () => Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value:
                                                    controller
                                                        .selectedUserType
                                                        .value,
                                                isExpanded: true,
                                                items:
                                                    controller.userTypes.map((
                                                      String value,
                                                    ) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller
                                                        .selectedUserType
                                                        .value = newValue;
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Notification Details Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header - Separate container with padding from all sides
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Notification Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Description content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFormField(
                                      label: 'Notification Description',
                                      hint:
                                          'Craft a comprehensive description that highlights the unique features, benefits, and specifications of your notification.',
                                      child: TextFormField(
                                        controller:
                                            controller.descriptionController,
                                        maxLines: 8,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Enter notification description...',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFF97316),
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(16),
                                        ),
                                        validator: (value) {
                                          if (value != null &&
                                              value.length > 10000) {
                                            return 'Description must be less than 10000 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Column(
                          children: [
                            // Save button
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : controller.submitNotification,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                  child:
                                      controller.isLoading.value
                                          ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Saving...',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          )
                                          : const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Cancel button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: TextButton(
                                onPressed: controller.cancelForm,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.grey[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    bool isRequired = false,
    String? hint,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 6),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// Usage example - Add this to your main routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notification App',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: NotificationFormScreen(),
    );
  }
}
