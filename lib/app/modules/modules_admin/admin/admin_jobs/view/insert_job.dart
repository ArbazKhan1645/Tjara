// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/models/attributes_model.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:tjara/app/services/others/others_service.dart';
import 'package:tjara/app/models/others/cities_model.dart';

// Add your Job model import here
// import 'package:tjara/app/models/job_model.dart';

class InsertJobController extends GetxController {
  final Rx<JobAttributeItem?> selectedParent = Rx<JobAttributeItem?>(null);
  String categoryId = '';
  final RxList<JobAttribute> jobAttributes = <JobAttribute>[].obs;
  final NetworkRepository _repository = NetworkRepository();
  Future<void> fetchJobAttributes() async {
    try {
      final result = await _repository.fetchData<JobAttributesResponse>(
        url:
            'https://api.libanbuy.com/api/job-attributes?slug=${DateTime.now().millisecondsSinceEpoch}_t=${DateTime.now().millisecondsSinceEpoch}',
        fromJson: (json) => JobAttributesResponse.fromJson(json),
      );

      jobAttributes.assignAll(result.jobAttributes ?? []);
    } catch (e) {
      print('Failed to load job attributes: $e');
    }
  }

  // Basic form fields
  final title = ''.obs;
  final salary = ''.obs;
  final jobType = 'full-time'.obs;
  final workType = 'on-site'.obs;
  final description = ''.obs;
  final selectedCategory = ''.obs;

  // Location fields
  Countries? selectedCountry;
  States? selectedState;
  City? selectedCity;

  // Media fields
  final thumbnail = Rx<String?>(null);
  final thumbnailFile = Rx<File?>(null);

  // Loading state
  final isLoading = false.obs;

  // Edit mode fields
  final isEditMode = false.obs;
  dynamic editingJob; // Replace with your Job model type
  String? editingJobId;

  // Static data
  final categories = ['Design', 'Development', 'Marketing'];

