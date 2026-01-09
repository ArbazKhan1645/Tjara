import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'dart:convert';

import 'package:tjara/app/models/others/country_model.dart';

class CountryController extends GetxController {
  final countries = <Countries>[].obs;
  final isLoading = false.obs;
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isEditing = false.obs;
  var editingId = 0.obs;

  final apiBase = 'https://api.libanbuy.com/api/countries';

  @override
  void onInit() {
    fetchCountries();
    super.onInit();
  }

  Future<void> fetchCountries() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse(apiBase),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final CountryModel res = CountryModel.fromJson(jsonData);
        countries.value = res.countries ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch countries');
    } finally {
      isLoading.value = false;
    }
  }

  final searchQuery = ''.obs;

  List<Countries> get filteredCountries {
    if (searchQuery.isEmpty) return countries;
    return countries
        .where(
          (country) =>
              country.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false,
        )
        .toList();
  }

  Future<void> insertOrUpdateCountry() async {
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final url =
        isEditing.value
            ? '$apiBase/${editingId.value}/update'
            : '$apiBase/insert';

    try {
      final response =
          isEditing.value
              ? await http.put(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'X-Request-From': 'Application',
                },
                body: jsonEncode({'name': name}),
              )
              : await http.post(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'X-Request-From': 'Application',
                },
                body: jsonEncode({'name': name}),
              );

      if (response.statusCode == 200 || response.statusCode == 201) {
        nameController.clear();
        isEditing.value = false;
        editingId.value = 0;
        fetchCountries();
        Get.snackbar(
          'Success',
          isEditing.value ? 'Country Updated' : 'Country Added',
        );
      } else {
        Get.snackbar(
          'Error',
          json.decode(response.body)['message'] ?? 'Operation failed',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed $e');
    }
  }

  void startEditing(Countries country) {
    nameController.text = country.name ?? '';
    isEditing.value = true;
    editingId.value = int.tryParse(country.id.toString()) ?? 0;
  }

  Future<void> deleteCountry(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBase/$id/delete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );
      if (response.statusCode == 200) {
        fetchCountries();
        Get.snackbar('Success', 'Country deleted');
      } else {
        Get.snackbar('Error', 'Failed to delete country');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete');
    }
  }

  void cancelEditing() {
    nameController.clear();
    isEditing.value = false;
    editingId.value = 0;
  }
}

class CountryPage extends StatelessWidget {
  final controller = Get.put(CountryController());

  CountryPage({super.key});

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
                        'Countries',
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
                        // Add Countries Form Card
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
                                    Text(
                                      'Add Countries',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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
                                      // Country Name label
                                      Text(
                                        'Country Name',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Country Name Input
                                      TextFormField(
                                        controller: controller.nameController,
                                        decoration: InputDecoration(
                                          hintText: 'Country Name',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
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
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Required'
                                                    : null,
                                      ),
                                      const SizedBox(height: 20),
                                      // Buttons
                                      Column(
                                        children: [
                                          // Go Ahead button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed:
                                                  controller
                                                      .insertOrUpdateCountry,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFF97316,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                elevation: 2,
                                              ),
                                              child: const Text(
                                                'Go Ahead',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
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
                                              onPressed:
                                                  controller.cancelEditing,
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                foregroundColor:
                                                    Colors.grey[700],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Countries List Card
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
                              // Search Input
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Search Countries',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
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

                              // Countries List
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFF97316),
                                    ),
                                  );
                                }

                                if (controller.filteredCountries.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No countries found',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount:
                                      controller.filteredCountries.length,
                                  itemBuilder: (context, index) {
                                    final country =
                                        controller.filteredCountries[index];

                                    // Get first letter for the grouping
                                    final String firstLetter =
                                        country.name![0].toUpperCase();
                                    // Only show letter if it's the first occurrence
                                    final bool showLetter =
                                        index == 0 ||
                                        controller
                                                .filteredCountries[index - 1]
                                                .name![0]
                                                .toUpperCase() !=
                                            firstLetter;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showLetter)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: index == 0 ? 8 : 20,
                                              bottom: 8,
                                              right: 16,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  firstLetter,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              // Country flag circle
                                              _getCountryFlag(country.name),
                                              const SizedBox(width: 12),
                                              // Country name
                                              Expanded(
                                                child: Text(
                                                  country.name.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // Action buttons
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                    onPressed:
                                                        () => controller
                                                            .startEditing(
                                                              country,
                                                            ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                    onPressed:
                                                        () => controller
                                                            .deleteCountry(
                                                              country.id
                                                                  .toString(),
                                                            ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index <
                                            controller
                                                    .filteredCountries
                                                    .length -
                                                1)
                                          Divider(
                                            height: 1,
                                            color: Colors.grey[200],
                                          ),
                                      ],
                                    );
                                  },
                                );
                              }),
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
      ),
    );
  }

  /// Returns a circular widget with flag or country initials
  Widget _getCountryFlag(String? countryName) {
    if (countryName == null || countryName.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 16,
        child: Icon(Icons.flag, color: Colors.white, size: 16),
      );
    }

    // Map some countries to their flag colors (simplified for example)
    final Map<String, Color> flagColors = {
      'Albania': Colors.red,
      'Algeria': Colors.green,
      'Andorra': Colors.blue,
      'Bahamas': Colors.lightBlue,
      'Belarus': Colors.red,
      'Belize': Colors.blue,
      'Chad': Colors.red,
      'China': Colors.red,
      'Cuba': Colors.blue,
      // Add more countries as needed
    };

    // Get flag color or default to a random color based on country name
    final Color flagColor =
        flagColors[countryName] ??
        Colors.primaries[countryName.hashCode % Colors.primaries.length];

    return CircleAvatar(
      backgroundColor: flagColor,
      radius: 16,
      child: Text(
        countryName.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
