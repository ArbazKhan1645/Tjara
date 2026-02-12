import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'dart:convert';

import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

// FAQ Controller

// FAQ Controller
class FAQController extends GetxController {
  var faqs = <PostModel>[].obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var searchQuery = ''.obs;

  final String baseUrl = 'https://api.libanbuy.com/api';

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  List<PostModel> get filteredFAQs {
    if (searchQuery.isEmpty) return faqs;
    return faqs
        .where(
          (faq) =>
              faq.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (faq.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  Future<void> fetchFAQs({bool bustCache = true}) async {
    try {
      isLoading.value = true;

      // Add cache busting parameter when needed
      String url =
          '$baseUrl/posts?with=thumbnail,shop&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&filterByColumns[columns][1][column]=post_type&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=faqs';

      if (bustCache) {
        url += '&_t=${DateTime.now().millisecondsSinceEpoch}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['posts'] != null) {
          final List<dynamic> faqList = data['posts']['data'];
          faqs.value = faqList.map((json) => PostModel.fromJson(json)).toList();
        } else {
          faqs.value = [];
        }

        // Get.snackbar(
        //   'Success',
        //   'FAQs loaded successfully',
        //   backgroundColor: Colors.green[100],
        //   colorText: Colors.green[800],
        //   snackPosition: SnackPosition.TOP,
        //   duration: Duration(seconds: 2),
        // );
      } else {
        throw Exception('Failed to load FAQs: ${response.statusCode}');
      }
    } catch (e) {
      String errorMessage = 'Failed to load FAQs';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFAQ(String id) async {
    try {
      isDeleting.value = true;

      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id/delete'),
        headers: {
          'Accept': 'application/json',
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        faqs.removeWhere((faq) => faq.id == id);

        // Refresh with cache busting to ensure updated data
        fetchFAQs(bustCache: true);
      } else {
        throw Exception('Failed to delete FAQ: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete FAQ',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void showDeleteConfirmation(PostModel faq) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete FAQ'),
        content: Text('Are you sure you want to delete "${faq.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteFAQ(faq.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper method to truncate text for display
  String truncateText(String text, int maxLength) {
    // Remove <p> and </p> tags
    text = text.replaceAll('<p>', '').replaceAll('</p>', '');

    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

// FAQ List Screen
class FAQListScreen extends StatelessWidget {
  final FAQController controller = Get.put(FAQController());

  FAQListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
                        'FAQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Add New Button Card
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
                              // Add New Button
                              InkWell(
                                onTap: () {
                                  Get.to(() => const FAQFormScreen());
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add New',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // FAQ DataTable Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
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
                              // Search Input
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Search faq',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    controller.searchQuery.value = value;
                                  },
                                ),
                              ),

                              // FAQ Section Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'FAQ Management',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // DataTable with horizontal scroll
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Obx(() {
                                  if (controller.isLoading.value) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFF97316),
                                        ),
                                      ),
                                    );
                                  }

                                  if (controller.filteredFAQs.isEmpty) {
                                    return SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.help_outline,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No FAQs found',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              64,
                                        ),
                                        child: DataTable(
                                          columnSpacing: 20,
                                          headingRowColor:
                                              WidgetStateProperty.all(
                                                const Color(0xFFF97316),
                                              ),
                                          headingTextStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                          dataTextStyle: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                          columns: [
                                            const DataColumn(
                                              label: Text('S.No'),
                                            ),
                                            const DataColumn(
                                              label: Text('Question'),
                                            ),
                                            const DataColumn(
                                              label: Text('Answer'),
                                            ),
                                            const DataColumn(
                                              label: Text('Actions'),
                                            ),
                                          ],
                                          rows:
                                              controller.filteredFAQs.asMap().entries.map((
                                                entry,
                                              ) {
                                                final index = entry.key;
                                                final faq = entry.value;

                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text('${index + 1}'),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                              maxWidth: 200,
                                                            ),
                                                        child: Tooltip(
                                                          message: faq.name,
                                                          child: Text(
                                                            controller
                                                                .truncateText(
                                                                  faq.name,
                                                                  50,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                              maxWidth: 250,
                                                            ),
                                                        child: Tooltip(
                                                          message:
                                                              faq.description ??
                                                              'No answer provided',
                                                          child: Text(
                                                            controller.truncateText(
                                                              faq.description ??
                                                                  'No answer provided',
                                                              60,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.blue,
                                                              size: 20,
                                                            ),
                                                            onPressed:
                                                                () => Get.to(
                                                                  () =>
                                                                      FAQFormScreen(
                                                                        faq:
                                                                            faq,
                                                                      ),
                                                                ),
                                                            tooltip: 'Edit',
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                            onPressed:
                                                                () => controller
                                                                    .showDeleteConfirmation(
                                                                      faq,
                                                                    ),
                                                            tooltip: 'Delete',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Pagination button
                        // Container(
                        //   width: double.infinity,
                        //   margin: EdgeInsets.only(bottom: 20),
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // Add pagination logic here
                        //       controller.fetchFAQs();
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.black,
                        //       foregroundColor: Colors.white,
                        //       padding: EdgeInsets.symmetric(vertical: 16),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       '1/1',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
}

// Rest of your existing code (FAQFormController and FAQFormScreen) remains the same...

// FAQ Form Controller
class FAQFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  var isLoading = false.obs;
  PostModel? editingFAQ;

  final String baseUrl = 'https://api.libanbuy.com/api';

  void setEditingFAQ(PostModel? faq) {
    editingFAQ = faq;
    if (faq != null) {
      nameController.text = faq.name;
      descriptionController.text = faq.description ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> submitFAQ() async {
    try {
      isLoading.value = true;

      final Map<String, dynamic> requestData = {
        'name': nameController.text.trim(),
        'post_type': 'faqs',
        'description': descriptionController.text.trim(),
      };

      http.Response response;

      if (editingFAQ != null) {
        // Update existing FAQ
        response = await http.put(
          Uri.parse('$baseUrl/posts/${editingFAQ!.id}/update'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Request-From': 'Application',
          },
          body: json.encode(requestData),
        );
      } else {
        // Create new FAQ
        response = await http.post(
          Uri.parse('$baseUrl/posts/insert'),
          headers: {
            'Content-Type': 'application/json',
            'X-Request-From': 'Application',
            'Accept': 'application/json',
            'shop-id':
                AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          },
          body: json.encode(requestData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Success',
          editingFAQ != null
              ? 'FAQ updated successfully!'
              : 'FAQ created successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Refresh FAQ list with cache busting
        if (Get.isRegistered<FAQController>()) {
          Get.find<FAQController>().fetchFAQs(bustCache: true);
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage =
            editingFAQ != null
                ? 'Failed to update FAQ'
                : 'Failed to create FAQ';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
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
      String errorMessage = 'Network error occurred';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please try again';
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

  void cancelForm() {
    nameController.clear();
    descriptionController.clear();
    Get.back();
  }
}

// FAQ Form Screen
class FAQFormScreen extends StatelessWidget {
  final PostModel? faq;

  const FAQFormScreen({super.key, this.faq});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    final FAQFormController controller = Get.put(FAQFormController());

    // Set editing FAQ if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setEditingFAQ(faq);
    });

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
                        'Add FAQ',
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
                        // Question Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
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
                                      'Question',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Question content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
                                  controller: controller.nameController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Enter FAQ question...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF97316),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Question is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 49),
                            ],
                          ),
                        ),

                        // Answer Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
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
                                      'Answer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Answer content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextFormField(
                                  controller: controller.descriptionController,
                                  maxLines: 8,
                                  decoration: InputDecoration(
                                    hintText: 'Enter FAQ answer...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF97316),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Answer is required';
                                    }
                                    return null;
                                  },
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
                                          : controller.submitFAQ,
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
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
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
                                              const SizedBox(width: 12),
                                              Text(
                                                faq != null
                                                    ? 'Updating...'
                                                    : 'Saving...',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          )
                                          : Text(
                                            faq != null ? 'Update' : 'Save',
                                            style: const TextStyle(
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
}