  @override
  void onInit() {
    super.onInit();

    fetchJobAttributes();

    // Ensure CountryService is initialized and countries are loaded
    if (!Get.isRegistered<CountryService>()) {
      Get.putAsync<CountryService>(() async => CountryService().init());
    } else {
      CountryService.instance.loadCountries();
    }

    // Check if we're in edit mode by looking for passed arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('job')) {
      _initializeEditMode(args['job']);
    }
  }

  void _initializeEditMode(dynamic job) {
    isEditMode.value = true;
    editingJob = job;
    editingJobId = job.id?.toString();

    // Populate form fields with existing job data
    title.value = job.title ?? '';
    salary.value = job.salary?.toString() ?? '';
    jobType.value = job.jobType ?? 'full-time';
    workType.value = job.workType ?? 'on-site';
    description.value = job.description ?? '';
    thumbnail.value = job.thumbnailId?.toString();

    // Set location data if available
    if (job.countryId != null) {
      selectedCountry =
          CountryService.instance.countryList
              .where(
                (country) => country.id.toString() == job.countryId.toString(),
              )
              .firstOrNull;

      if (selectedCountry != null && job.stateId != null) {
        CountryService.instance
            .fetchStates(selectedCountry!.id.toString())
            .then((_) {
              selectedState =
                  CountryService.instance.stateList
                      .where(
                        (state) =>
                            state.id.toString() == job.stateId.toString(),
                      )
                      .firstOrNull;

              if (selectedState != null && job.cityId != null) {
                CountryService.instance
                    .fetchCities(selectedState!.id.toString())
                    .then((_) {
                      selectedCity =
                          CountryService.instance.cityList
                              .where(
                                (city) =>
                                    city.id.toString() == job.cityId.toString(),
                              )
                              .firstOrNull;
                    });
              }
            });
      }
    }
  }

  Future<List<String>> _uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final List<String> mediaIds = [];
    final String id = await uploadMedia(
      files,
      directory: directory,
      width: width,
      height: height,
    );
    if (!id.contains('Failed to upload media')) {
      mediaIds.add(id);
    }
    return mediaIds;
  }

  Future<String> uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'X-Request-From': 'Application',
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    // Add media files
    for (var file in files) {
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'media[]',
        stream,
        length,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);
    }

    // Add optional parameters
    if (directory != null) {
      request.fields['directory'] = directory;
    }

    if (width != null) {
      request.fields['width'] = width.toString();
    }

    if (height != null) {
      request.fields['height'] = height.toString();
    }

    // Send request and allow redirects
    final response = await request.send();

    // Handle redirect manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await uploadMedia(
          files,
          directory: directory,
          width: width,
          height: height,
        );
      }
    }

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      return jsonData['media'][0]['id'];
    } else {
      return 'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}';
    }
  }

  Future<void> pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final File file = File(picked.path);
      thumbnailFile.value = file;
      _uploadMedia([file]).then((mediaIds) {
        if (mediaIds.isNotEmpty) {
          thumbnail.value = mediaIds.first;
        }
      });
    }
  }

  Future<void> submitJob() async {
    if (isEditMode.value) {
      await _updateJob();
    } else {
      await _createJob();
    }
  }

  Future<void> _createJob() async {
    isLoading.value = true;

    final uri = Uri.parse('https://api.libanbuy.com/api/jobs/insert');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'X-Request-From': 'Application',
      'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
    });

    // Regular string fields
    request.fields['title'] = title.value;
    request.fields['salary'] = salary.value;
    request.fields['job_type'] = jobType.value;
    request.fields['work_type'] = workType.value;
    request.fields['description'] = description.value;
    request.fields['thumbnail_id'] = thumbnail.value ?? '';
    request.fields['country_id'] = selectedCountry?.id ?? '';
    request.fields['state_id'] = selectedState?.id ?? '';
    request.fields['city_id'] = selectedCity?.id ?? '';

    // If categories is a single ID:
    if (categoryId.isNotEmpty) {
      request.fields['categories[0]'] = categoryId;
    }

    // If categories is a list:
    // for (var id in categoryIds) {
    //   request.fields['categories[]'] = id;
    // }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar('Success', 'Job created successfully');
      } else {
        final parsed = json.decode(responseBody);
        Get.snackbar('Error', parsed['message'] ?? 'Failed to create job');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create job: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateJob() async {
    if (editingJobId == null) return;

    isLoading.value = true;

    final uri = Uri.parse(
      'https://api.libanbuy.com/api/jobs/$editingJobId/update',
    );

    final Map<String, String> body = {
      'title': title.value,
      'salary': salary.value,
      'job_type': jobType.value,
      'work_type': workType.value,
      'description': description.value,
      'thumbnail_id': thumbnail.value ?? '',
      'country_id': selectedCountry?.id ?? '',
      'state_id': selectedState?.id ?? '',
      'city_id': selectedCity?.id ?? '',
    };

    try {
      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Request-From': 'Application',
          'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar('Success', 'Job updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update job');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update job: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJob() async {
    if (editingJobId == null) return;

    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${title.value}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    final uri = Uri.parse(
      'https://api.libanbuy.com/api/jobs/$editingJobId/delete',
    );

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Request-From': 'Application',
          'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.back();
        Get.snackbar('Success', 'Job deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete job');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete job: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    title.value = '';
    salary.value = '';
    jobType.value = 'full-time';
    workType.value = 'on-site';
    description.value = '';
    selectedCategory.value = '';
    thumbnail.value = null;
    thumbnailFile.value = null;
    selectedCountry = null;
    selectedState = null;
    selectedCity = null;
    isEditMode.value = false;
    editingJob = null;
    editingJobId = null;
  }
}

class InsertJobScreen extends StatefulWidget {
  const InsertJobScreen({super.key});

  @override
  State<InsertJobScreen> createState() => _InsertJobScreenState();
}

class _InsertJobScreenState extends State<InsertJobScreen> {
  final controller = Get.put(InsertJobController());

  Widget buildCard({required String title, required Widget child}) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, RxString selected) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: selected.value.isEmpty ? null : selected.value,
      onChanged: (value) => selected.value = value!,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    );
  }

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
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Job' : 'Create Job',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Information Section
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Orange Header
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Job Title',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Job Name*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Enter the unique name of your job. Make it descriptive and easy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: TextEditingController(
                                            text: controller.title.value,
                                          )
                                          ..selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset:
                                                      controller
                                                          .title
                                                          .value
                                                          .length,
                                                ),
                                              ),
                                        decoration: InputDecoration(
                                          hintText: 'Name',
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                        ),
                                        onChanged:
                                            (v) => controller.title.value = v,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Category*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Select the primary category that best represents your job. This helps employee find your job more easily',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Obx(() {
                                        final items =
                                            controller.jobAttributes.isNotEmpty
                                                ? controller
                                                        .jobAttributes
                                                        .first
                                                        .attributeItems
                                                        ?.jobAttributeItems ??
                                                    []
                                                : <JobAttributeItem>[];

                                        return DropdownButtonFormField<
                                          JobAttributeItem
                                        >(
                                          decoration: InputDecoration(
                                            hintText: 'Select Category',
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          initialValue:
                                              controller.selectedParent.value,
                                          items:
                                              items
                                                  .map(
                                                    (attribute) =>
                                                        DropdownMenuItem(
                                                          value: attribute,
                                                          child: Text(
                                                            attribute.name ??
                                                                'Unnamed',
                                                          ),
                                                        ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            controller.selectedParent.value =
                                                value;
                                            controller.categoryId =
                                                value?.id ?? '';
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Upload Job Section
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Orange Header
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Upload Job',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Featured Image*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'High Quality Images Can significantly impact your banners appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: controller.pickThumbnail,
                                        child: Obx(
                                          () => Container(
                                            height: 60,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child:
                                                controller
                                                            .thumbnailFile
                                                            .value !=
                                                        null
                                                    ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: Image.file(
                                                        controller
                                                            .thumbnailFile
                                                            .value!,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                    )
                                                    : controller
                                                            .isEditMode
                                                            .value &&
                                                        controller
                                                                .thumbnail
                                                                .value !=
                                                            null
                                                    ? const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.image,
                                                            size: 24,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Current image (tap to change)',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    : const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.landscape,
                                                          color: Colors.black,
                                                          size: 24,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Upload a file',
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF165E28,
                                                            ),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Job Details Section
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Orange Header
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF97316),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Job Details',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Job Description
                                      const Text(
                                        'Job Description*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Craft a comprehensive description that highlights th benefits of your Job',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: TextEditingController(
                                            text: controller.description.value,
                                          )
                                          ..selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset:
                                                      controller
                                                          .description
                                                          .value
                                                          .length,
                                                ),
                                              ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                        ),
                                        maxLines: 6,
                                        onChanged:
                                            (v) =>
                                                controller.description.value =
                                                    v,
                                      ),
                                      const SizedBox(height: 16),
                                      // Salary
                                      const Text(
                                        'Salary:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: TextEditingController(
                                            text: controller.salary.value,
                                          )
                                          ..selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset:
                                                      controller
                                                          .salary
                                                          .value
                                                          .length,
                                                ),
                                              ),
                                        decoration: InputDecoration(
                                          hintText: '',
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged:
                                            (v) => controller.salary.value = v,
                                      ),
                                      const SizedBox(height: 16),
                                      // Job Type
                                      const Text(
                                        'Job Type*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      buildDropdown('Select job type', [
                                        'part-time',
                                        'full-time',
                                      ], controller.jobType),
                                      const SizedBox(height: 16),
                                      // Work Type
                                      const Text(
                                        'Work Type*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      buildDropdown('Select work type', [
                                        'on-site',
                                        'remote',
                                      ], controller.workType),
                                      const SizedBox(height: 16),
                                      // Country
                                      const Text(
                                        'Country*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: DropdownButtonFormField<
                                          Countries
                                        >(
                                          decoration: const InputDecoration(
                                            hintText: 'Select country',
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          isExpanded: true,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          initialValue:
                                              controller.selectedCountry,
                                          items:
                                              CountryService
                                                  .instance
                                                  .countryList
                                                  .map((Countries value) {
                                                    return DropdownMenuItem<
                                                      Countries
                                                    >(
                                                      value: value,
                                                      child: Text(
                                                        value.name.toString(),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              controller.selectedCountry =
                                                  newValue;
                                              controller.selectedState = null;
                                              controller.selectedCity = null;
                                              CountryService.instance.stateList
                                                  .clear();
                                              CountryService.instance.cityList
                                                  .clear();
                                              CountryService.instance
                                                  .fetchStates(
                                                    newValue!.id.toString(),
                                                  );
                                            });
                                          },
                                          validator:
                                              (value) =>
                                                  value == null
                                                      ? 'Please select a country'
                                                      : null,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // State
                                      const Text(
                                        'State*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Obx(() {
                                        final List<States> states =
                                            CountryService.instance.stateList;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<
                                            States
                                          >(
                                            decoration: const InputDecoration(
                                              hintText: 'Select country',
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                            initialValue:
                                                controller.selectedState,
                                            items:
                                                states.map((States value) {
                                                  return DropdownMenuItem<
                                                    States
                                                  >(
                                                    value: value,
                                                    child: Text(
                                                      value.name.toString(),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                controller.selectedState =
                                                    newValue;
                                                controller.selectedCity = null;
                                                CountryService.instance.cityList
                                                    .clear();
                                                CountryService.instance
                                                    .fetchCities(
                                                      newValue!.id.toString(),
                                                    );
                                              });
                                            },
                                            validator:
                                                (value) =>
                                                    value == null
                                                        ? 'Please select a state'
                                                        : null,
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                      // City
                                      const Text(
                                        'City*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Obx(() {
                                        final List<City> cities =
                                            CountryService.instance.cityList;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<City>(
                                            decoration: const InputDecoration(
                                              hintText: 'Select city',
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                            initialValue:
                                                controller.selectedCity,
                                            items:
                                                cities.map((City value) {
                                                  return DropdownMenuItem<City>(
                                                    value: value,
                                                    child: Text(
                                                      value.name.toString(),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                controller.selectedCity =
                                                    newValue;
                                              });
                                            },
                                            validator:
                                                (value) =>
                                                    value == null
                                                        ? 'Please select a city'
                                                        : null,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Obx(
                            () => Column(
                              children: [
                                // Delete button (only in edit mode)
                                if (controller.isEditMode.value) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: controller.deleteJob,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete Job',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Save and Cancel buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: controller.submitJob,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0D9488,
                                          ), // Teal color
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Get.back(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black87,
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
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
